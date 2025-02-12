module namespace uf = "unflat";
import module namespace n = "normalize";

declare function uf:make-node ($nodes, $id, $head, $attrs){
  let $rel := $attrs/../@relation => data() => lower-case()
  let $el := if ($rel) then $rel else "w"
  return element {$el} {
    ($attrs[name()=("form", "lemma")], n:expand-postag($attrs[name()="postag"])),
    for $n in $nodes/../*[@head=$id]
    return uf:make-node($n, $n/@id, $n/@head, $n/@*[not(name()=("id", "head"))])
  }
};

declare function uf:unflat($tb) {
  <treebank>
    <body>{
      for $s in $tb//sentence
      return <sentence>{
        $s/@* ,
        for $w in $s/word
        let $attrs := $w/@*[not(name()=("id", "head"))]
        return if ($w/@head="0") then uf:make-node($w, $w/@id , $w/@head, $attrs)
      }</sentence>
    }</body>
  </treebank>  
};

