module namespace ox = "oxytone/define";

declare variable $ox:xslt := 
  <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="no" encoding="UTF-8"/>
      <xsl:template match="/">
        <div>
          <xsl:for-each select="/div/entryFree">
            <div class="entry">
              <div class="headword">
                <xsl:value-of select="orth"/>
              </div>
              <ul class="meanings">
                <xsl:for-each select=".//sense//tr[not(.=preceding::*)]/text()">
                  <li>
                    <xsl:value-of select="." />
                  </li>
                </xsl:for-each>
              </ul>
            </div>
          </xsl:for-each>
        </div>
      </xsl:template>
  </xsl:stylesheet>;

declare %rest:path("define/lsj/{$lemma}")
        %rest:GET
        %output:method("html")
        function ox:getDefinition($lemma) {
   let $entry := <div>{db:get("lsj", $lemma)}</div>
   return xslt:transform($entry, $ox:xslt)
};