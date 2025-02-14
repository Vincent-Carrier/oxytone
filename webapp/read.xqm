module namespace ox = "oxytone/read";

import module namespace ref = "ref";

declare variable $ox:xslt := 
  <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="no" encoding="UTF-8"/>
      <xsl:template match="body">
        <div class="treebank">
            <xsl:apply-templates />
        </div>
      </xsl:template>
      <xsl:template match="sentence">
          <span class="sentence">
              <xsl:apply-templates />
          </span>
      </xsl:template>
      <xsl:template match="w">
          <ox-w>
              <xsl:copy-of select="./*|@*|text()" />
          </ox-w>
      </xsl:template>
      <xsl:template match="br">
          <br/>
      </xsl:template>
  </xsl:stylesheet>;

declare %rest:path("/read/{$author}/{$work}/{$edition}")
        %rest:single
        %output:method("html")
        function ox:getTb($author, $work, $edition) {
          let $urn := string-join(($author, $work, $edition), '/')
          let $body := db:get('flatbanks', $urn)[1]
          return xslt:transform($body, $ox:xslt)
};

declare %rest:path("/read/{$author}/{$work}/{$edition}/{$book=[0-9]+}")
        %rest:single
        %output:method("html")
        function ox:getBook($author, $work, $edition, $book) {
          let $urn := string-join(($author, $work, $edition), '/')
          let $tb := db:get('flatbanks', $urn)[1]
          let $body := ref:get-book($tb, $book)
          return xslt:transform($body, $ox:xslt)
};
