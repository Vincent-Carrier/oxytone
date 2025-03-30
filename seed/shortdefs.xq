let $f := file:read-text('seed/lsj-shortdefs.tsv', 'utf-8', true())
let $defs := csv:parse($f, {'header': true(), 'separator': 'tab', 'format': 'xquery'})
for $w in $defs?records
  let $lemma := $w?1
  let $def := $w?2
  let $w := tokenize($lemma, '\d+$')
  let $n := tokenize($lemma, '^\D+')
  let $path := string-join(($w[1], if ($n != "") then foot($n)), '/')
  let $_ := message($path)
  return store:put(`{$path}`, $def),

store:write('lsj_shortdefs')
