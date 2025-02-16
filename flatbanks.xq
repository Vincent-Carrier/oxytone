import module namespace n = "normalize";
import module namespace ref = "ref";

declare variable $tbDir := "agldt/v2.1";

for $path in file:list($tbDir, true(), '*.xml')
let $urn := tokenize($path, '\.')
let $dbPath := string-join($urn[1 to 3], '/')
let $doc := doc(`{$tbDir}/{$path}`)
let $isVerse := n:is-verse($urn[1], $urn[2])
let $fb := n:normalize($doc, $isVerse)
return db:put('flatbanks', $fb, $dbPath)

(: split up homer into individual books :)
(: for $doc in db:get('flatbanks', 'tlg0012')
let $urn := tokenize($path, '\.')
where $urn[1] = "tlg0012" 
  for $n in 1 to 24
  let $dbPath := string-join(($urn[1 to 3], $n), '/')
  let $book := 
    <treebank>
      <body>
        {$doc/treebank/body/sentence[matches(@subdoc, `^{$n}\.`)]}
      </body>
    </treebank>
  let $_ := message($dbPath, "writing flatbank: ")
  return db:put('flatbanks', $fb, $dbPath) :)
