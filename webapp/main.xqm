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

declare %rest:path("read/{$urn=.+}")
        %rest:GET
        %output:method("html")
        function ox:getTb($urn) {
    let $body:= db:get('flatbanks', $urn)
    (: return $body :)
    return xslt:transform($body, "tb.xslt")
};
