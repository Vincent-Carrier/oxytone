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
    (: Senses are all but flat in LSJ — @level, not nesting, carries the depth
       (1 → A, 2 → II, 3 → 2, 4 → b), so they're selected flat and @level drives
       the indent. Of 62k senses sampled, only 3 actually nest. :)
    "entryFree": (
      (: Gender leads the headword (τό ἀβάκιον), and the separator only appears
         when there is a gender to separate — otherwise the dt opened with a
         stray space. :)
      <dt>
        <xsl:value-of select="string-join(((.//gen)[1], string-join(orth, ', '))[. != ''], ' ')"/>
      </dt>,
      <div class="meanings">
        <xsl:apply-templates select="../shortdef" />
        <xsl:choose>
          <xsl:when test=".//sense">
            <xsl:variable name="pre"
              select="node()[not(self::orth or self::gen)][not(self::sense)][not(.//sense)]
                            [not(preceding-sibling::sense or ancestor::sense)]"/>
            <xsl:if test="normalize-space(replace(string-join($pre, ''), '[\s,;:()\[\]]', ''))">
              <dd class="preamble">
                <!-- The commas separating orth from gen are their own text
                     nodes, so dropping those elements orphans them here. -->
                <xsl:variable name="html"><xsl:apply-templates select="$pre"/></xsl:variable>
                <xsl:for-each select="$html/node()">
                  <xsl:choose>
                    <xsl:when test="position() = 1 and self::text()">
                      <xsl:value-of select="replace(., '^[\s,;:]+', '')"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </dd>
            </xsl:if>
            <xsl:for-each select=".//sense">
              <dd class="sense" data-level="{{@level}}">
                <xsl:if test="@n">
                  <span class="sense-n"><xsl:value-of select="@n"/>.</span>
                </xsl:if>
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
    (: Etymologies live in tr, which is where nearly all the unresolved
       beta-code entities sit (sṃ-soq[uglide]-iyo-). :)
    "tr": (
      <xsl:call-template name="gap"/>,
      <strong><xsl:value-of select="oxy:betacode(normalize-space(.))"/></strong>),
    "ref": (
      <xsl:call-template name="gap"/>,
      <ox-ref><xsl:value-of select="normalize-space(.)" /></ox-ref>),
    (: Citations indent author/title/biblScope onto their own lines, so the
       string value would carry that indentation into the output; join the
       parts on a single space instead. The gap goes outside the span so it
       isn't caught by the span's own styling. :)
    "bibl": (
      <xsl:call-template name="gap"/>,
      <span class="bibl">
        <xsl:value-of select="string-join(.//text()[normalize-space()]!normalize-space(), ' ')"/>
      </span>),
    (: Grammar labels: gram (voice/dialect) alongside the tense, mood, person
       and number markers, which all read the same way. :)
    "gram|tns|mood|pos|number|per|itype|gen": (
      <xsl:call-template name="gap"/>,
      <span class="gram">
        <xsl:value-of select="string-join(.//text()[normalize-space()]!normalize-space(), ' ')"/>
      </span>),
    (: Greek: headwords cited inside a sense, and quoted passages. :)
    "foreign|quote": (
      <xsl:call-template name="gap"/>,
      <span class="grc"><xsl:value-of select="normalize-space(.)"/></span>),
    "etym": (
      <xsl:call-template name="gap"/>,
      <span class="etym"><xsl:value-of select="normalize-space(.)"/></span>),
    "lbl|abbr": (
      <xsl:call-template name="gap"/>,
      <span class="lbl"><xsl:value-of select="normalize-space(.)"/></span>),
    "pron": (
      <xsl:call-template name="gap"/>,
      <span class="pron"><xsl:value-of select="normalize-space(.)"/></span>),
    "date": (
      <xsl:call-template name="gap"/>,
      <span class="date"><xsl:value-of select="normalize-space(.)"/></span>),
    (: Containers whose children already have templates. Without these they
       fall through to the bare text() rule and lose all their markup. :)
    "cit|gramGrp|xr":
      <xsl:apply-templates />,
    (: Whitespace-only nodes are pure indentation; dropping them keeps oxy:gap
       from doubling up with a space that is already there. :)
    "text()[not(normalize-space())]": (),
    "text()[contains(., 'gen.')]": (
      <xsl:call-template name="gap"/>,
      <xsl:sequence>
        <xsl:analyze-string select="." regex="(gen\.)">
          <xsl:matching-substring>
            <span class="case gen"><xsl:value-of select="."/></span>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:sequence>),
    "text()[contains(., 'dat.')]": (
      <xsl:call-template name="gap"/>,
      <xsl:sequence>
        <xsl:analyze-string select="." regex="(dat\.)">
          <xsl:matching-substring>
            <span class="case dat"><xsl:value-of select="."/></span>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:sequence>),
    "text()[contains(., 'acc.')]": (
      <xsl:call-template name="gap"/>,
      <xsl:sequence>
        <xsl:analyze-string select="." regex="(acc\.)">
          <xsl:matching-substring>
            <span class="case acc"><xsl:value-of select="."/></span>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:sequence>),
    "text()": (
      <xsl:call-template name="gap"/>,
      <xsl:value-of select="oxy:betacode(normalize-space(.))" />)
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
