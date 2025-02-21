module namespace n = "normalize";

declare function n:expand-postag($tag) {
    let $tags := characters($tag)
    return (
      attribute pos {
          switch ($tags[1])
          case "n" return "noun"
          case "v" return "verb"
          case "a" return "adj."
          case "d" return "adv."
          case "l" return "article"
          case "g" return "particle"
          case "c" return "conj."
          case "r" return "prep."
          case "p" return "pronoun"
          case "m" return "numeral"
          case "i" return "interj."
          case "u" return "punct."
          default return ()
      },
      attribute person {
          switch ($tags[2])
          case "1" return "1st"
          case "2" return "2nd"
          case "3" return "3rd"
          default return ()
      },
      attribute number {
          switch ($tags[3])
          case "s" return "sg."
          case "p" return "pl."
          case "d" return "dual"
          default return ()
      },
      attribute tense {
          switch ($tags[4])
          case "p" return "pres."
          case "i" return "imperf."
          case "r" return "perf."
          case "l" return "pluperf."
          case "t" return "fut.-perf."
          case "f" return "fut."
          case "a" return "aor."
          default return ()
      },
      attribute mood {
          switch ($tags[5])
          case "i" return "ind."
          case "s" return "subj."
          case "o" return "opt."
          case "n" return "inf."
          case "m" return "imperative"
          case "p" return "partcpl."
          default return ()
      },
      attribute voice {
          switch ($tags[6])
          case "a" return "act."
          case "p" return "pass."
          case "m" return "mid."
          case "e" return "m.-p."
          default return ()
      },
      attribute gender {
          switch ($tags[7])
          case "m" return "masc."
          case "n" return "neut."
          case "f" return "fem."
          default return ()
      },
      attribute case {
          switch ($tags[8])
          case "n" return "nom."
          case "a" return "acc."
          case "d" return "dat."
          case "g" return "gen."
          case "v" return "voc."
          case "l" return "loc."
          default return ()
      },
      attribute degree {
          switch ($tags[9])
          case "c" return "comparative"
          case "s" return "superlative"
          default return ()
      }
    )[data() != ""]
};

declare function n:is-verse($author, $work) {
  switch($author)
    case ('tlg0012') return true()
    default return false()
};


declare function n:cite-break($a, $b, $c) {
  ($a != $c and $b = "")
  or ($b != $c and $c != "" and $b != "")
};

declare function n:normalize-verse($tb) as element()* {
    for tumbling window $line in $tb//word
      start $s end $e previous $p next $n
      when n:cite-break($p/@cite, $e/@cite, $n/@cite)
    let $ref := tokenize($s/@cite/string(), ':') => foot()
    return
      <ln n="{$ref}">
        {
          for sliding window $win in $line
            start $w at $i end $n at $j
            when $j - $i = 1
          let $ref := tokenize($w/@cite/string(), ':') => foot()
          let $morph := n:expand-postag($w/@postag/string())
          return element w {
              attribute ref {$ref},
              attribute sentence_id {$w/../@id},
              $w/@*[name()=("id", "head", "lemma", "relation", "artificial")],
              $morph,
              concat(
                $w/@form/string(),
                (: insert space if not followed by punctuation :)
                if (characters($n/@postag/string())[1] != "u") then "&#x20;"
              )
          }
        }
      </ln>
};

declare function n:normalize-prose($tb) as element()* {
  for $sen in $tb//sentence
  return <sentence>{
    $sen/@*,
    for sliding window $win in $sen/word
      start $s at $i end $e at $j
      when $j - $i = 1
    return (
      element w {
        $s/@*[name()=("id", "head", "lemma", "relation", "artificial")],
        n:expand-postag($s/@postag/string()),
        concat(
          $s/@form/string(),
          (: insert space if not followed by punctuation :)
          if (characters($e/@postag/string())[1] != "u") then "&#x20;")
      }
    )
  }</sentence>
};

declare function n:normalize($tb, $verse) as element() {
  <treebank type="{if ($verse) then 'verse' else 'prose'}">
    <body>{
      if ($verse) {n:normalize-verse($tb)}
      else {n:normalize-prose($tb)}
    }</body>
  </treebank>
};
