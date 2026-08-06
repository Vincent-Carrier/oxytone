(: Computes three syntactic-complexity measures over a genre-spanning sample of
   the treebank, and writes them as TSV for analysis outside BaseX.

   The measures come from the dependency-treebank complexity literature:

     MDD  mean dependency distance — mean |pos(head) - pos(dependent)|, a proxy
          for working-memory load during incremental parsing.
     MHD  mean hierarchical distance — mean depth from the root, capturing
          embedding rather than linear span. The two dissociate: coordinate
          parataxis is flat but can be linearly scrambled, and a deeply
          subordinated sentence can keep every head adjacent to its dependent.
     crossings  pairs of dependencies that interleave — the treebank signature of
          discontinuous constituency, which in Greek is hyperbaton.

   Every measure is emitted twice, once over all edges and once over content
   edges only (suffix _c). Greek makes this necessary rather than optional:
   second-position particles sit in Wackernagel position and articles cling to
   their nouns, so both generate large numbers of edges that say more about the
   language's clitic inventory than about the sentence. Measured on Thucydides,
   dropping them halves the crossing count (6.41 -> 2.67 per sentence) while
   leaving the ranking between authors intact — so the raw figure overstates
   discontinuity but does not invent it. Reporting both keeps that visible
   instead of burying it in whichever variant we happened to pick.

   Manual annotation only. GLAUx is mostly machine-parsed, and parser error is
   systematic rather than random, so mixing modes would make a cross-author
   comparison partly a comparison of how well the parser handled each author.
   That costs some works entirely (Plato's Republic has no manual sentences) in
   exchange for numbers that mean what they claim to.

   Analysis output, not a seeding step — not part of `just seed`. Run with
   `just complexity`. :)
import module namespace urn = "urn";

declare namespace cx = "complexity";

declare variable $cx:out := 'out';

(: Sentences sampled per work. Works with fewer manual sentences contribute all
   of them. :)
declare variable $cx:sample-size := 400;

(: Hand-picked for genre spread, and filtered to works with enough manually
   annotated sentences to be worth sampling. Ordered by genre so the per-work TSV
   reads as a table rather than needing a sort. :)
declare variable $cx:works := (
  'tlg0012/tlg001', 'tlg0012/tlg002', 'tlg0020/tlg001', 'tlg0020/tlg002',
  'tlg0011/tlg004', 'tlg0011/tlg002', 'tlg0085/tlg005', 'tlg0085/tlg003',
  'tlg0006/tlg003',
  'tlg0019/tlg001', 'tlg0019/tlg008',
  'tlg0016/tlg001', 'tlg0003/tlg001', 'tlg0543/tlg001', 'tlg0032/tlg001',
  'tlg4029/tlg001',
  'tlg0026/tlg001', 'tlg0028/tlg005', 'tlg0014/tlg059',
  'tlg0059/tlg002', 'tlg0059/tlg001', 'tlg0086/tlg035', 'tlg0032/tlg002',
  'tlg0554/tlg001', 'tlg0031/tlg003', 'tlg0031/tlg004', 'tlg0096/tlg002b',
  'tlg0058/tlg001', 'tlg0559/tlg002'
);

(: Punctuation and the article are identified by the first character of the
   9-character AGLDT postag ('u' and 'l'); the Aux* relations are the annotation
   scheme's own category for particles and other material attached for
   bookkeeping rather than syntax. :)
declare variable $cx:function-relations := ('AuxY', 'AuxZ', 'AuxK', 'AuxX', 'AuxG');

declare function cx:content($edges as map(*)*) as map(*)* {
  $edges[not(?rel = $cx:function-relations)
         and not(starts-with(?pt, 'u'))
         and not(starts-with(?pt, 'l'))]
};

(: Every edge as {d: dependent position, h: head position, rel, pt}.

   Positions are 1-based indices in *document* order over non-artificial words.
   Sorting by @id would be wrong: elliptical nodes are numbered from a separate
   counter and carry 10-digit ids, so they sort after every real word in the
   sentence regardless of where they belong. They are dropped here anyway — they
   have no surface position, so no linear distance to measure — but their
   presence still rules out @id as an ordering key.

   Words whose head does not resolve are roots (or, for punctuation, stubs with
   head="0"); they contribute a node but no edge. :)
declare function cx:edges($ws as element(word)*) as map(*)* {
  let $pos := map:merge(for $w at $i in $ws return map:entry(string($w/@id), $i))
  for $w at $i in $ws
    let $h := $pos(string($w/@head))
    where exists($h)
    return { 'd': $i, 'h': $h, 'rel': string($w/@relation), 'pt': string($w/@postag) }
};

(: Pairs of edges that strictly interleave: a1 < b1 < a2 < b2. Touching
   endpoints do not count — two edges sharing a node are nested, not crossing. :)
declare function cx:crossings($edges as map(*)*) as xs:integer {
  let $spans := for $e in $edges
    return { 'lo': min(($e?d, $e?h)), 'hi': max(($e?d, $e?h)) }
  return count(
    for $a at $i in $spans
    for $b at $j in $spans
      where $j > $i
        and (($a?lo < $b?lo and $b?lo < $a?hi and $a?hi < $b?hi)
          or ($b?lo < $a?lo and $a?lo < $b?hi and $b?hi < $a?hi))
      return 1
  )
};

(: Depth of each word, walking up @head to a node that has none.

   The visited set makes a cycle terminate rather than loop forever. Manual
   annotation should not contain any, but a silent hang on one bad sentence would
   be far worse to diagnose than a counter, so cycles are counted and reported.
   A word on a cycle yields the empty sequence and is excluded from the mean. :)
declare function cx:depth($id as xs:string, $heads as map(*)) as xs:integer? {
  let $walk := function($walk, $cur as xs:string, $seen as xs:string*) as xs:integer? {
    let $h := $heads($cur)
    return
      if (empty($h)) then 0
      else if ($h = $seen) then ()
      else
        let $up := $walk($walk, $h, ($seen, $cur))
        return if (empty($up)) then () else $up + 1
  }
  return $walk($walk, $id, ())
};

declare function cx:stats($sen as element(sentence)) as map(*)? {
  let $all := $sen/word
  let $ws := $all[not(@artificial)]
  let $n := count($ws)
  (: Below three words there is no tree worth measuring — and no pair of edges
     that could cross. :)
  where $n >= 3
  let $ids := map:merge(for $w in $ws return map:entry(string($w/@id), true()))
  (: Restricted to ids present in $ws, so an edge into a dropped artificial node
     reads as absent (making its dependent a root) rather than dangling. :)
  let $heads := map:merge(
    for $w in $ws
      let $h := string($w/@head)
      where $ids($h)
      return map:entry(string($w/@id), $h)
  )
  let $edges := cx:edges($ws)
  let $content := cx:content($edges)
  let $depths := for $w in $ws return cx:depth(string($w/@id), $heads)
  let $crossings := cx:crossings($edges)
  let $crossings-c := cx:crossings($content)
  return {
    'id': string($sen/@id),
    'n': $n,
    'artificial': count($all) - $n,
    'mdd': avg(for $e in $edges return abs($e?d - $e?h)),
    'mdd_c': avg(for $e in $content return abs($e?d - $e?h)),
    'mhd': avg($depths),
    'max_depth': (max($depths), 0)[1],
    'crossings': $crossings,
    'crossings_c': $crossings-c,
    (: Punctuation also carries head="0", so counting bare roots would report a
       stub per clause; a real root is a non-punctuation word with no head. :)
    'roots': count($ws[not(starts-with(@postag, 'u')) and not($heads(string(@id)))]),
    'cyclic': count($ws) - count($depths)
  }
};

declare function cx:round($v as xs:double?) as xs:string {
  if (empty($v)) then '' else string(round($v * 1000) div 1000)
};

declare function cx:row($vs as item()*) as xs:string {
  string-join(for $v in $vs return string($v), '&#9;')
};

let $_ := file:create-dir($cx:out)
let $_ := store:read('glaux')

let $per-work :=
  for $urn in $cx:works
    let $meta := store:get($urn)
    let $doc := db:get('glaux', $urn || '/')[1]
    let $manual := $doc//sentence[@analysis = 'manual']
    let $total := count($manual)
    (: Even stride across the whole work. Taking the first N instead would sample
       Thucydides' archaeology and Homer's proem — openings are not
       representative of the prose that follows. :)
    let $stride := max((1, $total idiv $cx:sample-size))
    (: mod $stride = 0 rather than = 1, because at stride 1 — any work with fewer
       manual sentences than the sample size — every position is congruent to 0
       and none to 1, which would silently select nothing. :)
    let $sample := $manual[position() mod $stride = 0][position() <= $cx:sample-size]
    let $stats := for $s in $sample return cx:stats($s)
    let $author := ($meta?'english-author', '?')[1]
    let $title := ($meta?'english-title', '?')[1]
    let $genre := ($meta?genre, '?')[1]
    let $_ := message(`{$urn} {$author} — {$title}: {count($stats)}/{$total} manual sentences`)
    return {
      'urn': $urn, 'author': $author, 'title': $title, 'genre': $genre,
      'tokens': ($meta?tokens, 0)[1], 'manual_total': $total, 'stats': $stats
    }

let $sentence-rows := (
  cx:row(('urn', 'author', 'title', 'genre', 'sent_id', 'n_words', 'n_artificial',
          'mdd', 'mdd_c', 'mhd', 'max_depth', 'crossings', 'crossings_c',
          'n_roots', 'cyclic')),
  for $w in $per-work
    for $s in $w?stats
      return cx:row(($w?urn, $w?author, $w?title, $w?genre, $s?id, $s?n, $s?artificial,
                     cx:round($s?mdd), cx:round($s?mdd_c), cx:round($s?mhd),
                     $s?max_depth, $s?crossings, $s?crossings_c, $s?roots, $s?cyclic))
)

let $work-rows := (
  cx:row(('urn', 'author', 'title', 'genre', 'tokens', 'manual_total', 'n_sentences',
          'mean_len', 'mdd', 'mdd_c', 'mhd', 'max_depth', 'crossings', 'crossings_c',
          'pct_nonproj', 'pct_nonproj_c', 'cyclic')),
  for $w in $per-work
    let $s := $w?stats
    let $n := count($s)
    where $n > 0
    return cx:row(($w?urn, $w?author, $w?title, $w?genre, $w?tokens, $w?manual_total, $n,
                   cx:round(avg($s?n)),
                   cx:round(avg($s?mdd)), cx:round(avg($s?mdd_c)),
                   cx:round(avg($s?mhd)), cx:round(avg($s?max_depth)),
                   cx:round(avg($s?crossings)), cx:round(avg($s?crossings_c)),
                   cx:round(count($s[?crossings > 0]) div $n * 100),
                   cx:round(count($s[?crossings_c > 0]) div $n * 100),
                   sum($s?cyclic)))
)

return (
  file:write-text-lines(`{$cx:out}/complexity-sentences.tsv`, $sentence-rows),
  file:write-text-lines(`{$cx:out}/complexity-works.tsv`, $work-rows),
  message(`wrote {count($sentence-rows) - 1} sentence rows, {count($work-rows) - 1} work rows`)
)
