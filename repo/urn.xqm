module namespace urn = "urn";

declare function urn:parse($path as xs:string) {
  let $urn := tokenize($path, '/')
  return map {
    'author': $urn[1],
    'work': $urn[2],
    'edition': $urn[3]
  }
};

(: The work URN, which is the first two segments of an edition path:
   "tlg0012/tlg001/perseus-grc2" -> "tlg0012/tlg001". Segment-wise rather than a
   fixed width, since 23 works are split into lettered parts (tlg0096/tlg002a)
   whose suffix must survive. :)
declare function urn:work($path as xs:string) as xs:string {
  string-join(tokenize($path, '/')[position() le 2], '/')
};

(: Splits the {$work-page} part of a read/plain route into its work and its page
   label, or an empty page if the route named none. The page is everything after
   the first segment, not just the second: a few works carry a label with a slash
   in it (Dionysius "17/18", Hippolytus "77/78"). :)
declare function urn:work-page($work-page as xs:string) {
  let $parts := tokenize($work-page, '/')
  return map {
    'work': head($parts),
    'page': if (count($parts) gt 1) then string-join(tail($parts), '/') else ()
  }
};
