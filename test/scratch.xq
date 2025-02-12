import module namespace n = "normalize";

declare variable $tb := doc('./tb.xml');

declare function local:normalize($tb) {
  <treebank>
    <body>{
      for $sen in $tb/body/sentence
      return <sentence>{
        $sen/@*,
        (: compare @cite to see if we've reached a new verse :)
        for sliding window $win in $sen/word
          start $s at $i end $e at $j
          when $j - $i = 1
        let $refs := if ($s/@cite) then
          $win/@cite/string() =!> fn { tokenize(., ':') => foot() }()
        return (
          element w {
            $s/@*[name()=("id", "head", "lemma", "relation")],
            n:expand-postag($s/@postag/string()),
            concat(
              $s/@form/string(),
              if (characters($e/@postag/string())[1] != "u") then "&#x20;")
          },
          if (not(all-equal($refs))) then <br/>
        )
      }</sentence>
    }</body>
  </treebank>
};

local:normalize($tb) => replace(<br/>, '\n') -> .//text() => string-join()
