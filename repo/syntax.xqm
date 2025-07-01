module namespace syn = "syntax";
import module namespace pt = "postag";
import module namespace meta = "meta";

declare function syn:node ($nodes, $id, $head, $attrs){
  let $rel := $attrs/../@relation => data() => lower-case() => tokenize('_')
  let $el := if ($rel[1] != "") then $rel[1] else "unknown"
  return element w {
    if ($rel[1]) then attribute rel {$rel[1]},
    if ($rel[2]) then $rel => slice(2) =!> fn { attribute {.} {} }(),
    $attrs[name()=("id", "form", "lemma")],
    pt:expand($attrs[name()="postag"]),
    for $n in $nodes/../*[@head=$id]
    return syn:node($n, $n/@id, $n/@head, $n/@*[not(name()=("head"))])
  }
};

declare function syn:unflat($tb, $meta) {
  <treebank>
    {meta:head($meta)}
    <body>{
      for $s in $tb//sentence
      return <sentence>{
        $s/@* ,
        for $w in $s/word
        let $attrs := $w/@*[not(name()=("head"))]
        return if ($w/@head="0") then syn:node($w, $w/@id , $w/@head, $attrs)
      }</sentence>
    }</body>
  </treebank>
};
