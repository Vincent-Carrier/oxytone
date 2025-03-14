module namespace r = "oxytone/read";
import module namespace xsm = "xsm";
import module namespace dblazy = "dblazy";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $r:xslt := xsm:stylesheet({
  "/treebank":
    <div class="treebank">
      <hgroup>
        <h1>
          <xsl:value-of select="oxy:strip-diacritics(head/title)" />
        </h1>
        <p class="author">
          <xsl:value-of select="oxy:strip-diacritics($author)" />
        </p>
      </hgroup>
      <div class="body">
        <xsl:apply-templates select="body" />
      </div>
    </div>,
  "sentence":
    <span class="sentence">
      <span class="sentence-nbr">
        <xsl:value-of select="@id" />
      </span>
      <xsl:apply-templates />
    </span>,
  "verse":
    <span class="verse">
      <a class="verse-nbr">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', replace(@id, '\w+ \d+\.(\d+)$', '$1'))" />
        </xsl:attribute>
        <xsl:value-of select="replace(@id, '\w+ \d+\.(\d+)$', '$1')" />
      </a>
      <xsl:apply-templates />
    </span>,
  "ln":
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
      <xsl:apply-templates />
    </div>,
  "speaker":
    <div class="speaker">
      <xsl:value-of select="oxy:strip-diacritics(.)"/>
    </div>,
  "w[not(@artificial)]":
    <ox-w>
      <xsl:copy-of select="@*" />
      <xsl:value-of select="oxy:strip-smooth-breathings(.)" />
    </ox-w>,
  "blockquote": xsm:keep("node()"),
  "br|hr": xsm:keep()
}, params := ("title", "author"));

declare
  %rest:path("/read/{$author}/{$work}")
  %rest:single
  %output:method("html")
  function r:get-treebank($author, $work) {
    let $body := dblazy:get-flatbank($author, $work)
    let $tei := db:get("lit", `{$author}/{$work}`)[1]
    let $titleStmt := $tei/TEI/teiHeader/fileDesc/titleStmt
    return xslt:transform($body, $r:xslt, {
      'title': `{$titleStmt/title/text()}`,
      'author': $titleStmt/author/text()
    })
};


declare
  %rest:path("/read/{$author}/{$work}/{$part}")
  %rest:single
  %output:method("html")
  function r:get-part($author, $work, $part) {
    let $path := string-join(($author, $work, $part), '/')
    let $_ := message($path)
    let $tb := dblazy:get-flatbank($author, $work)
    return xslt:transform($tb, $r:xslt, {
      'title': 'Unknown',
      'author': 'Unknown'
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
