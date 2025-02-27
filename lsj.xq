for $path in file:list('lsj/', true(), '*.xml')
  let $doc := doc(`./lsj/{$path}`)
  for $entry in $doc//entryFree
    let $key := $entry/@key/string()
    let $w := tokenize($key, '\d+$')
    let $n := tokenize($key, '^\D+')
    let $dbPath := string-join(($w[1], if ($n != "") then foot($n)), '/')
    let $_ := message($dbPath)
    return db:put('lsj', $entry, $dbPath)
