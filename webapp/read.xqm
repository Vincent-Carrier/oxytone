module namespace r = "oxytone/read";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

import module namespace ref = "ref";
import module namespace n = "normalize";

declare variable $r:proseXslt :=
  <xsl:stylesheet version="3.0">
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

declare variable $r:lineXslt :=
  <div class="line">
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

declare variable $r:verseXslt :=
  <xsl:stylesheet version="1.0">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>
    <xsl:template match="/">
      <div class="treebank">
        <xsl:apply-templates />
      </div>
    </xsl:template>
    <xsl:template match="ln">
      {$r:lineXslt}
    </xsl:template>
  </xsl:stylesheet>;

declare variable $r:mergedXslt :=
  <xsl:stylesheet version="1.0">
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
      {$r:lineXslt}
    </xsl:template>
  </xsl:stylesheet>;

declare
  %rest:path("/read/{$author}/{$work}/{$edition}")
  %rest:single
  %output:method("html")
  function r:getTreebank($author, $work, $edition) {
    let $body := db:get('flatbanks', string-join(($author, $work, $edition), '/'))[1]
    let $xslt := if (n:is-verse($author, $work)) then $r:verseXslt else $r:proseXslt
    return xslt:transform($body, $xslt)
};

declare
  %rest:path("/read/{$author}/{$work}/{$edition}/{$book=\d+}")
  %rest:single
  %output:method("html")
  function r:getBook($author, $work, $edition, $book) {
    let $path := string-join(($author, $work, $edition, $book), '/')
    let $_ := message($path)
    let $tb := db:get('flatbanks', $path)
    return xslt:transform($tb, $r:mergedXslt)
};

declare
  %rest:path("/hl/{$author}/{$work}/{$sentence=\d+}/{$word=\d+}")
  %output:method("json")
  function r:highlightDependencies($author, $work, $sentence, $word) {
    let $path := string-join(($author, $work), '/')
    let $tb := db:get('treebanks', $path)[1]
    let $sen := $tb//sentence[@id=$sentence]
    let $w := $sen//*[@id=$word]
    let $o := ($w/obj, $w/coord/obj)
    let $s := ($w/sbj, $w/coord/sbj)
    let $dobjs := $o =!> fn { map {
      'type': switch(@case)
        case 'dat.' return 'dat-obj'
        case 'gen.' return 'gen-obj'
        default return 'acc-obj',
      'head': xs:integer(@id),
      'descendants': .//@id =!> xs:integer() => array:build()
    } }()
    let $sbjs := $s =!> fn { map {
      'type': 'sbj',
      'head': xs:integer(@id),
      'descendants': .//@id =!> xs:integer() => array:build()
    } }()

    return array:build(($dobjs, $sbjs))
};
