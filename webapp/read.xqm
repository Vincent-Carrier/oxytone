module namespace r = "oxytone/read";
import module namespace xsm = "xsm";
import module namespace n = "normalize";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $r:xslt := xsm:stylesheet({
  "/treebank":
    <div>
      <xsl:attribute name="class">
        <xsl:value-of select="concat('treebank ', @style)" />
      </xsl:attribute>
      <hgroup>
        <h1>
          <xsl:value-of select="oxy:strip-diacritics(concat(head/title, ', ', head/page))" />
        </h1>
        <p class="author">
          <xsl:value-of select="oxy:strip-diacritics(head/author)" />
        </p>
      </hgroup>
      <div class="body">
        <xsl:apply-templates select="body" />
      </div>
    </div>,
  "sentence":
    <span class="sentence">
      <a class="sentence-nbr">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', replace(@id, '\w+ \d+\.(\d+)$', '$1'))" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="replace(@id, '\w+ \d+\.(\d+)$', '$1')" />
        </xsl:attribute>
        <xsl:value-of select="replace(@id, '\w+ \d+\.(\d+)$', '$1')" />
      </a>
      <xsl:apply-templates />
    </span>,
  "chapter":
    <section>
      <a class="chapter-nbr">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', @id)" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:value-of select="@id" />
      </a>
      <xsl:apply-templates />
    </section>,
  "section":
    <p>
      <a class="section-nbr">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', @id)" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:value-of select="@id" />
      </a>
      <xsl:apply-templates />
    </p>,
  "verse":
    <span class="verse">
      <a class="verse-nbr">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', replace(@id, '\w+ \d+\.(\d+)$', '$1'))" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="replace(@id, '\w+ \d+\.(\d+)$', '$1')" />
        </xsl:attribute>
        <xsl:value-of select="replace(@id, '\w+ \d+\.(\d+)$', '$1')" />
      </a>
      <xsl:apply-templates />
    </span>,
  "ln":
    <div class="line">
      <a class="line-nbr">
        <xsl:copy-of select="@id" />
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', @id)" />
        </xsl:attribute>
        <xsl:value-of select="@id" />
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
});


declare
  %rest:path("/read/{$author}/{$work-page=.+}")
  %rest:single
  %output:method("html")
  function r:get-page($author, $work-page) {
    let $wp := tokenize($work-page, '/')
    let $path := string-join(($author, $work-page), '/')
    let $tb := n:get-normalized($author, $wp[1], $wp[2])
    return xslt:transform($tb, $r:xslt)
};
