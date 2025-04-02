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
          <xsl:value-of select="oxy:strip-diacritics(normalize-unicode(head/title, 'NFD'))" />
        </h1>
        <p class="author">
          <xsl:value-of select="head/author" />
        </p>
        <xsl:apply-templates select="head/books" />
      </hgroup>
      <main class="body" lang="grc">
        <xsl:apply-templates select="body" />
      </main>
    </div>,
  "books":
    <ol class="books">
      <xsl:apply-templates select="book" />
    </ol>,
  "book":
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('./', @id)" />
        </xsl:attribute>
        <xsl:value-of select="." />
      </a>
    </li>,
  "sentence":
    <span class="sentence">
      <xsl:apply-templates />
    </span>,
  "chapter":
    <section>
      <a class="nbr chapter-nbr">
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
      <a class="nbr section-nbr">
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
  "ln":
    <div class="line">
      <a class="nbr line-nbr">
        <xsl:copy-of select="@id" />
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', @id)" />
        </xsl:attribute>
        <xsl:value-of select="replace(@id, '\d+\.(\d+)$', '$1')" />
      </a>
      <span class="verse">
        <xsl:apply-templates />
      </span>
    </div>,
  "stephanus":
    <a class="nbr stephanus-nbr">
      <xsl:attribute name="href">
        <xsl:value-of select="concat('#', @id)" />
      </xsl:attribute>
      <xsl:attribute name="id">
        <xsl:value-of select="@id" />
      </xsl:attribute>
      <xsl:value-of select="@id" />
    </a>,
  "speaker":
    <xsl:sequence>
      <div class="speaker long">
        <xsl:value-of select="oxy:strip-diacritics(normalize-unicode(., 'NFD'))"/>
      </div>
      <div class="speaker short">
          <xsl:value-of select="concat(substring(oxy:strip-diacritics(normalize-unicode(., 'NFD')), 1, 2), '.')"/>
      </div>
      <div class="speaker mask">
          <xsl:value-of select="concat(substring(oxy:strip-diacritics(normalize-unicode(., 'NFD')), 1, 2), '.')"/>
      </div>
    </xsl:sequence>,
  "w":
    <ox-w>
      <xsl:copy-of select="@*" />
      <xsl:value-of select="oxy:strip-smooth-breathings(.)" />
    </ox-w>,
  "blockquote|p": xsm:keep("node()")
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
