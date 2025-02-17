module namespace t = 'test';

import module namespace ref = 'ref';
import module namespace n = 'normalize';

declare %unit:test function t:getIliad() {
  let $doc := db:get('flatbanks', 'tlg0012/tlg001')[1]
  return unit:assert-equals($doc//ln[1]/@n, "1.1")
};

declare %unit:test function t:normalize() {
  let $doc := doc('./tb.xml') => n:normalize(true())
  return unit:assert-equals($doc//w[1]/@lemma/string(), "μῆνις")
};

declare %unit:test function t:getBook() {
  let $doc := db:get('flatbanks', 'tlg0012/tlg001')[1]
  let $b1 := ref:get-book($doc, 2)
  return unit:assert-equals($b1//ln[1]/@n, "2.1")
};
