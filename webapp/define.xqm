module namespace def = "oxytone/define";
import module namespace xsm = "xsm";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $def:xslt := xsm:stylesheet(
  {
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
        <xsl:for-each select=".//sense">
          <dd>
            <xsl:apply-templates />
          </dd>
        </xsl:for-each>
      </div>),
    "tr":
      <strong>
        <xsl:value-of select="concat('&#x20;', ., '&#x20;')"/>
      </strong>,
    "xr/ref[@lang='greek']":
      <button class="lemma-ref">
        {xsm:attr("lemma", ".")}
        <xsl:value-of select="." />
      </button>,
    "bibl": (),
    "text()": <xsl:value-of select="replace(., ',$|cf\.$', '')"/>
  },
  <xsl:preserve-space elements="*" />
);

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
