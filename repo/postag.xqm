module namespace pt = "postag";

declare function pt:expand($tag as xs:string) {
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

declare function pt:expand-proiel($tag) {
  let $tags := characters($tag)
  return (
    attribute person {
      switch ($tags[1])
        case "1" return "1st"
        case "2" return "2nd"
        case "3" return "3rd"
        default return ()
    },
    attribute number {
      switch ($tags[2])
        case "s" return "sg."
        case "p" return "pl."
        case "d" return "dual"
        default return ()
    },
    attribute tense {
      switch ($tags[3])
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
      switch ($tags[4])
        case "i" return "ind."
        case "s" return "subj."
        case "o" return "opt."
        case "n" return "inf."
        case "m" return "imperative"
        case "p" return "partcpl."
        default return ()
    },
    attribute voice {
      switch ($tags[5])
        case "a" return "act."
        case "p" return "pass."
        case "m" return "mid."
        case "e" return "m.-p."
        default return ()
    },
    attribute gender {
      switch ($tags[6])
        case "m" return "masc."
        case "n" return "neut."
        case "f" return "fem."
        default return ()
    },
    attribute case {
      switch ($tags[7])
        case "n" return "nom."
        case "a" return "acc."
        case "d" return "dat."
        case "g" return "gen."
        case "v" return "voc."
        case "l" return "loc."
        default return ()
    },
    attribute degree {
      switch ($tags[8])
        case "c" return "comparative"
        case "s" return "superlative"
        default return ()
    }
  )[data() != ""]
};

declare function pt:proiel-pos($tag as xs:string) {
  attribute pos {
      switch ($tag)
        case ("Nb", "Ne") return "noun"
        case "V-" return "verb"
        case "A-" return "adj."
        case "Df" return "adv."
        case "S-" return "article"
        case "C-" return "conj."
        case "R-" return "prep."
        case ("Px", "Pi", "Pp", "Pk", "Ps", "Pt", "Pc", "Pr") return "pronoun"
        case ("Ma", "Mo") return "numeral"
        case "I-" return "interj."
        default return ()
  }[data() != ""]
};
