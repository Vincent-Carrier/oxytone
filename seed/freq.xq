let $_ := store:read('glaux')
for $k in store:keys()
  let $text := store:get($k)
  group by $genre := $text?genre
  where $genre = 'Epic poetry'
  let $genre-map := map:build($text?tlg, value := fn { db:get('glaux', .) })
  for $w in $genre-map?*//word
    group by $lemma := $w/@lemma
    order by count($w) descending
    where count($w) > 100
    return ($lemma, count($w))
