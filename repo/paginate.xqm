module namespace p = 'paginate';
import module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

(: The hand-curated page list for a work, or empty if it has none. Written by
   seed/pagers.xq under a "books/" prefix — the store is a single keyspace, so
   prefixes are what keep these apart from the work metadata and LSJ shortdefs.

   They are data rather than a rule because the lists are not all plain ranges:
   some have gaps, a preface, or labels like "17/18". :)
declare function p:book-list($urn as xs:string) {
  let $_ := store:read('glaux')
  return store:get('books/' || $urn)
};

(: The fallback pager for works long enough to need paging but with no curated
   book list, so a text divided by fable or oration pages like one divided by
   book. Which division to use, and its page list, are precomputed by
   seed/divisions.xq: deciding it here would mean scanning //word for two dozen
   candidate attributes on every request, once per work on the index page. :)
declare function p:auto-pager($urn as xs:string) {
  let $_ := store:read('glaux')
  let $meta := store:get($urn)
  where exists($meta?division)
  return p:div-pager($meta?division, $meta?pages?*)
};

(: How to page a work, or empty for one that is read whole. A pager is a map of
   `get` (a treebank and a page label -> that page's sentences), `list` (every page
   label, in reading order), `format` (a label -> its heading, "Book 3") and
   `label` (a label -> its shorter form in the nav). Curated lists win over the
   division picked automatically. :)
declare function p:pager($urn as xs:string) {
  p:curated-pager($urn) otherwise p:auto-pager($urn)
};

(: Homer is the one text numbered by Greek letter as well as by digit. :)
declare variable $p:greek-numbered := ('tlg0012/tlg001', 'tlg0012/tlg002');

declare function p:curated-pager($urn as xs:string) {
  let $books := p:book-list($urn)
  where exists($books)
  return
    if ($urn = $p:greek-numbered)
    then p:homer-pager($books?*)
    else p:book-pager($books?*)
};

declare function p:homer-pager($list) {
  let $format := fn($n) { `Book {$n} ({p:greek-numeral($n)})` }
  return map {
    'get': fn($tb, $n) {
      let $page := $n otherwise head($list)
      return $tb transform with {
        delete nodes .//sentence[./word[1]/@div_book != $page]
      }
    },
    'list': $list,
    'format': $format,
    'label': $format
  }
};


(: Same shape as p:book-pager, but filters on whichever division attribute the
   text uses rather than assuming @div_book. :)
declare function p:div-pager($div as xs:string, $list) {
  let $label := replace(replace($div, '^div_', ''), '_', ' ')
  let $name := `{upper-case(substring($label, 1, 1))}{substring($label, 2)}`
  (: Past a couple of dozen entries the noun is repeated more than it is read,
     and at 359 fables it was three times the width of the number it labels. Long
     numbered runs get the bare numeral; short lists keep the word. :)
  let $terse := count($list) > 24 and every($list, fn { string(.) castable as xs:integer })
  return map {
    'get': fn($tb, $n) {
      let $page := $n otherwise head($list)
      return $tb transform with {
        delete nodes .//sentence[(./word/@*[name() = $div])[1] != $page]
      }
    },
    'list': $list,
    'terse': $terse,
    (: The heading always spells the division out ("Fables, Fable 7"); only the
       nav list goes terse, where the noun is repeated hundreds of times. :)
    'format': fn($n) { `{$name} {$n}` },
    'label': fn($n) { if ($terse) then string($n) else `{$name} {$n}` }
  }
};

declare function p:book-pager($list) {
  let $format := fn($n) {
    typeswitch ($n) {
      case xs:integer return `Book {$n}`
      default return switch ($n) {
        case 'praef' return "Preface"
        default return $n
      }
    }
  }
  (: Book lists are short enough that the nav reads the same as the heading. :)
  return map {
    'get': fn($tb, $n) {
      let $page := $n otherwise head($list)
      return $tb transform with {
        delete nodes .//sentence[./word[1]/@div_book != $page]
      }
    },
    'list': $list,
    'format': $format,
    'label': $format
  }
};

(: The nth capital Greek letter, as Homer's books are traditionally numbered.
   Counting from Α at U+0391, book 18 onward shifts by one to step over final
   sigma (U+03A2 is unassigned, and ς is not used as a numeral). :)
declare function p:greek-numeral($num) as xs:string {
  let $n := $num cast as xs:integer
  let $char := if ($n < 18) then $n - 1 else $n
  return char(0x0391 + $char)
};
