module namespace t = 'test';

import module namespace p = 'paginate';

declare variable $t:iliad := db:get('flatbanks', 'tlg0012/tlg001')[1];

declare %unit:test function t:get-book() {
  let $pager := p:pager('tlg0012', '001')
  let $book := $pager($t:iliad, 2)
  return unit:assert-equals($book//ln[1]/@n/string(), "2.1")
};
