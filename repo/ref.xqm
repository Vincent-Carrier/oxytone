module namespace ref = "ref";

declare function ref:from-str($str) {
    let $parts := tokenize($str, '-')
    return (
        attribute start {$parts[1]},
        attribute end {$parts[2]}
    )
};

declare function ref:get-book($tb, $book as xs:integer) {
  let $xslt := 
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:template match="@*|node()">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:template>
        <xsl:template match="ln">
            <xsl:if test="starts-with(@n, '{$book}.')">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:if>
        </xsl:template>
    </xsl:stylesheet>
  return xslt:transform($tb, $xslt)
};
