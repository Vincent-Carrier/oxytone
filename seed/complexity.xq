declare context item := doc('agldt/v2.1/tlg0020.tlg001.perseus-grc1.tb.xml');
for $sen in //sentence
  let $distances :=
    for $w in $sen//word[not(@relation = 'AuxK' or @relation = 'AuxX' or @artificial)]
    where $w/@head != "0"
    return abs(xs:integer($w/@id) - xs:integer($w/@head))
  let $dmm := avg($distances)
  return `{format-number($dmm, '0.00')} {$sen/word/@form}`
