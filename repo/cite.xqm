module namespace c = "cite";

(: Canonical citation keys, the join between a GLAUx treebank and a Perseus TEI
   translation of the same work.

   Both corpora inherit Perseus' numbering, so a passage can be addressed by the
   same dotted string on either side — "1.1.0" is Herodotus book 1, chapter 1,
   section 0 in both. What differs is where that string lives: GLAUx denormalizes
   it onto every <word> as a @div_* attribute, while the TEI carries it as a chain
   of nested <div n=""> plus <l n=""> for verse. These functions reduce each side
   to the same key.

   Which GLAUx attribute is the key varies by work, and cannot be inferred from
   the author: across the 52 paginated works that have a translation it is
   @div_section for 24, @div_book for 15, @div_chapter for 11 and
   @div_perseus_section for 2. c:key picks it by seeing which one the TEI's own
   references actually match. :)

(: Finest first: a work carrying both @div_chapter and @div_section is cited by
   section, and Plato is cited by Perseus section rather than by the Stephanus
   page that also appears on its words. @line is the verse case, and @div_book the
   floor for a text divided no more finely than that. :)
declare variable $c:keys := (
  'div_section', 'div_perseus_section', 'div_chapter', 'line', 'div_book'
);

(: Every citation the TEI offers, at every depth of its div chain. A <l n="5">
   nested under book 1 of a card-divided edition answers to "1.1.5", "1.5" and
   "5", and GLAUx cites that line as @line="1.5" — neither the full chain nor the
   bare number. Emitting every suffix is what lets the two meet, and costs
   nothing: c:key only ever asks whether a GLAUx value is present. :)
declare function c:tei-refs($tei as node()) as xs:string* {
  distinct-values(c:tei-refs($tei, ()))
};

declare %private function c:tei-refs($node as node(), $chain as xs:string*) as xs:string* {
  let $name := local-name($node)
  (: The edition wrapper carries the work's URN in @n, which is not a citation. :)
  let $chain :=
    if ($name = 'div' and exists($node/@n)
        and not(lower-case(($node/@subtype, $node/@type)[1]) = ('edition', 'translation')))
    then ($chain, string($node/@n))
    else $chain
  let $ref :=
    if ($name = ('l', 'milestone') and exists($node/@n)) then ($chain, string($node/@n))
    else if ($name = 'div' and exists($chain)) then $chain
    else ()
  return (
    c:suffixes($ref),
    for $child in $node/* return c:tei-refs($child, $chain)
  )
};

(: Every trailing run of a citation chain, longest first: ("1","1","5") becomes
   "1.1.5", "1.5", "5". :)
declare %private function c:suffixes($chain as xs:string*) as xs:string* {
  for $start in 1 to count($chain)
  return string-join(subsequence($chain, $start), '.')
};

(: The GLAUx attribute whose values the TEI actually cites, or empty if none of
   them line up. Resolved per work rather than configured, since the alternative
   is a 52-entry table that has to be revisited whenever a translation is added. :)
declare function c:key($tb as node(), $tei as node()) as xs:string? {
  let $refs := c:tei-refs($tei)
  return head(
    for $attr in $c:keys
      let $vals := distinct-values($tb//word/@*[name() = $attr])
      where exists($vals)
      let $hits := count($vals[c:near(., $refs)])
      (: Below this a key is coincidence, not agreement — the runner-up attribute
         on a well-aligned work typically lands under a third. :)
      where $hits div count($vals) ge 0.8
      (: No ordering: $c:keys is already finest-first, and on a well-aligned work
         several attributes clear the threshold together — Herodotus matches book,
         chapter and section alike. Sorting by hit rate would pick whichever tied
         first by accident, losing the finest usable key. :)
      return $attr
  )
};

(: Whether a citation is covered by the TEI, exactly or by the nearest anchor
   before it. Verse translations number lines at intervals — Euripides marks 1, 5,
   10 — so requiring equality would score those works near 40% and read as a
   corpus mismatch rather than the sampling it is. Ten is comfortably past the
   five-line convention without letting a genuinely absent passage match. :)
declare function c:near($ref as xs:string, $refs as xs:string*) as xs:boolean {
  if ($ref = $refs) then true()
  else
    let $parts := analyze-string($ref, '^(.*?)(\d+)([a-z]?)$')//*:group
    return
      if (count($parts) = 0) then false()
      else
        let $prefix := string($parts[@nr = 1])
        let $num := xs:integer($parts[@nr = 2])
        let $suffix := string($parts[@nr = 3])
        return some $back in 1 to 10
          satisfies `{$prefix}{$num - $back}{$suffix}` = $refs
};
