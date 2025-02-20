module namespace ox = "oxytone/read";

import module namespace ref = "ref";
import module namespace n = "normalize";

declare variable $ox:proseXslt := 
  <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="html" indent="no" encoding="UTF-8"/>
    <xsl:template match="/">
      <xsl:for-each select="//body">
        <div class="treebank">
            <xsl:for-each select=".//sentence">
              <span class="sentence">
                <xsl:for-each select=".//w">
                  <ox-w>
                    <xsl:copy-of select="./*|@*|text()" />
                  </ox-w>
                </xsl:for-each>
                <xsl:for-each select=".//br">
                  <br/>
                </xsl:for-each>
              </span>
            </xsl:for-each>
        </div>
      </xsl:for-each>
    </xsl:template>
  </xsl:stylesheet>;

declare variable $ox:verseXslt := 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  <xsl:template match="/">
      <xsl:for-each select="//body">
        <div class="treebank">
          <xsl:for-each select=".//ln">
            <div class="line">
              <span class="line-nbr">
                <xsl:copy-of select="@n" />
                <xsl:value-of select="@n" />
              </span>
              <xsl:for-each select=".//w">
                <ox-w>
                  <xsl:copy-of select="./*|@*|text()" />
                </ox-w>
              </xsl:for-each>
              <xsl:for-each select=".//br">
                <br/>
              </xsl:for-each>
            </div>
          </xsl:for-each>
        </div>
      </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>;


declare %rest:path("/read/{$author}/{$work}")
        %rest:single
        %output:method("html")
        function ox:getTb($author, $work) {
          let $body := db:get('flatbanks', $author || '/' || $work)[1]
          return xslt:transform($body, if (n:is-verse($author, $work)) then $ox:verseXslt else $ox:proseXslt)
};

declare %rest:path("/read/{$author}/{$work}/{$book=[0-9]+}")
        %rest:single
        %output:method("html")
        function ox:getBook($author, $work, $book) {
          let $tb := db:get('flatbanks', $author || '/' || $work)[1]
          let $body := ref:get-book($tb, $book)
          return xslt:transform($body, $ox:verseXslt)
};
