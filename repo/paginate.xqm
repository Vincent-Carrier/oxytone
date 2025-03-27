module namespace p = 'paginate';
import module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare function p:pager($urn as xs:string) {
  switch ($urn)
    case ('tlg0012/tlg001', 'tlg0012/tlg002')
      return {
        'get': fn($tb, $n) { p:xslt-filter($tb, 'sentence', `./word[1]/@div_book = {$n}`) },
        'list': fn() { 1 to 24 },
        'format': fn($n) { `Book {$n} ({p:greek-numeral($n)})` }
      }
    case 'tlg0059/tlg030' (: Republic :)
      return p:book-pager(10)
    case 'tlg0016/tlg001' (: Herodotus :)
      return p:book-pager(8)
    case 'tlg0032/tlg006' (: Anabasis :)
      return p:book-pager(7)
    default return ()
};

declare function p:xslt-filter($xml, $el as xs:string, $pred as xs:string) {
  let $filter := xsm:stylesheet({
    "@*|node()": xsm:keep(),
    $el: <xsl:if test="{$pred}">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  })
  return xslt:transform($xml, $filter)
};

declare function p:book-pager($last) {
  map {
    'get': fn($tb, $n) { p:xslt-filter($tb, 'sentence', `./word[1]/@div_book = {$n}`) },
    'list': fn() { 1 to $last },
    'format': fn($n) { `Book {$n}` }
  }
};

declare function p:greek-numeral($n as xs:integer) as xs:string {
  let $char := if ($n < 18) then $n - 1 else $n (: skip sigma alternate :)
  return char(0x0391 + $char)
};
