declare module namespace m = "merge";

declare function m:compare($a as xs:string*, $b as xs:string*) as xs:integer {
  let $aNorm := $a => concat() => normalize-space()
  let $bNorm := $b => concat() => normalize-space()
  return string:jaro-winkler($aNorm, $bNorm)
}
