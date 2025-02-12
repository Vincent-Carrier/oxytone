module namespace n = "normalize";

declare function n:expand-postag($tag) {
    let $tags := characters($tag)
    return (
      attribute pos {
          switch ($tags[1])
          case "n" return "noun"
          case "v" return "verb"
          case "a" return "adjective"
          case "d" return "adverb"
          case "l" return "article"
          case "g" return "particle"
          case "c" return "conjuction"
          case "r" return "preposition"
          case "p" return "pronoun"
          case "m" return "numeral"
          case "i" return "interjection"
          case "u" return "punctuation"
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
          case "s" return "singular"
          case "p" return "plural"
          case "d" return "dual"
          default return ()
      },
      attribute tense {
          switch ($tags[4])
          case "p" return "present"
          case "i" return "imperfect"
          case "r" return "perfect"
          case "l" return "pluperfect"
          case "t" return "future-perfect"
          case "f" return "future"
          case "a" return "aorist"
          default return ()
      },
      attribute mood {
          switch ($tags[5])
          case "i" return "indicative"
          case "s" return "subjunctive"
          case "o" return "optative"
          case "n" return "infinitive"
          case "m" return "imperative"
          case "p" return "participle"
          default return ()
      },
      attribute voice {
          switch ($tags[6])
          case "a" return "active"
          case "p" return "passive"
          case "m" return "middle"
          case "e" return "medio-passive"
          default return ()
      },
      attribute gender {
          switch ($tags[7])
          case "m" return "masculine"
          case "n" return "neuter"
          case "f" return "feminine"
          default return ()
      },
      attribute case {
          switch ($tags[8])
          case "n" return "nom"
          case "a" return "acc"
          case "d" return "dat"
          case "g" return "gen"
          case "v" return "voc"
          case "l" return "loc"
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


declare function n:normalize($tb) {
  <treebank>
    <body>{
      for $sen in $tb/body/sentence
      return <sentence>{
        $sen/@*,
        for sliding window $win in $sen/word
          start $s at $i end $e at $j
          when $j - $i = 1
        (: compare @cite to see if we've reached a new verse :)
        let $refs := if ($s/@cite) then
          $win/@cite/string() =!> fn { tokenize(., ':') => foot() }()
        return (
          element w {
            $s/@*[name()=("id", "head", "lemma", "relation")],
            n:expand-postag($s/@postag/string()),
            concat(
              $s/@form/string(),
              (: insert space if not followed by punctuation :)
              if (characters($e/@postag/string())[1] != "u") then "&#x20;")
          },
          if (not(all-equal($refs))) then <br/>
        )
      }</sentence>
    }</body>
  </treebank>
};
