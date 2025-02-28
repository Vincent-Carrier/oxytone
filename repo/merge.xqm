module namespace m = "merge";

declare function m:teiPath($tbPath as xs:string) as xs:string {
  let $urn := tokenize($tbPath, "/")
  return db:list('lit', string-join($urn[1 to 2], '/'))[1]
};

declare function m:compare($a as xs:string*, $b as xs:string*) as xs:integer {
  let $aNorm := $a => concat() => normalize-space()
  let $bNorm := $b => concat() => normalize-space()
  return string:jaro-winkler($aNorm, $bNorm)
};
