let $_ := store:read('glaux')
for $k in store:keys()
  let $text := store:get($k)
  group by $genre := $text?genre
  for $t in $text
    where $t?tokens > 500
    return `{$genre}, {$t?date}, {$t?author}, {$t?title}`
