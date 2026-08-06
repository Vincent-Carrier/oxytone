(: Appends Wiktionary glosses (key 'wikt/<lemma>') to the shared store, on top of
   the LSJ shortdefs written by seed/shortdefs.xq.

   This BaseX build keeps a single on-disk store (the store name is ignored), so
   the 'wikt/' prefix is load-bearing: it keeps this keyspace disjoint from the bare
   Greek lemma keys (LSJ shortdefs) and the tlg keys (work metadata added by
   seed/index.xq). Without it these writes would overwrite the shortdefs outright.

   Run after shortdefs (which clears the store) and before index (which writes it
   out as 'glaux'). :)
let $_ := store:read('lsj_shortdefs')
let $f := file:read-text('seed/wiktionary-defs.tsv', 'utf-8', true())
let $defs := csv:parse($f, {'header': true(), 'separator': 'tab', 'format': 'xquery'})
(: Group by lemma up front: a lemma can hold several parts of speech (623 do),
   and a per-lemma filter over ~21k records would be quadratic. :)
let $bylemma := map:build($defs?records, key := fn { ?1 })
for $lemma in map:keys($bylemma)
  let $rows := $bylemma($lemma)
  return store:put(`wikt/{$lemma}`, array {
    for $r in $rows return { 'pos': $r?2, 'def': $r?3 }
  }),

store:write('lsj_shortdefs')
