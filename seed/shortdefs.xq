(: Seeds the shared store with LSJ shortdefs (Greek lemma -> gloss string).
   This BaseX build keeps a single on-disk store (the store name is ignored, so
   'glaux' and 'lsj_shortdefs' resolve to the same file); seed/index.xq reads
   this store and appends the work metadata. Run shortdefs before index. :)
let $_ := store:clear()
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
