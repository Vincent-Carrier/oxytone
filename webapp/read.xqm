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
      </hgroup>
      <main class="body">
        <xsl:apply-templates select="body" />
      </main>
    </div>,
  "sentence":
    <span class="sentence">
      <a class="sentence-nbr">
        <xsl:attribute name="href">
          <xsl:value-of select="concat('#', @id)" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:value-of select="@id" />
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
          <xsl:value-of select="concat('#', @id)" />
        </xsl:attribute>
        <xsl:attribute name="id">
          <xsl:value-of select="@id" />
        </xsl:attribute>
        <xsl:value-of select="@id" />
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
        <xsl:value-of select="replace(@id, '\d+\.(\d+)$', '$1')" />
      </a>
      <span class="verse">
        <xsl:apply-templates />
      </span>
    </div>,
  "speaker":
    <div class="speaker group">
      <span class="short">
        <xsl:value-of select="substring(oxy:strip-diacritics(normalize-unicode(., 'NFD')), 1, 2)"/>
      </span>
      <span class="long">
        <xsl:value-of select="oxy:strip-diacritics(normalize-unicode(., 'NFD'))"/>
      </span>
    </div>,
  "w":
    <ox-w>
      <xsl:copy-of select="@*" />
      <xsl:value-of select="oxy:strip-smooth-breathings(.)" />
    </ox-w>,
  "hr": <div class="flex"><div class="line-nbr"></div><hr /></div>,
  "blockquote|p": xsm:keep("node()"),
  "br": xsm:keep()
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
