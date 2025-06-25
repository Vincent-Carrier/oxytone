import module namespace n = 'normalize';

for $path in db:list('glaux')
  let $urn := tokenize($path, '/')
  let $doc := n:get-normalized($urn[1], $urn[2])
  let $_ := trace(`{$urn[1]}/{$urn[2]}`)
  let $_ := db:put('normalized', $doc, `{$urn[1]}/{$urn[2]}`)
  return ()
