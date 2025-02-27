module namespace def = "oxytone/define";

declare variable $def:xslt :=
  <xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
      <xsl:output method="xml" indent="no" encoding="UTF-8"/>
      <xsl:template match="lemma">
        <dl>
          <xsl:apply-templates select="entryFree" />
        </dl>
      </xsl:template>
      <xsl:template match="shortdef">
        <dd class="shortdef">
          <xsl:value-of select="." />
        </dd>
      </xsl:template>
      <xsl:template match="entryFree">
        <dt>
          <xsl:value-of select="orth"/>
        </dt>
        <div class="meanings">
          <xsl:apply-templates select="../shortdef" />
          <xsl:for-each select=".//sense">
            <dd>
              <xsl:apply-templates />
            </dd>
          </xsl:for-each>
        </div>
      </xsl:template>
      <xsl:template match="tr">
        <strong>
          <xsl:value-of select="concat('&#x20;', ., '&#x20;')"/>
        </strong>
      </xsl:template>
      <xsl:template match="xr/ref[@lang='greek']">
        <button class="lemma-ref">
          <xsl:attribute name="lemma">
            <xsl:value-of select="." />
          </xsl:attribute>
          <xsl:value-of select="." />
        </button>
      </xsl:template>
      <xsl:template match="bibl">
      </xsl:template>
      <xsl:template match="text()">
        <xsl:value-of select="replace(., ',$|cf\.$', '')"/>
      </xsl:template>
      <xsl:preserve-space elements="*" />
  </xsl:stylesheet>;

declare
  %rest:path("define/lsj/{$lemma}")
  %rest:GET
  %output:method("html")
  function def:getDefinition($lemma) {
    let $_ := store:read("lsj_shortdefs")
    let $entry := <div>
      {
        for $path in db:list("lsj", $lemma)
          let $shortdef := store:get($path)
          return <lemma key="{$path}">
            {if ($shortdef) then <shortdef>{$shortdef}</shortdef>}
            {db:get("lsj", $path)}
          </lemma>
      }
    </div>
    return xslt:transform($entry, $def:xslt)
};
