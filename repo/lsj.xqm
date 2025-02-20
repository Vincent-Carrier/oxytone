module namespace lsj = "lsj";

declare function lsj:define($lemma as xs:string) {
  let $entry := db:get("lsj", $lemma)
  return $entry
};
