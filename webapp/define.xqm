module namespace def = "oxytone/define";
import module namespace xsm = "xsm";
declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $def:xslt := xsm:stylesheet(
  {
    (: Each source is wrapped in its own section so the Svelte component can
       anchor that source's external link at the bottom of it (see
       src/lib/components/definition.svelte). :)
    "body":
      <div>
        <xsl:apply-templates select="wiktionary" />
        <xsl:if test="lemma">
          <section class="source" data-source="lsj">
            <h3 class="source-label">LSJ</h3>
            <xsl:apply-templates select="lemma" />
          </section>
        </xsl:if>
      </div>,
    "wiktionary":
      <section class="source" data-source="wiktionary">
        <h3 class="source-label">Wiktionary</h3>
        <dl class="wiktionary">
          <dt><xsl:value-of select="@lemma" /></dt>
          <xsl:apply-templates select="wsense" />
        </dl>
      </section>,
    (: Senses arrive pipe-joined from the TSV (seed/wiktionary.py); split them
       back out so each renders as its own list item. The pos label sits on its
       own line above the list, so bullets stay flush regardless of its width. :)
    "wsense":
      <dd class="wsense">
        <span class="pos"><xsl:value-of select="@pos" /></span>
        <ul class="senses">
          <xsl:for-each select="tokenize(., '\s*\|\s*')">
            <li><xsl:value-of select="." /></li>
          </xsl:for-each>
        </ul>
      </dd>,
    "lemma":
      <dl><xsl:apply-templates select="entryFree" /></dl>,
    "shortdef":
      <dd class="shortdef"><xsl:value-of select="." /></dd>,
    "entryFree": (
      <dt>
        <xsl:value-of select="concat((.//gen)[1], ' ')"/>
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

declare function def:definition-html($lemma) {
  let $_ := store:read("lsj_shortdefs")
  (: Exact key match, unlike the prefix match db:list does below: a lemma either
     has a Wiktionary entry or it doesn't. :)
  let $wikt := store:get(`wikt/{$lemma}`)
  let $entry := <body>
    {
      (: Emitted independently of the LSJ lookup — 5.4k lemmas (mostly Koine and
         Biblical proper nouns) have a Wiktionary gloss but no LSJ entry, and
         would otherwise render an empty document. :)
      if (exists($wikt)) then <wiktionary lemma="{$lemma}">{
        for $sense in $wikt?*
          return <wsense pos="{$sense?pos}">{$sense?def}</wsense>
      }</wiktionary>
    }
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

declare
  %rest:path("define/lsj/{$lemma}")
  function def:get-definition($lemma) {
    def:definition-html($lemma)
};
