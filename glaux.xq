let $f := file:read-text('glaux.tsv', 'utf-8', true())
let $index := csv:parse($f, {'header': true(), 'separator': 'tab', 'format': 'xquery'})
for $text in $index?records
    let $urn := $text?2 => tokenize('-')
    let $path := `tlg{$urn[1]}/tlg{$urn[2]}`
    let $author := $text?5
    let $title := $text?6
    let $_ := message(($path, $author, $title))
    return store:put(`{$path}`, {'author': $author, 'title': $title}),

store:write('glaux')
