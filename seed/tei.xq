for $path in file:list('tei/', true(), '*.xml')
let $urn := tokenize($path, '\.')
where db:list('flatbanks', string-join($urn[1 to 2], '/'))[1]
let $dbPath := string-join($urn[1 to 3], '/')
let $_ := message($dbPath)
return db:put('tei', `tei/{$path}`, $dbPath, {
  'stripns': true()
})
