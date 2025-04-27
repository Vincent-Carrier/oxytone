module namespace pl = "oxytone/plain";
import module namespace xsm = "xsm";
import module namespace n = "normalize";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $pl:xslt := xsm:stylesheet({
  "/treebank":
    <body>
      <hgroup>
        <h1>
          <xsl:value-of select="oxy:strip-diacritics(normalize-unicode(head/title, 'NFD'))" />
        </h1>
        <p class="author">
          <xsl:value-of select="head/author" />
        </p>
      </hgroup>
      <main class="body" lang="grc">
        <xsl:apply-templates select="body" />
      </main>
    </body>,
  "sentence":
    <span class="sentence">
      <xsl:apply-templates />
    </span>,
  "section":
    <p>
      <a class="nbr section-nbr">
        {xsm:attr("href", "concat('#', @id)")}
        {xsm:attr("id", "@id")}
        <xsl:value-of select="concat('#section-ref[', @id, '] ')" />
      </a>
      <xsl:apply-templates />
    </p>,
  "ln":
    <xsl:sequence>
      <a class="nbr line-nbr">
        <xsl:copy-of select="@id" />
        {xsm:attr("href", "concat('#', @id)")}
        {xsm:attr("id", "@id")}
        <xsl:value-of select="replace(@id, '\d+\.(\d+)$', '$1')" />
      </a>
      <div class="line">
        <xsl:apply-templates />
      </div>
    </xsl:sequence>,
  "stephanus":
    <a class="nbr stephanus-nbr">
      {xsm:attr("href", "concat('#', @id)")}
      {xsm:attr("id", "@id")}
      <xsl:value-of select="@id" />
    </a>,
  "speaker":
    <div class="speaker">
      <xsl:value-of select="oxy:strip-diacritics(normalize-unicode(., 'NFD'))"/>
    </div>,
  "w":
    <span>
      <xsl:copy-of select="@*" />
      <xsl:choose>
        <xsl:when test="@pos='verb' and @person">
          <xsl:value-of select="concat('*', oxy:strip-smooth-breathings(.), '* ')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="oxy:strip-smooth-breathings(.)" />
        </xsl:otherwise>
      </xsl:choose>
    </span>,
  "blockquote|p": xsm:keep("node()")
});

declare
  %rest:path("/plain/{$author}/{$work-page=.+}")
  %output:method("html")
  function pl:get-page($author, $work-page) {
    let $wp := tokenize($work-page, '/')
    let $path := string-join(($author, $work-page), '/')
    let $tb := n:get-normalized($author, $wp[1], $wp[2])
    return xslt:transform($tb, $pl:xslt)
};
