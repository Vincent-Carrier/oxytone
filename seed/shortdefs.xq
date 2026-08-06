(: Seeds the shared store with LSJ shortdefs (Greek lemma -> gloss string).
   This BaseX build keeps a single on-disk store (the store name is ignored, so
   'glaux' and 'lsj_shortdefs' resolve to the same file); seed/index.xq reads
   this store and appends the work metadata. Run shortdefs before index. :)
let $_ := store:clear()
let $f := file:read-text('seed/lsj-shortdefs.tsv', 'utf-8', true())
let $defs := csv:parse($f, {'header': true(), 'separator': 'tab', 'format': 'xquery'})
for $record in $defs?records
  let $key := $record?1
  let $def := $record?2
  (: Keyed the same way as seed/lsj.xq: a trailing homograph number becomes its own
     path segment, so the bare lemma is a prefix of all its entries. :)
  let $lemma := tokenize($key, '\d+$')
  let $homograph := tokenize($key, '^\D+')
  let $path := string-join(
    ($lemma[1], if ($homograph != "") then foot($homograph)), '/')
  let $_ := message($path)
  return store:put(`{$path}`, $def),

store:write('lsj_shortdefs')
