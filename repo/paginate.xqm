module namespace p = 'paginate';
import module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare function p:pager($urn as xs:string) {
  switch ($urn)
    case 'tlg0012/tlg001'
      return {
        'get': fn($tb, $n) { p:xslt-filter($tb, 'ln', `starts-with(@n, '{$n}.')`) },
        'list': fn() { 1 to 24 },
        'format': fn($n) { `Book {$n} ({p:greek-numeral($n)})` }
      }
    case 'tlg0012/tlg002'
      return {
        'get': fn($tb, $n) { p:xslt-filter($tb, 'ln', `starts-with(@n, '{$n}.')`) },
        'list': fn() { 1 to 24 },
        'format': fn($n) { `Book {$n} ({p:greek-numeral($n, lowercase := true())})` }
      }
    case 'tlg0059/tlg030' (: Republic :)
      return {
        'get': fn($tb, $n) { p:xslt-filter($tb, 'sentence', `./w[1]/@book = {$n}`) },
        'list': fn() { 1 to 10 },
        'format': fn($n) { `Book {$n}` }
      }
    case 'tlg0016/tlg001' (: Herodotus :)
      return {
        'get': fn($tb, $n) { p:xslt-filter($tb, 'sentence', `./word[1]/@div_book = {$n}`) },
        'list': fn() { 1 to 8 },
        'format': fn($n) { `Book {$n}` }
      }
    case 'tlg0032/tlg006' (: Anabasis :)
      return {
        'get': fn($tb, $n) { p:xslt-filter($tb, 'sentence', `./word[1]/@div_book = {$n}`) },
        'list': fn() { 1 to 7 },
        'format': fn($n) { `Book {$n}` }
      }

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

declare function p:greek-numeral($n, $lowercase := false()) as xs:string {
  let $char := if ($n < 18) then $n - 1 else $n
  return char((if ($lowercase) then 0x03b1 else 0x0391) + $char)
};
