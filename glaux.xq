let $f := file:read-text('glaux-merged.tsv', 'utf-8', true())
let $index := csv:parse($f, {'header': true(), 'separator': 'tab', 'format': 'xquery'})
for $text in $index?records
    let $urn := $text?2 => tokenize('-')
    let $tlg := `tlg{$urn[1]}/tlg{$urn[2]}`
    let $author := $text?5
    let $title := $text?6
    let $_ := message(`{$tlg}, {$text?14}, {$text?15}`)
    return store:put(`{$tlg}`, {
      'tlg': $tlg,
      'author': $text?5,
      'title': $text?6,
      'date': $text?3 cast as xs:integer,
      'genre': $text?7,
      'dialect': $text?8,
      'tokens': $text?12 cast as xs:integer,
      'english-author': $text?14,
      'english-title': $text?15
    }),

store:write('glaux')
