module namespace n = "normalize";
import module namespace pt = "postag";

declare function n:is-verse($author, $work) {
  switch($author)
    case ('tlg0011', 'tlg0012', 'tlg0013', 'tlg0020', 'tlg0085') return true()
    default return false()
};

declare function n:normalize-verse($tb) as element()* {
  for tumbling window $line in $tb//word[not(@artificial)]
    start $s end $e previous $p next $n
    when $s/@cite != $n/@cite and $n/@cite != ""
  let $ref := tokenize($s/@cite, ':') => foot()
  return
    <ln n="{$ref}" xml:space="preserve">
      {
        for sliding window $win in $line
          start $w at $i end $n at $j
          when $j - $i = 1
        let $morph := pt:expand($w/@postag)
        return element w {
          attribute sentence {$w/../@id},
          $w/@*[name()=("id", "head", "lemma", "relation")],
          $morph,
          concat(
            $w/@form/string(),
            (: insert space if not followed by punctuation :)
            if (characters($n/@postag)[1] != "u") then "&#x20;"
          )
        }
      }
    </ln>
};

declare function n:normalize-prose($tb) as element()* {
  for $sen in $tb//sentence
  return <sentence xml:space="preserve">{
    attribute id {$sen/@id otherwise $sen/@struct_id},
    $sen/@* except $sen/@id,
    for sliding window $win in $sen/word[not(@artificial)]
      start $s at $i end $e at $j
      when $j - $i = 1
      return (
        element w {
          $s/@*[name()=("id", "head", "relation")],
          attribute sentence {$sen/@id otherwise $sen/@struct_id},
          attribute lemma {normalize-unicode($s/@lemma, 'NFC')},
          pt:expand($s/@postag),
          concat(
            $s/@form,
            (: insert space if not followed by punctuation :)
            if (characters($e/@postag)[1] != "u") then "&#x20;")
        }
      )
  }</sentence>
};

declare function n:normalize($tb, $verse := false()) as element() {
  <treebank type="{if ($verse) then 'verse' else 'prose'}">
    <body>{
      if ($verse) {n:normalize-verse($tb)}
      else {n:normalize-prose($tb)}
    }</body>
  </treebank>
};
