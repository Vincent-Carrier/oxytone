module namespace lsj = "lsj";

declare function lsj:define($lemma as xs:string) {
  let $entry := db:attribute("lsj", $lemma, "key")/..
  return $entry
};
