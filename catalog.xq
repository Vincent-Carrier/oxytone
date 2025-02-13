for $path in db:list('lit')
let $urn := tokenize($path, '/')
group by $author := $urn[1]
let $work := $urn[2]
let $entry := element author {
  attribute id {$author},
  attribute name {db:get("lit", $author)[1]/TEI/teiHeader/fileDesc/titleStmt/author[1]/text()},
  
  for $p in $path
  return element work {
    attribute id {$work},
    attribute edition {$urn[3]},
    attribute path {$p},
    db:get("lit", $p)/TEI/teiHeader/fileDesc/titleStmt/title,
    for $tb in db:list("flatbanks", $author)
    return element tb {
      attribute path {$tb}
    }
  }
}
return db:put('catalog', $entry, $author)
