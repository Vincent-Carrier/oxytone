import module namespace n = 'normalize';
import module namespace p = 'pager';

let $_ := store:read('glaux')
let $index := map:build(store:keys, value := fn { store:get(.) })
for key $tlg value $meta in $index
  where $meta?genre = 'Epic poetry'
  let urn := tokenize($tlg, '/')
  let $pager := p:pager($tlg)
  if ($pager)
  let $_ := n:get-normalized($urn[1], $urn[2])
