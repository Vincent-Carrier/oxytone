let $_ := store:read('glaux')
for $k in store:keys()
  let $text := store:get($k)
  group by $genre := $text?genre
  (: where $genre = 'Epic poetry' :)
  let $genre-map := map:build($text?tlg, value := fn { db:get('normalized', .) })
  for $w in $genre-map?*//w
    where $w/@pos = ('noun', 'verb', 'adv.')
    group by $lemma := $w/@lemma
    order by count($w) descending
    where count($w) > 50
      and not(matches($lemma, "^[\p{Lu}]"))
    return [$lemma, count($w), head($w/@pos)]


(: { epic: 101 } :)
