module namespace idx = "oxytone/index";

declare variable $idx:xslt :=
  <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="no" encoding="UTF-8"/>
      <xsl:template match="/">
        <div>
          <xsl:for-each select="/div/author[.//tb]">
            <xsl:sort select="@name" />
            <div class="author">
              <h2>
                <xsl:value-of select="@name"/>
              </h2>
              <ul class="works">
                <xsl:for-each select="./work[tb]">
                  <xsl:sort select="./title[1]" />
                  <li>
                    <a>
                      <xsl:attribute name="href">
                        <xsl:value-of select="concat('/read/', ./tb/@path)" />
                      </xsl:attribute>
                      <xsl:value-of select="./title[1]" />
                    </a>
                  </li>
                </xsl:for-each>
              </ul>
            </div>
          </xsl:for-each>
        </div>
      </xsl:template>
  </xsl:stylesheet>;

declare %rest:path("")
        %rest:GET
        %output:method("html")
        function idx:get-index() {
  let $_ := store:read('glaux')
  for $k in store:keys()
    let $text := store:get($k)
    where $text?tokens > 500
    group by $genre := $text?genre
    return <section class="genre">
      <h2>{$genre}</h2>
      <ul class="authors">{
        for $author-in-genre in $text
          group by $author := $author-in-genre?author
          return
            <li>
              <h3>{$author}</h3>
              <ul class="works">
              {for $t in $author-in-genre
                return
                    <li>
                      <a href="{'/read/' || $t?tlg}">{$t?title}</a>
                    </li>}
              </ul>
            </li>
      }</ul>
    </section>
};
