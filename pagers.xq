let $glaux := map:build(db:list('glaux'), value := fn { db:get('glaux', .) })
let $_ := store:read('glaux')
for key $path value $tb in $glaux
  where $tb[.//word/@div_book]
  let $urn := substring($path, 1, 14)
  let $meta := store:get($urn)
  let $books := distinct-values($tb//word/@div_book)
    =!> fn { if (. castable as xs:integer) then . cast as xs:integer else . }()
  let $range := if (every($books, fn { . castable as xs:integer })) then
    min($books) to max($books)
  let $list := if (deep-equal($range, $books))
    then `{min($range)} to {max($range)}` else `({string-join($books =!> fn { if (. instance of xs:integer) then . else `"{.}"`}(), ', ')})`
  where count($books) > 1
  where $meta?tokens > 3000
  return
`case '{$urn}' (: {$meta?author}, {$meta?title} :)
  return p:book-pager({$list})`
