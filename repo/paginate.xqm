module namespace p = 'paginate';
import module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

(: Hand-curated book lists, keyed by URN under a "books/" prefix in the store
   (the store is a single keyspace, so prefixes are what keep the work metadata,
   the LSJ shortdefs and these apart). They used to be a ~320-line switch here,
   with seed/pagers.xq generating that XQuery as text; now that script writes the
   same data straight into the store. The lists are not all plain ranges — some
   have gaps, a preface, or labels like "17/18" — so they are data, not a rule. :)
declare function p:book-list($urn as xs:string) {
  let $_ := store:read('glaux')
  return store:get('books/' || $urn)
};

(: Works big enough that one page is unreadable, but with no curated book list,
   so texts divided by fable or oration paginate like those divided by book. The
   division and its page list are decided once by seed/divisions.xq — working
   them out here meant opening the treebank and scanning //word for two dozen
   candidate attributes, which the index then did for every work on the site. :)
declare function p:auto-pager($urn as xs:string) {
  let $_ := store:read('glaux')
  let $meta := store:get($urn)
  where exists($meta?division)
  return p:div-pager($meta?division, $meta?pages?*)
};

declare function p:pager($urn as xs:string) {
  p:cased-pager($urn) otherwise p:auto-pager($urn)
};

(: Homer is the one text numbered by Greek letter as well as by digit. :)
declare variable $p:greek-numbered := ('tlg0012/tlg001', 'tlg0012/tlg002');

declare function p:cased-pager($urn as xs:string) {
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

declare function p:greek-numeral($num) as xs:string {
  let $n := $num cast as xs:integer
  let $char := if ($n < 18) then $n - 1 else $n (: skip sigma alternate :)
  return char(0x0391 + $char)
};
