module namespace p = 'paginate';
import module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare function p:pager($urn as xs:string) {
  if ($urn => matches('^tlg0012') then
    fn($tb, $n) { p:xslt-filter($tb, 'ln', `starts-with(@n, '{$n}.')`) }
};

declare function p:all-pages($urn xs:string) {
  if ($author = 'tlg0012') then
    1 to 24
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
