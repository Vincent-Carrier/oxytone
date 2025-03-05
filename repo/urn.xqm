module namespace urn = "urn";

declare function urn:parse($path as xs:string) {
  let $urn := tokenize($path, '/')
  return map {
    'author': $urn[1],
    'work': $urn[2],
    'edition': $urn[3]
  }
};
