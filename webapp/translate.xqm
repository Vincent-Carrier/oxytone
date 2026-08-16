module namespace tr = "oxytone/translate";
import module namespace p = "paginate";
import module namespace urn = "urn";

(: The English translation of one page of a work, from the Perseus editions
   `just translations` puts in the `translations` DB.

   A page is a range of citations rather than a document, so the translation is
   assembled by keeping the TEI blocks whose own citation falls on the requested
   page. Which citation that is varies by work — see repo/cite.xqm — so the key is
   resolved per request against the treebank rather than assumed.

   Most works have no translation: 128 of the 180 that paginate. That returns an
   empty <translation>, not an error, and the frontend hides the link. :)

(: The lowest div that carries a citation, i.e. the blocks the reader actually
   sees. A <div> holding only other divs is structure, not a passage. :)
declare %private function tr:passages($tei as node()) as element()* {
  $tei//*:div[@n][not(*:div)]
};

(: A passage's text, with the editorial apparatus left out. Two kinds of it sit
   inline and splice into the sentence if the string value is taken whole:

   <reg> holds a Getty-thesaurus regularization beside the reading text, so
   Herodotus is "of Bodrum [27.466,37.5] (inhabited place), Mugla Ili…
   Halicarnassus" rather than "of Halicarnassus".

   <note> holds an editorial footnote. Its text has to come out of the running
   prose — the Loeb Odyssey otherwise reads "flashing-eyed1 Athena" — but it is
   worth keeping: 49 of the 51 paginated translations carry substantive notes,
   38,502 across the corpus. tr:content emits it as a marker the reader turns into
   a popover, so only Homer's two, whose notes are bare digits, lose anything.

   A <milestone/> line marker carries no text of its own, and the edition leans on
   it for the break, so the text nodes on either side run together as "upon the
   sea,seeking to win". It contributes a space; joining every node on one instead
   would space the punctuation off its word ("citadel of Troy ."), since
   <placeName>Troy</placeName> and the period that follows are separate nodes.

   Dropping an inline element leaves the whitespace that surrounded it, which then
   sits in front of the following punctuation — "of Halicarnassus , so that". The
   final replace closes that gap up. :)
declare %private function tr:text($nodes as node()*) as xs:string {
  let $text := normalize-space(string-join(
    $nodes/descendant-or-self::node()[self::text() or self::*:milestone]
      [not(ancestor::*:reg or ancestor::*:note)]
      ! (if (self::*:milestone) then ' ' else string(.))
  ))
  return replace($text, '\s+([,.;:!?’”)])', '$1')
};

(: A note's own text, which needs the same apparatus stripping as the prose: notes
   carry <reg> gazetteer entries too. :)
declare %private function tr:note-text($note as element()) as xs:string {
  normalize-space(replace(
    string-join($note/descendant-or-self::node()[self::text()][not(ancestor::*:reg)]),
    '\s+', ' '))
};

(: A passage rendered as text with its footnotes marked where they occur.

   Walked in document order rather than string-joined, so a note keeps its place in
   the sentence: each becomes a <button> carrying its text, which the reader turns
   into a popover. A note whose body is only a marker digit is dropped — Homer's
   Loeb numbers point at an apparatus this corpus does not ship — which is why the
   filter is on the note's own length rather than on its presence. :)
declare %private function tr:content($passage as element()) as node()* {
  (: Split at the notes worth keeping, then render each run of prose between them
     with tr:text — which is what collapses whitespace and tightens punctuation, and
     cannot be applied across the whole passage once buttons are interleaved. :)
  let $notes := $passage//*:note[string-length(tr:note-text(.)) gt 15]
  let $flat := $passage//node()[self::text() or self::*:milestone][not(ancestor::*:reg)]
  (: A note's own text is excluded from the prose, but the note still marks where
     the run ends: everything before it belongs to the preceding run. :)
  let $prose := $flat[not(ancestor::*:note)]
  return
    if (empty($notes)) then text { tr:text($passage) }
    else (
      for $note at $i in $notes
        let $start := if ($i eq 1) then () else $notes[$i - 1]
        let $run := $prose[. << $note and (empty($start) or . >> $start)]
        return (
          text { tr:text($run) },
          (: A dagger rather than the edition's own numeral: those number per page
             of a printed book, which this pagination does not follow, so they would
             restart and repeat down the screen. :)
          <button type="button" class="note" data-note="{tr:note-text($note)}"
                  aria-label="editorial note">†</button>
        ),
      text { tr:text($prose[. >> $notes[last()]]) }
    )
};

(: The div chain a passage sits under, outermost first, skipping the edition
   wrapper whose @n is the work's URN rather than a citation. :)
declare %private function tr:chain($passage as element()) as xs:string* {
  $passage/ancestor-or-self::*:div[@n]
    [not(lower-case((@subtype, @type)[1]) = ('edition', 'translation'))]
    ! string(@n)
};

(: A passage's full dotted citation, "2.35.1" rather than the "1" its own @n
   carries. Chapter and section numbering restarts in every book, so the local
   number alone repeats across the work — it would collide as an id, and it is the
   dotted form that GLAUx's @div_section holds and repo/cite.xqm joins on. :)
declare %private function tr:cite($passage as element()) as xs:string {
  string-join(tr:chain($passage), '.')
};

(: The page a passage belongs to: the leading segment of its citation, so section
   1.32.4 of Herodotus is on book 1. :)
declare %private function tr:page-of($passage as element()) as xs:string {
  head(tr:chain($passage))
};

declare
  %rest:path("/translate/{$author}/{$work-page=.+}")
  %output:method("html")
  function tr:get-page($author, $work-page) {
    let $wp := urn:work-page($work-page)
    let $work := $wp?work
    let $tei := db:get('translations', `{$author}/{$work}`)[1]
    let $pager := p:pager(`{$author}/{$work}`)
    let $page := if (exists($pager)) then ($wp?page otherwise head($pager?list)) else $wp?page
    return
      (: A marker rather than a 404: having no translation is the ordinary case for
         128 of the 180 works that paginate, and the reader says so in its own words
         rather than rendering this. :)
      if (empty($tei)) then <div data-empty="yes" />
      else
        let $passages := tr:passages($tei)
        (: Unpaginated works are read whole, so every passage belongs. :)
        let $on-page :=
          if (empty($page)) then $passages
          else $passages[tr:page-of(.) = string($page)]
        (: <hgroup> and <main> as siblings rather than inside a wrapper:
           treebank.css styles the heading with `& > hgroup` on .treebank, so a
           wrapping div here would put it a level too deep and drop the styles. :)
        return (
            <hgroup>
              <h1>{normalize-space(string(($tei//*:titleStmt/*:title)[1]))}</h1>
              <p class="author">{normalize-space(string(($tei//*:titleStmt/*:author)[1]))}</p>
            </hgroup>,
            <main class="body" lang="en">{
              (: The marker shows the local number, as the Greek side does: the
                 page is already one book, so repeating it on every paragraph is
                 noise. The id keeps the full citation, which is what links. :)
              for $passage in $on-page
              let $cite := tr:cite($passage)
              return <p id="{$cite}"><a class="nbr section-nbr" href="#{$cite}">{
                string($passage/@n)
              }</a>{tr:content($passage)}</p>
            }</main>
          )
};
