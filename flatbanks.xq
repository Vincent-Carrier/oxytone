import module namespace n = "normalize";
import module namespace ref = "ref";

declare variable $tbDir := "agldt/v2.1";

for $path in file:list($tbDir, true(), '*.xml')
let $urn := tokenize($path, '\.')
let $dbPath := string-join($urn[1 to 3], '/')
let $doc := doc(`{$tbDir}/{$path}`)
let $isVerse := n:is-verse($urn[1], $urn[2])
let $fb := n:normalize($doc, $isVerse)
let $_ := trace((), `{$dbPath}, {count($fb//*)}`)
return db:put('flatbanks', $fb, $dbPath)
