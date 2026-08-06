(: Appends work metadata (keyed by tlg path) to the shared store, on top of the
   LSJ shortdefs written by seed/shortdefs.xq. This BaseX build keeps a single
   on-disk store, so we read the existing contents first rather than clearing,
   then write everything back. Metadata keys (tlg...) and shortdef keys (Greek
   lemmas) never collide. Run shortdefs before index. :)
let $_ := store:read('lsj_shortdefs')
let $f := file:read-text('seed/glaux.tsv', 'utf-8', true())
let $index := csv:parse($f, {'header': true(), 'separator': 'tab', 'format': 'xquery'})
(: Columns are read positionally; glaux.tsv's header names them. :)
for $text in $index?records
    (: The TSV writes the URN as "0012-001"; the store keys it as "tlg0012/tlg001". :)
    let $urn := $text?2 => tokenize('-')
    let $tlg := `tlg{$urn[1]}/tlg{$urn[2]}`
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
