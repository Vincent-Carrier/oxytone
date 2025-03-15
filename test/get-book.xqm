module namespace t = 'test';

import module namespace dbl = 'db-lazy';
import module namespace n = 'normalize';

declare %unit:test function t:get-tb() {
  let $tb := dbl:get-flatbank('tlg0540', 'tlg001')
  return unit:assert($tb//w)
};

declare %unit:test function t:normalize-tb() {
  let $doc := doc('../treebanks/agldt/v2.1/tlg0540.tlg001.perseus-grc1.tb.xml')
  let $tb := n:normalize($doc)
  return unit:assert($tb//w)
};
