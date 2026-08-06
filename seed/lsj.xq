(: Loads the LSJ entries into the `lsj` database, one document per entry.

   Homographs are keyed with a trailing number (λόγος1, λόγος2), which is split off
   into a path segment: "λόγος/1". The lemma is then a path *prefix*, so
   def:definition-html can pick up every homograph with one db:list. :)
for $path in file:list('lsj/', true(), '*.xml')
  let $doc := doc(`../lsj/{$path}`)
  for $entry in $doc//entryFree
    let $key := $entry/@key/string()
    let $lemma := tokenize($key, '\d+$')
    let $homograph := tokenize($key, '^\D+')
    let $dbPath := string-join(
      ($lemma[1], if ($homograph != "") then foot($homograph)), '/')
    let $_ := message($dbPath)
    return db:put('lsj', $entry, $dbPath)
