module namespace urn = "urn";

declare function urn:parse($path as xs:string) {
  let $urn := tokenize($path, '/')
  return map {
    'author': $urn[1],
    'work': $urn[2],
    'edition': $urn[3]
  }
};

(: The work URN is the first two segments: "tlg0012/tlg001/perseus-grc2" ->
   "tlg0012/tlg001". Slicing to a fixed 14 characters instead dropped the suffix
   on the 23 works split into parts (tlg0096/tlg002a -> tlg0096/tlg002), which
   linked them all to a work that does not exist. :)
declare function urn:work($path as xs:string) as xs:string {
  string-join(tokenize($path, '/')[position() le 2], '/')
};

(: Splits the {$work-page} part of a read/plain route into its work and its page
   label. The page is everything after the first segment, not just the second:
   two works carry a label with a slash in it (Dionysius "17/18", Hippolytus
   "77/78"), and tokenizing those into pieces asked for a book that does not
   exist, so the page filter deleted every sentence and rendered an empty text. :)
declare function urn:work-page($work-page as xs:string) {
  let $parts := tokenize($work-page, '/')
  return map {
    'work': head($parts),
    'page': if (count($parts) gt 1) then string-join(tail($parts), '/') else ()
  }
};
