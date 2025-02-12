for $path in db:list('lit')
let $urn := tokenize($path, '\.')
return db:put('catalog', element author {
  attribute id {$urn[1]},
  element work {
    attribute id {$urn[2]},
    attribute edition {$urn[3]},
    attribute path {$path},
    for $tb in db:list("flatbanks", $urn[1])
    return element tb {
      attribute path {$tb}
    }
  }
  }, $urn[1])
