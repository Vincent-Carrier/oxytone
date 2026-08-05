module namespace pt = "postag";

(: The AGLDT positional tag: nine characters, each a code in its own vocabulary.
   Written out as a table rather than nested switches, so the two tag dialects
   can share one expansion. :)
declare variable $pt:positions := (
  { 'name': 'pos', 'codes': {
      'n': 'noun', 'v': 'verb', 'a': 'adj.', 'd': 'adv.', 'l': 'article',
      'g': 'particle', 'c': 'conj.', 'r': 'prep.', 'p': 'pronoun',
      'm': 'numeral', 'i': 'interj.', 'u': 'punct.' } },
  { 'name': 'person', 'codes': { '1': '1st', '2': '2nd', '3': '3rd' } },
  { 'name': 'number', 'codes': { 's': 'sg.', 'p': 'pl.', 'd': 'dual' } },
  { 'name': 'tense', 'codes': {
      'p': 'pres.', 'i': 'imperf.', 'r': 'perf.', 'l': 'pluperf.',
      't': 'fut.-perf.', 'f': 'fut.', 'a': 'aor.' } },
  { 'name': 'mood', 'codes': {
      'i': 'ind.', 's': 'subj.', 'o': 'opt.', 'n': 'inf.',
      'm': 'imperative', 'p': 'partcpl.' } },
  { 'name': 'voice', 'codes': {
      'a': 'act.', 'p': 'pass.', 'm': 'mid.', 'e': 'm.-p.' } },
  { 'name': 'gender', 'codes': { 'm': 'masc.', 'n': 'neut.', 'f': 'fem.' } },
  { 'name': 'case', 'codes': {
      'n': 'nom.', 'a': 'acc.', 'd': 'dat.', 'g': 'gen.',
      'v': 'voc.', 'l': 'loc.' } },
  { 'name': 'degree', 'codes': { 'c': 'comparative', 's': 'superlative' } }
);

(: Attributes are emitted only when the code is recognised. Constructing them
   unconditionally and filtering afterwards would need a trailing predicate:
   attribute x { () } yields an attribute with an empty value, not nothing. :)
declare function pt:attributes($tag as xs:string, $positions) {
  let $chars := characters($tag)
  for $p at $i in $positions
    let $value := $p?codes?($chars[$i])
    where exists($value)
    return attribute { $p?name } { $value }
};

declare function pt:expand($tag as xs:string) {
  pt:attributes($tag, $pt:positions)
};

(: PROIEL omits the leading part-of-speech character; the rest lines up. :)
declare function pt:expand-proiel($tag as xs:string) {
  pt:attributes($tag, tail($pt:positions))
};

declare variable $pt:proiel-pos := {
  'Nb': 'noun', 'Ne': 'noun', 'V-': 'verb', 'A-': 'adj.', 'Df': 'adv.',
  'S-': 'article', 'C-': 'conj.', 'R-': 'prep.',
  'Px': 'pronoun', 'Pi': 'pronoun', 'Pp': 'pronoun', 'Pk': 'pronoun',
  'Ps': 'pronoun', 'Pt': 'pronoun', 'Pc': 'pronoun', 'Pr': 'pronoun',
  'Ma': 'numeral', 'Mo': 'numeral', 'I-': 'interj.'
};

declare function pt:proiel-pos($tag as xs:string) {
  let $value := $pt:proiel-pos?($tag)
  where exists($value)
  return attribute pos { $value }
};
