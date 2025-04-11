module namespace def = "oxytone/define";
import module namespace xsm = "xsm";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $def:xslt := xsm:stylesheet(
  {
    "body":
      <div><xsl:apply-templates select="lemma" /></div>,
    "lemma":
      <dl><xsl:apply-templates select="entryFree" /></dl>,
    "shortdef":
      <dd class="shortdef"><xsl:value-of select="." /></dd>,
    "entryFree": (
      <dt>
        <xsl:value-of select="concat(.//gen[1], ' ')"/>
        <xsl:value-of select="string-join(orth, ', ')"/>
      </dt>,
      <div class="meanings">
        <xsl:apply-templates select="../shortdef" />
        <xsl:choose>
          <xsl:when test=".//sense">
            <xsl:for-each select=".//sense">
              <dd>
                <xsl:apply-templates />
              </dd>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <dd>
              <xsl:apply-templates select="*[not(self::orth)]"/>
            </dd>
          </xsl:otherwise>
        </xsl:choose>
      </div>),
    "tr":
      <strong><xsl:value-of select="concat(' ', ., ' ')"/></strong>,
    "ref":
      <ox-ref><xsl:value-of select="." /></ox-ref>,
    "bibl":
      <span class="bibl"><xsl:value-of select="." /></span>,
    "gram":
      <span class="gram"><xsl:value-of select="." /></span>,
    "text()[contains(., 'gen.')]":
      <xsl:sequence>
        <xsl:analyze-string select="." regex="(gen\.)">
          <xsl:matching-substring>
            <span class="case gen"><xsl:value-of select="."/></span>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:sequence>,
    "text()[contains(., 'dat.')]":
      <xsl:sequence>
        <xsl:analyze-string select="." regex="(dat\.)">
          <xsl:matching-substring>
            <span class="case dat"><xsl:value-of select="."/></span>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:sequence>,
    "text()[contains(., 'acc.')]":
      <xsl:sequence>
        <xsl:analyze-string select="." regex="(acc\.)">
          <xsl:matching-substring>
            <span class="case acc"><xsl:value-of select="."/></span>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:sequence>,
    "text()":
      <xsl:value-of select="normalize-space(.)" />
  }
);

declare
  %rest:path("define/lsj/{$lemma}")
  function def:get-definition($lemma) {
    let $_ := store:read("lsj_shortdefs")
    let $entry := <body>
      {
        for $path in db:list("lsj", $lemma)
          let $shortdef := store:get($path)
          return <lemma key="{$path}">
            {if ($shortdef) then <shortdef>{$shortdef}</shortdef>}
            {db:get("lsj", $path)}
          </lemma>
      }
    </body>
    return xslt:transform($entry, $def:xslt)
};
