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
  let $sorted :=
    if (every($vals, fn { . castable as xs:integer }))
    then for $v in $vals order by xs:integer($v) return $v
    else for $v in $vals order by $v return $v
  let $_ := message(`{$urn} {$div} ({count($sorted)} pages)`)
  return store:put($urn, map:merge((
    $meta,
    { 'division': $div, 'pages': array { $sorted } }
  ))),

store:write('glaux')
