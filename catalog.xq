import module namespace urn = "urn";

for $authors in db:list('flatbanks')
  let $urn := urn:parse($authors)
  group by $author := $urn?author
  let $entry := element author {
    attribute id {$urn?author},
    attribute name {db:get("lit", $author)[1]//titleStmt/author},
    for $works in $authors
      group by $work := $urn?work
      let $tei := db:get("lit", `{$urn?author}/{$urn?work}`)[1]
      return element work {
        attribute id {$work},
        $tei//titleStmt/title
      }
  }
  return db:put('catalog', $entry, $author)
