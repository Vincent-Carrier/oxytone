for $path in file:list('lit/', true(), '*.xml')
let $urn := tokenize($path, '\.')
let $dbPath := string-join($urn[1 to 3], '/')
return db:put('lit', `lit/{$path}`, $dbPath, {
  'stripns': true()
})