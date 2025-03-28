import module namespace syn = "syntax";

let $glaux := map:build(db:list('glaux'), value := fn { db:get('glaux', .) })
for key $path value $tb in $glaux
  where $tb//[@analysis="manual"]
  let $syn := syn:unflat($tb)
  return  db:put('syntax', $syn, $path)
