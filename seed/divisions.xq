(: Precomputes the page division for works that need automatic pagination, and
   appends it to the shared store next to the work metadata.

   p:auto-pager used to work this out per request by opening the glaux document
   and scanning //word for each candidate attribute. The index calls p:pager for
   every one of ~1400 works, so that scan ran on every visit to the home page and
   made it unusable. Deciding it once here keeps p:pager a map lookup.

   Run after seed/index.xq, which writes the metadata this reads and extends. :)
import module namespace urn = "urn";

let $_ := store:read('glaux')

(: Structural units only — the divisions a work is actually composed of.
   Deliberately excludes edition page numbers (Stephanus, Bekker, Jebb, Reiske,
   olpage, manuscript pages) and Perseus' section ids. Those are coordinates into
   a printed edition, not parts of the text: a Stephanus page is a spot in
   Estienne's 1578 folio, and paginating the Gorgias on it produced 81 pages of
   roughly a paragraph each, against ~10,000 tokens for a book of the Republic.
   A work with no structural division is better read whole than sliced at
   arbitrary marks.

   div_section and div_fragment are out for the same reason — they are citation
   coordinates, and Demosthenes' On the Crown came out as 324 pages of 81 tokens,
   a sentence or two apiece. div_chapter stays: a chapter of Genesis is a unit
   people actually read. :)
let $divisions := (
  'div_book', 'div_oration', 'div_fable', 'div_fabula', 'div_homily', 'div_psalm',
  'div_chapter', 'div_letter', 'div_poem', 'div_epigram', 'div_speech',
  'div_declamation', 'div_life', 'div_essay'
)

for $path in db:list('glaux')
  let $urn := urn:work($path)
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
  (: Emitted even when nothing matches, so that a work which used to paginate on
     a division since removed from the list gets its stale entry cleared rather
     than keeping it forever. :)
  let $vals := if (exists($div))
    then distinct-values($tb/treebank//word/@*[name() = $div])
    else ()
  (: Natural sort. Page labels are mostly numbers, but many texts mix in a
     suffixed variant (100b, 1252a, 17/18) or a leading preface (praef, pr).
     Sorting on the leading integer keeps 100b next to 100 rather than beside
     10, and labels with no number at all sort first, which is where a preface
     belongs. Testing every value for castability instead meant one "100b"
     dropped the whole work back to string order: 1, 10, 100, 100b, 101. :)
  let $sorted := sort($vals, (), fn($v) {
    let $num := replace($v, '^(\d*).*$', '$1')
    return ((if ($num = '') then -1 else xs:integer($num)), string($v))
  })
  let $_ := if (exists($div))
    then message(`{$urn} {$div} ({count($sorted)} pages)`)
    else ()
  (: use-last so re-running overwrites a previously stored division; the default
     keeps the first value, which made this script a no-op on any second run. :)
  return store:put($urn,
    if (exists($div))
    then map:merge(($meta, { 'division': $div, 'pages': array { $sorted } }),
                   { 'duplicates': 'use-last' })
    else map:remove($meta, ('division', 'pages'))),

store:write('glaux')
