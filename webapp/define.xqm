module namespace ox = "oxytone/define";

import module namespace lsj = "lsj";

declare variable $ox:xslt := 
  <xsl:stylesheet version="1.0" 
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
      <xsl:template match="entryFree">
          <div class="entry">
              <link href="/static/style.css" rel="stylesheet" />
              <h2 class="headword">
                  <xsl:apply-templates select="orth"/>
              </h2>
              <div class="senses">
                  <xsl:apply-templates select="sense"/>
              </div>
          </div>
      </xsl:template>
      <xsl:template match="orth">
          <span class="greek-text">
              <xsl:value-of select="."/>
          </span>
      </xsl:template>
      <xsl:template match="sense">
          <div class="sense">
              <xsl:if test="@n">
                  <span class="sense-number">
                      <xsl:value-of select="@n"/>. 
                  </span>
              </xsl:if>
              <xsl:apply-templates/>
          </div>
      </xsl:template>
      <xsl:template match="bibl">
          <span class="bibl">
              <xsl:apply-templates select="author"/>
              <xsl:text> </xsl:text>
              <xsl:apply-templates select="title"/>
              <xsl:text> </xsl:text>
              <xsl:apply-templates select="biblScope"/>
          </span>
      </xsl:template>
      <xsl:template match="cit">
          <div class="citation">
              <span class="quote greek-text">
                  <xsl:apply-templates select="quote"/>
              </span>
              <xsl:apply-templates select="bibl"/>
          </div>
      </xsl:template>
      <xsl:template match="text()">
          <xsl:value-of select="normalize-space()"/>
      </xsl:template>
  </xsl:stylesheet>;

declare %rest:path("define/lsj/{$lemma}")
        %rest:GET
        %output:method("html")
        function ox:getDefinition($lemma) {
   let $entry := lsj:define($lemma)
   return xslt:transform($entry, $ox:xslt)
};