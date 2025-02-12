import module namespace ref = 'ref' at '../repo/ref.xqm';

let $iliad := db:get('agldt', 'v2.1/tlg0012.tlg001.perseus-grc1.tb.xml')
return ref:get-book($iliad, 2)
