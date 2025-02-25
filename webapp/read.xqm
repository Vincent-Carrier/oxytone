module namespace ox = "oxytone/read";

import module namespace ref = "ref";
import module namespace n = "normalize";

declare variable $ox:proseXslt :=
  <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>
    <xsl:template match="/">
      <xsl:for-each select="//body">
        <div class="treebank">
            <xsl:for-each select=".//sentence">
              <span class="sentence">
                <span class="sentence-nbr">
                  <xsl:value-of select="@id" />
                </span>
                <xsl:for-each select=".//w[not(@artificial)]">
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

declare variable $ox:lineXslt :=
    <div class="line" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <a class="line-nbr">
        <xsl:copy-of select="@n" />
        <xsl:attribute name="id">
          <xsl:value-of select="@n" />
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', @n)" />
        </xsl:attribute>
        <xsl:value-of select="@n" />
      </a>
      <xsl:for-each select=".//w">
        <ox-w>
          <xsl:copy-of select="./*|@*|text()" />
        </ox-w>
      </xsl:for-each>
    </div>;

declare variable $ox:verseXslt :=
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  <xsl:template match="/">
    <div class="treebank">
      <xsl:apply-templates select="ln" />
    </div>
  </xsl:template>
  <xsl:template match="ln">
    {$ox:lineXslt}
  </xsl:template>
</xsl:stylesheet>;

declare variable $ox:mergedXslt :=
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="no" encoding="UTF-8"/>
  <xsl:template match="/">
    <div class="treebank">
      <xsl:apply-templates />
    </div>
  </xsl:template>
  <xsl:template match="hr|blockquote">
    <xsl:copy>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>
  <xsl:template match="ln">
    {$ox:lineXslt}
  </xsl:template>
</xsl:stylesheet>;

declare %rest:path("/read/{$author}/{$work}/{$edition}")
        %rest:single
        %output:method("html")
        function ox:getTb($author, $work, $edition) {
          let $body := db:get('flatbanks', string-join(($author, $work, $edition), '/'))[1]
          return xslt:transform($body, if (n:is-verse($author, $work))
                                       then $ox:verseXslt else $ox:proseXslt)
};

declare %rest:path("/read/{$author}/{$work}/{$edition}/{$book=[0-9]+}")
        %rest:single
        %output:method("html")
        function ox:getBook($author, $work, $edition, $book) {
          let $path := string-join(($author, $work, $edition, $book), '/')
          let $_ := message($path)
          let $tb := db:get('flatbanks', $path)
          return xslt:transform($tb, $ox:mergedXslt)
};
