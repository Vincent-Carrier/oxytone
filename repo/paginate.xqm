module namespace p = 'paginate';
import module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare function p:pager($urn as xs:string) {
  switch ($urn)
    case ('tlg0012/tlg001', 'tlg0012/tlg002')
      return {
        'get': fn($tb, $n) { p:xslt-filter($tb, 'ln', `starts-with(@n, '{$n}.')`) },
        'list': fn() { 1 to 24 },
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
