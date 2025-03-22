module namespace n = "normalize";
import module namespace pt = "postag";

declare function n:style($author, $work) {
  let $_ := store:read('glaux')
  let $meta := store:get(`{$author}/{$work}`)
  return switch ($meta?genre)
    case ("Tragedy", "Epic poetry", "Lyric poetry", "Comedy") return "verse"
    case ("Philosophic Dialogue") return "dialogue"
    default return "prose"
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
          start $w at $i end $e at $j
          when $j - $i = 1
          return n:make-word($w, not(n:is-punct-right($e)))
      }
    </ln>
};

declare function n:normalize-prose($tb) as element()* {
  for $sen in $tb//sentence
  return <sentence xml:space="preserve">{
    attribute id {$sen/@id otherwise $sen/@struct_id},
    $sen/@* except $sen/@id,
    for sliding window $win in $sen/word[not(@artificial)]
      start $w at $i end $e at $j
      when $j - $i = 1
      return n:make-word($w, not(n:is-punct-right($e)))
  }</sentence>
};

declare function n:normalize-dialogue($tb) as element()* {
  for tumbling window $speech in $tb//sentence
    start $s next $n
    when $s/word[1]/@speaker != $n/word[1]/@speaker
    return (
      trace(<speaker>{$s/word[1]/@speaker/string()}</speaker>, "SPEAKER: "),
      for $sen in $speech
        return <sentence xml:space="preserve">{
          attribute id {$sen/@id otherwise $sen/@struct_id},
          $sen/@* except $sen/@id,
          for sliding window $win in $sen/word[not(@artificial)]
            start $w at $i end $e at $j
            when $j - $i = 1
            return n:make-word($w, not(n:is-punct-right($e)))
        }</sentence>
    )
};

declare function n:normalize($tb, $style := "prose") as element() {
  <treebank style="{$style}">
    <body>{
      switch ($style)
        case "verse" return n:normalize-verse($tb)
        case "dialogue" return n:normalize-dialogue($tb)
        default return n:normalize-prose($tb)
    }</body>
  </treebank>
};

declare function n:make-word($w, $pad-right) {
  element w {
    $w/@*[name()=("id", "head", "relation")],
    attribute sentence {$w/../@id otherwise $w/../@struct_id},
    attribute lemma {normalize-unicode($w/@lemma, 'NFC')},
    if ($w/@postag) then pt:expand($w/@postag),
    concat($w/@form, if ($pad-right) then "&#x20;")
  }
};

declare function n:is-punct-right($w) {
  characters($w/@postag)[1] = "u"
  and $w/@form != ("[", "(")
};
