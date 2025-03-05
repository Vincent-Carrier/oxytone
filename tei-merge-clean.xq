for $path in db:list('flatbanks')
  let $urn := tokenize($path, '/')
  if ($urn[3] = 'merged') return db:delete('flatbanks', $path)
