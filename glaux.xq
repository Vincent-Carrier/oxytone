let $f := file:read-text('glaux.tsv', 'utf-8', true())
let $index := csv:parse($f, {'header': true(), 'separator': 'tab', 'format': 'xquery'})
for $text in $index?records
    let $urn := $text?2 => tokenize('-')
    let $tlg := `tlg{$urn[1]}/tlg{$urn[2]}`
    let $author := $text?5
    let $title := $text?6
    let $_ := message(`{$tlg}, {$author}, {$title}, {$text?12}`)
    return store:put(`{$tlg}`, {
      'tlg': $tlg,
      'author': $author,
      'title': $title,
      'date': $text?3 cast as xs:integer,
      'genre': $text?7,
      'dialect': $text?8,
      'tokens': $text?12 cast as xs:integer
    }),

store:write('glaux')
