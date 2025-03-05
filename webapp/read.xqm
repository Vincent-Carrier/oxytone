module namespace r = "oxytone/read";
import module namespace xsm = "xsm";
import module namespace n = "normalize";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $r:proseXslt := xsm:stylesheet({
  "/":
    <div class="treebank">
      <h1><xsl:value-of select="$title" /></h1>
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
}, (<xsl:param name="title" />));

declare variable $r:rootXslt :=
  <div class="treebank">
    <hgroup>
      <h1>
        <xsl:value-of select="replace(normalize-unicode($title, 'NFD'), '\p{{M}}', '')" />
      </h1>
      <p class="author">
        <xsl:value-of select="replace(normalize-unicode($author, 'NFD'), '\p{{M}}', '')" />
      </p>
    </hgroup>
    <xsl:apply-templates />
  </div>;

declare variable $r:wordXslt :=
  <ox-w>
    <xsl:copy-of select="@*" />
    <xsl:value-of select="normalize-unicode(., 'NFD') => replace('^([αεηιυοω]{{1,2}})&#x0313;', '$1', 'i') => normalize-unicode('NFC')" />
  </ox-w>;

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
      {$r:wordXslt}
    </xsl:for-each>
  </div>;

declare variable $r:verseXslt := xsm:stylesheet({
  "/":
    <div class="treebank">
      <xsl:apply-templates />
    </div>,
  "ln": $r:lineXslt
});

declare variable $r:mergedXslt := xsm:stylesheet({
  "/": $r:rootXslt,
  "hr|blockquote": xsm:keep("node()"),
  "speaker":
    <div class="speaker">
      <xsl:value-of select="replace(normalize-unicode(., 'NFD'), '\p{{M}}', '')"/>
    </div>,
  "ln": $r:lineXslt
}, (<xsl:param name="title" />, <xsl:param name="author" />));

declare
  %rest:path("/read/{$author}/{$work}")
  %rest:single
  %output:method("html")
  function r:get-merged($author, $work) {
    let $body := db:get('flatbanks', string-join(($author, $work, 'merged'), '/'))[1]
    let $tei := db:get("lit", `{$author}/{$work}`)[1]
    let $titleStmt := $tei/TEI/teiHeader/fileDesc/titleStmt
    return xslt:transform($body, $r:mergedXslt, {
      'title': `{$titleStmt/title/text()}`,
      'author': $titleStmt/author/text()
    })
};

declare
  %rest:path("/read/{$author}/{$work}/{$edition}")
  %rest:single
  %output:method("html")
  function r:get-treebank($author, $work, $edition) {
    let $body := db:get('flatbanks', string-join(($author, $work, $edition), '/'))[1]
    let $xslt :=
      if ($edition = 'merged') then $r:mergedXslt
      else if (n:is-verse($author, $work)) then $r:verseXslt
      else $r:proseXslt
    return xslt:transform($body, $xslt)
};

declare
  %rest:path("/read/{$author}/{$work}/book/{$book=\d+}")
  %rest:single
  %output:method("html")
  function r:get-book($author, $work, $book) {
    let $path := string-join(($author, $work, 'merged', $book), '/')
    let $_ := message($path)
    let $tb := db:get('flatbanks', $path)
    let $tei := db:get("lit", `{$author}/{$work}`)[1]
    let $titleStmt := $tei/TEI/teiHeader/fileDesc/titleStmt
    return xslt:transform($tb, $r:mergedXslt, {
      'title': `{$titleStmt/title/text()} {$book}`,
      'author': $titleStmt/author/text()
    })
};

declare
  %rest:path("/hl/{$author}/{$work}/{$sentence=\d+}/{$word=\d+}")
  %output:method("json")
  function r:highlight-dependencies($author, $work, $sentence, $word) {
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
