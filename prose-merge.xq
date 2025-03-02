let $tb := db:get("flatbanks", "tlg0540/tlg001")[1]
let $tei := db:get("lit", "tlg0540/tlg001")[1]
for $p in $tei//body//p
  let $sentences :=
    for $sen in $tb//sentence
    where $p//text() contains text {$sen[.//*[not(@artificial)]/text()]} using fuzzy ordered distance at most 3 words
    return $sen
  return if ($sentences) then <p>{
    $sentences/@id/data()
  }</p>



(: for sliding window $win in $tb//sentence[1 to 10] => fold-left(fn { concat(.) })
  start $chunk at $i end $next at $j when $j - $i = 1


for $i in 1 to count($sentences)
  let $win := concat($sentences[position() <= $i])
  let $delta := string:levenshtein($win, $p)
  let $deltaPlus := string:levenshtein(concat($win, $sentences[$i+1]), $p)
  let $_ := message(`{$i}: {$delta} | {$deltaPlus} | {string-length($win)} | {string-length(concat($win, $sentences[$i+1]))} | {string-length($p)}`)
  where $delta > $deltaPlus
  return ($p, ' ||| ', $win) :)

(: let $merged := <treebank>
  <body>
    {
      for $el in $tei//body//*
      return typeswitch ($el) {
        case element(milestone)
          return then <hr />
        case element(p)
          return $tb//ln[@n=$el/@n]
        case element(q)
          return <blockquote>{
            for $ln in $el/l
            return $tb[@n=$ln/@n]
          }</blockquote>
        default return ()
      }
    }
  </body>
</treebank>
let $path := string-join(($urn[1 to 2], 'merged'), '/')
let $_ := message($path)
return db:put('flatbanks', $merged, $path) :)
