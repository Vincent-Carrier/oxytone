module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare function xsm:stylesheet(
  $templates as map(xs:string, element()*),
  $body as element()* := (),
  $params as xs:string* := (),
  $method as xs:string := "xml",
  $indent as xs:string := "no"
) as element() {
  <xsl:stylesheet version="3.0" xmlns:oxy="http://oxytone.xyz/functions">
    <xsl:output method="{$method}" indent="{$indent}" encoding="UTF-8"/>
    <xsl:function name="oxy:normalize-punct">
      <xsl:param name="text"/>
      <xsl:value-of select="$text
        => replace(',\s+', ', ')
        => replace('\.\s+', '. ')
        => replace(';\s+', '; ')
        => replace(':\s+', ': ')" />
    </xsl:function>
    <xsl:function name="oxy:strip-diacritics">
      <xsl:param name="text"/>
      <xsl:value-of select="replace($text, '\p{{M}}', '')" />
    </xsl:function>
    <xsl:function name="oxy:strip-smooth-breathings">
      <xsl:param name="text"/>
      <xsl:value-of select="$text => replace('^([αεηιυοω]{{1,2}})&#x0313;', '$1', 'i') => normalize-unicode('NFC')" />
    </xsl:function>
    {for $param in $params
      return <xsl:param name="{$param}" />}
    {for key $match value $template in $templates
      return <xsl:template match="{$match}">
        {$template}
      </xsl:template>}
    {$body}
  </xsl:stylesheet>
};

declare function xsm:attr($name as xs:string, $value as xs:string) as element() {
    <xsl:attribute name="{$name}">
      <xsl:value-of select="{$value}" />
    </xsl:attribute>
};

declare function xsm:keep($select as xs:string := "@*|node()") as element() {
  <xsl:copy>
    <xsl:apply-templates select="{$select}" />
  </xsl:copy>
};
