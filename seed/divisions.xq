(: Precomputes the page division for works that need automatic pagination, and
   appends it to the shared store next to the work metadata.

   p:auto-pager used to work this out per request by opening the glaux document
   and scanning //word for each candidate attribute. The index calls p:pager for
   every one of ~1400 works, so that scan ran on every visit to the home page and
   made it unusable. Deciding it once here keeps p:pager a map lookup.

   Run after seed/index.xq, which writes the metadata this reads and extends. :)
let $_ := store:read('glaux')

(: Best first: structural units before editorial page numbers, which are only a
   sensible page boundary when a text carries no structure of its own. :)
let $divisions := (
  'div_book', 'div_oration', 'div_fable', 'div_fabula', 'div_homily', 'div_psalm',
  'div_chapter', 'div_letter', 'div_poem', 'div_epigram', 'div_speech',
  'div_declamation', 'div_life', 'div_essay', 'div_fragment', 'div_section',
  'div_stephanus_page', 'div_bekker_page', 'div_jebb_page', 'div_page',
  'div_olpage', 'div_reiskpage', 'div_perseus_section', 'div_manuscriptpage'
)

for $path in db:list('glaux')
  let $urn := string-join(tokenize($path, '/')[position() le 2], '/')
  let $meta := store:get($urn)
  (: Only works long enough that a single page is unreadable. :)
  where $meta?tokens > 25000
  let $tb := db:get('glaux', $path)
  let $div := head(
    for $d in $divisions
      let $vals := distinct-values($tb/treebank//word/@*[name() = $d])
      where count($vals) > 1 and count($vals) <= 600
      return $d
  )
  where exists($div)
  let $vals := distinct-values($tb/treebank//word/@*[name() = $div])
  (: Natural sort. Page labels are mostly numbers, but many texts mix in a
     suffixed variant (100b, 1252a, 17/18) or a leading preface (praef, pr).
     Sorting on the leading integer keeps 100b next to 100 rather than beside
     10, and labels with no number at all sort first, which is where a preface
     belongs. Testing every value for castability instead meant one "100b"
     dropped the whole work back to string order: 1, 10, 100, 100b, 101. :)
  let $sorted :=
    for $v in $vals
      let $num := replace($v, '^(\d*).*$', '$1')
      order by
        (if ($num = '') then -1 else xs:integer($num)),
        $v
      return $v
  let $_ := message(`{$urn} {$div} ({count($sorted)} pages)`)
  (: use-last so re-running overwrites a previously stored division; the default
     keeps the first value, which made this script a no-op on any second run. :)
  return store:put($urn, map:merge((
    $meta,
    { 'division': $div, 'pages': array { $sorted } }
  ), { 'duplicates': 'use-last' })),

store:write('glaux')
