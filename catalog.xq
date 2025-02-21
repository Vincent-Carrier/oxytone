for $path in db:list('lit')
let $urn := tokenize($path, '/')
group by $author := $urn[1]
let $entry := element author {
  attribute id {$author},
  attribute name {db:get("lit", $author)[1]/TEI/teiHeader/fileDesc/titleStmt/author[1]/text()},
  for $p in $path
  let $urn := tokenize($p, '/')
  return element work {
    attribute id {$urn[2]},
    attribute edition {$urn[3]},
    db:get("lit", $p)/TEI/teiHeader/fileDesc/titleStmt/title,
    for $tb in db:list("flatbanks", `{$urn[1]}/{$urn[2]}`)
    return <tb type="agldt" path="{$tb}" />
  }
}
return db:put('catalog', $entry, $author)
