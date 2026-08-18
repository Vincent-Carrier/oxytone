module namespace t = "translations";
import module namespace urn = "urn";

(: What the Perseus TEI headers say about each English translation of a work:
   who translated it and when it was printed.

   None of this is indexed. seed/translated.xq records only a boolean per work —
   enough to decide whether to offer a link, not enough to label one — so the
   headers are read per request. That costs about 25ms for a work, which is well
   under what normalizing the Greek beside it takes.

   127 of the 634 translated works carry more than one edition, which is what
   makes the metadata worth surfacing: without it the reader gets whichever
   edition the database happens to return first, unlabelled. :)

(: Co-translators joined as a phrase rather than a list: there are only ever two
   (the Fowler brothers on Lucian), and "and" reads as a credit where a comma
   reads as a field separator. :)
declare %private function t:names($editors as element()*) as xs:string {
  string-join($editors ! normalize-space(.), ' and ')
};

(: The translator, from the first of three places that names one.

   @role="translator" covers 764 of the 770 editions. The remaining six leave the
   role off, or name the translator only in the source monograph's editor, which
   for a translation is the same person: Evelyn-White's Hesiod, Jebb's Sophocles,
   Hicks' Diogenes Laertius, and three others.

   These are alternatives, so the first non-empty one wins. Joining all three
   instead would credit "Henry Dale and Henry Dale and Henry Dale", since the
   fallbacks repeat the name they are standing in for. :)
declare function t:translator($header as element()) as xs:string {
  let $role := $header//*:titleStmt/*:editor[@role = 'translator'][normalize-space(.) ne '']
  let $any := $header//*:titleStmt/*:editor[normalize-space(.) ne '']
  let $monograph := $header//*:sourceDesc//*:monogr/*:editor[normalize-space(.) ne '']
  return (t:names($role)[. ne ''], t:names($any)[. ne ''], t:names($monograph)[. ne ''], '')[1]
};

(: When the translation was printed, from the source monograph's imprint.

   Not publicationStmt/date, which dates the Perseus digital edition — 1992, or a
   notBefore of 2007 — and so is the same handful of years across the corpus. It
   is the print date that distinguishes Hobbes' Thucydides from Crawley's.

   40 editions carry several dates, distinguished by @type: a Loeb reprinted in
   1962 from a 1927 setting is a 1927 translation, so the first printing wins over
   the printing over whatever is left. Two are unparseable as years ("1900 (?)",
   "1935-37") and pass through as written. :)
declare function t:date($header as element()) as xs:string {
  let $dates := $header//*:sourceDesc//*:imprint/*:date[normalize-space(.) ne '']
  let $date := normalize-space(string((
    $dates[@type = 'first_printing'],
    $dates[@type = 'printing'],
    $dates
  )[1]))
  (: Perseus marks a year it is unsure of with a parenthetical — Butler's Odyssey
     is "1900 (?)" — which is a cataloguing note rather than something a reader
     picking a translation needs, and reads as a typo in a one-line credit. The
     year itself is still the useful thing, so only the mark comes off. :)
  return normalize-space(replace($date, '\s*\(\?\)', ''))
};

(: Every English edition of a work, oldest first.

   Sorted rather than left in database order, which is arbitrary — Thucydides
   comes back with the 1851 Dale ahead of the 1843 Hobbes — and which matters
   beyond tidiness: the first entry is the edition served when none is asked for,
   so an unstable order would change what a bare /translate URL returns.

   Date is a string and sorts as one, which is what the range and question-mark
   forms need; they are year-first, so it still orders them correctly. :)
declare function t:editions($work as xs:string) as map(*)* {
  for $doc in db:get('translations', $work)
  let $header := ($doc//*:teiHeader)[1]
  let $edition := replace(db:path($doc), '^.*/(.*)\.xml$', '$1')
  let $date := t:date($header)
  order by $date, $edition
  return {
    'edition': $edition,
    'translator': t:translator($header),
    'date': $date,
    (: 261 of 770 name a series, nearly always the Loeb. Not rendered — the list
       shows "Translator (year)" and nothing else — but read here because it is
       free alongside the rest and is the obvious thing to want next. :)
    'series': normalize-space(string(($header//*:sourceDesc//*:series/*:title)[1]))
  }
};

(: The document for one edition of a work, or the oldest when none was asked for.

   An unknown edition falls back rather than erroring: the id travels in a query
   string, so a stale bookmark or a hand-edited URL should still read the work. :)
declare function t:edition($work as xs:string, $edition as xs:string?) as document-node()? {
  let $docs := db:get('translations', $work)
  let $wanted := $docs[replace(db:path(.), '^.*/(.*)\.xml$', '$1') = $edition]
  return (
    $wanted,
    $docs[replace(db:path(.), '^.*/(.*)\.xml$', '$1') = head(t:editions($work))?edition]
  )[1]
};
