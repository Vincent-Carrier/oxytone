import module namespace dbl = 'db-lazy';
import module namespace n = 'normalize';
import module namespace p = 'paginate';

let $doc := doc('glaux/tlg0016/tlg001/tb.xml')
let $page := p:xslt-filter($doc, 'sentence', `./word[1]/@div_book = 1`)
let $tb := n:normalize($page)
return $tb
