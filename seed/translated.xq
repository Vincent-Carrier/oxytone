(: Records which works have an English translation, next to the work metadata.

   The frontend needs this per work to decide whether to offer the link, and
   asking the translations DB per request would mean a lookup for every work on
   the index page. Most works have none — 128 of the 180 that paginate — so the
   absence is the common answer and worth having cheaply.

   Runs after seed/index.xq, which writes the metadata this extends. :)
import module namespace urn = "urn";

let $_ := store:read('glaux')

(: Empty when `just translations` was never run, which leaves every work without
   the key and the link correctly hidden everywhere. :)
let $translated := distinct-values(
  for $path in db:list('translations')
  return urn:work($path)
)

(: Every work is visited, not just the translated ones, so dropping a translation
   and re-seeding clears the key rather than leaving the link pointing at a
   passage that no longer resolves. :)
for $path in db:list('glaux')
  let $tlg := urn:work($path)
  let $meta := store:get($tlg)
  where exists($meta)
  let $has := $tlg = $translated
  let $_ := if ($has) then message($tlg) else ()
  (: use-last so re-running overwrites rather than no-ops, as in divisions.xq. :)
  return store:put($tlg,
    if ($has)
    then map:merge(($meta, { 'translated': true() }), { 'duplicates': 'use-last' })
    else map:remove($meta, 'translated')),

store:write('glaux')
