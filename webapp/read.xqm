module namespace r = "oxytone/read";
import module namespace xsm = "xsm";
import module namespace n = "normalize";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $r:xslt := xsm:stylesheet({
  "/treebank":
    <div id="tb-content">
      {xsm:attr('class', "concat('treebank ', head/style)")}
      {xsm:attr('data-analysis', 'head/analysis')}
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
        {xsm:attr("href", "concat('./', @id)")}
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
        {xsm:attr("href", "concat('#', @id)")}
        {xsm:attr("id", "@id")}
        <xsl:value-of select="@id" />
      </a>
      <xsl:apply-templates />
    </section>,
  "section":
    <p>
      <a class="nbr section-nbr">
        {xsm:attr("href", "concat('#', @id)")}
        {xsm:attr("id", "@id")}
        <xsl:value-of select="@id" />
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
      <xsl:value-of select="normalize-unicode(., 'NFC')" />
    </ox-w>,
  "blockquote|p": xsm:keep("node()")
});

declare
  %updating
  %rest:path("/read/{$author}/{$work-page=.+}")
  %output:method("html")
  function r:get-page($author, $work-page) {
    let $wp := tokenize($work-page, '/')
    let $path := string-join(($author, $work-page), '/')
    let $tb := if (db:option('debug'))
      then n:get-normalized($author, $wp[1], $wp[2])
      else
        db:get('normalized', $path)[1]
        otherwise (
          let $normalized := n:get-normalized($author, $wp[1], $wp[2])
          let $_ := db:put('normalized', $normalized, $path)
          return $normalized
        )
    return xslt:transform($tb, $r:xslt)
};
