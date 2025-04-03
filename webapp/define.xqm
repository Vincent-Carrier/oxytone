module namespace def = "oxytone/define";
import module namespace xsm = "xsm";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $def:xslt := xsm:stylesheet(
  {
    "body":
      <div>
        <xsl:apply-templates select="lemma" />
      </div>,
    "lemma":
      <dl>
        <xsl:apply-templates select="entryFree" />
      </dl>,
    "shortdef":
      <dd class="shortdef">
        <xsl:value-of select="." />
      </dd>,
    "entryFree": (
      <dt>
        <xsl:value-of select="orth"/>
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
      <strong>
        <xsl:value-of select="concat(' ', ., ' ')"/>
      </strong>,
    "bibl":
      <span class="bibl">
        <xsl:value-of select="." />
      </span>,
    '*[@lang="greek"]':
      <span class="greek">
        <xsl:value-of select="." />
      </span>
  }
);

declare
  %rest:path("define/lsj/{$lemma}")
  %output:method("xml")
  function def:get-definition($lemma) {
    let $_ := prof:sleep(1500)
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
