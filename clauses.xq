let $tree := db:get("treebanks", "tlg0012/tlg001")//sentence[@id="2274106"]
let $seq := dbl:get-flatbank("tlg0012", "tlg001", "1")//w[@sentence="2274106"]
for $coord in $sen//coord
  let $_ := message('===')
  for $clause in $coord/*[@co]
    let $sorted := for $w in $clause//* order by $w/@id ascending return $w
    let $i := $sorted[1]/@id
    let $j := $sorted[last()]/@id
    let $full-clause := for $w in $sen//*[@id >= $i and @id <= $j] order by $w/@id return $w
    let $str := trace($full-clause/@form => string-join(' '))
    return ()
