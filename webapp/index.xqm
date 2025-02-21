module namespace idx = "oxytone/index";

declare variable $idx:xslt :=
  <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="no" encoding="UTF-8"/>
      <xsl:template match="/">
        <div>
          <xsl:for-each select="/div/author[.//tb]">
            <xsl:sort select="@name" />
            <div class="author">
              <h2>
                <xsl:value-of select="@name"/>
              </h2>
              <ul class="works">
                <xsl:for-each select="./work[tb]">
                  <xsl:sort select="./title[1]" />
                  <li>
                    <a>
                      <xsl:attribute name="href">
                        <xsl:value-of select="concat('/read/', ./tb/@path)" />
                      </xsl:attribute>
                      <xsl:value-of select="./title[1]" />
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
            </div>
          </xsl:for-each>
        </div>
      </xsl:template>
  </xsl:stylesheet>;

declare %rest:path("")
        %rest:GET
        %output:method("html")
        function idx:get-index() {
   xslt:transform(<div>{db:get("catalog")}</div>, $idx:xslt)
};
