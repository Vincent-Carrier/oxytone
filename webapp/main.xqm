module namespace ox = "oxytone";

import module namespace lsj = "lsj" at "../repo/lsj.xqm";
import module namespace ref = "ref" at "../repo/ref.xqm";

declare %rest:path("lsj/{$lemma}")
        %rest:GET
        %output:method("html")
        function ox:getDefinition($lemma) {
   let $entry := lsj:define($lemma)
   return xslt:transform($entry, "./lsj-entry.xslt")
};

declare %rest:path("read/iliad/{$book}")
        %rest:GET
        %output:method("html")
        function ox:getIliad($book) {
    let $iliad := db:get('agldt', 'v2.1/tlg0012.tlg001.perseus-grc1.tb.xml')
    let $body := ref:get-book($iliad, $book)
    return xslt:transform($body, "./tb.xslt")
};
