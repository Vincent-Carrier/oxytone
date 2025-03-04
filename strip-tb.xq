import module namespace xsm = "xsm";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

let $xslt := xsm:stylesheet({
  "/": <body><xsl:apply-templates select="//sentence" /></body>,
  "sentence": <sentence>
    <xsl:copy-of select="@id"/>
    <xsl:for-each select="word">
      <xsl:value-of select="concat(@form, ' ')"/>
    </xsl:for-each>
  </sentence>
})
let $lysias := doc("agldt/v2.1/tlg0540.tlg001.perseus-grc1.tb.xml")
return xslt:transform($lysias, $xslt)
