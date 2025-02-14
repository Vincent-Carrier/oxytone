import module namespace ref = 'ref';

let $doc := db:get('flatbanks', 'tlg0012/tlg001/perseus-grc1')
return ref:get-book($doc, 1)