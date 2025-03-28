import module namespace uf = "unflat";

let $tbDir := `agldt/v2.1`

for $path in file:list($tbDir, true(), '*.xml')
let $urn := tokenize($path, '\.')
let $dbPath := string-join($urn[1 to 3], '/')
let $doc := doc(`{$tbDir}/{$path}`)
let $tb := uf:unflat($doc)
return  db:put('treebanks', $tb, $dbPath)

