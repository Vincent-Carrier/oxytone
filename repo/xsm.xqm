module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare function xsm:stylesheet(
  $templates as map(xs:string, element()*),
  $body as element()* := (),
  $params as xs:string* := (),
  $method as xs:string := "xml",
  $indent as xs:string := "no"
) as element() {
  (: exclude-result-prefixes keeps these declarations off the output element.
     Every caller shares this stylesheet, so without it the treebank's
     #tb-content div carries stray xmlns:* attributes too. :)
  <xsl:stylesheet version="3.0" xmlns:oxy="http://oxytone.xyz/functions"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="oxy map xs">
    <xsl:output method="{$method}" indent="{$indent}" encoding="UTF-8"/>
    <xsl:function name="oxy:normalize-punct">
      <xsl:param name="text"/>
      <xsl:value-of select="$text
        => replace('\s*,\s*', ', ')
        => replace('\s*\.\s*', '. ')
        => replace('\s*;\s*', '; ')
        => replace('\s*:\s*', ': ')" />
    </xsl:function>
    <xsl:function name="oxy:strip-diacritics">
      <xsl:param name="text"/>
      <xsl:value-of select="replace($text, '\p{{M}}', '')" />
    </xsl:function>
    <xsl:function name="oxy:strip-smooth-breathings">
      <xsl:param name="text"/>
      <xsl:value-of select="$text => replace('^([αεηιυοω]{{1,2}})&#x0313;', '$1', 'i') => normalize-unicode('NFC')" />
    </xsl:function>
    <!-- Dictionary sources indent their markup, so the whitespace between two
         inline elements lives in the indentation and is lost to
         normalize-space. Rather than pad each template with literal spaces,
         synthesize the gap: true when something precedes this node, and
         neither this node opens with punctuation nor the previous one ends
         with an opening bracket. -->
    <!-- preceding:: is a reverse axis, so [1] is the *nearest* preceding text
         node and the walk stops there. Wrapping the step in parentheses first,
         as ($node/preceding::text()[...])[last()], forces the whole axis to be
         materialised on every call — O(n^2) over the entry, and 93% of the cost
         of rendering a long LSJ article (993ms -> 71ms for λόγος). -->
    <xsl:function name="oxy:gap">
      <xsl:param name="node"/>
      <xsl:variable name="prev" select="$node/preceding::text()[normalize-space()][1]"/>
      <xsl:sequence select="exists($prev) and not(matches(normalize-space($node), '^[,;:.!?)]')) and not(matches(normalize-space($prev), '[(]$'))"/>
    </xsl:function>
    <!-- xsl:text would lose its space to XQuery boundary-space stripping. -->
    <xsl:template name="gap">
      <xsl:if test="oxy:gap(.)"><xsl:value-of select="' '"/></xsl:if>
    </xsl:template>
    <!-- Perseus left some beta-code entities unresolved in the LSJ etymologies,
         as bracketed names: sṃ-soq[uglide]-iyo-, vl[ucaron]k[ucaron]. They are
         compositional — a base letter plus a diacritic suffix — so resolve them
         from the two tables rather than enumerating ~55 spellings. Only names
         matching that grammar are touched, which leaves genuine editorial
         brackets ([them], [good], [ἐστι]) alone. -->
    <xsl:variable name="oxy:betacode" as="map(xs:string, xs:string)">
      <xsl:map>
        <xsl:map-entry key="'schwa'" select="'ə'"/>
        <xsl:map-entry key="'san'" select="'ϻ'"/>
        <xsl:map-entry key="'yogh'" select="'ȝ'"/>
        <xsl:map-entry key="'uglide'" select="'ʷ'"/>
        <xsl:map-entry key="'koppa'" select="'ϙ'"/>
        <xsl:map-entry key="'digamma'" select="'ϝ'"/>
        <xsl:map-entry key="'root'" select="'√'"/>
        <xsl:map-entry key="'ngnull'" select="'ŋ'"/>
        <xsl:map-entry key="'nmacrnull'" select="'n̄'"/>
        <xsl:map-entry key="'mmacrnull'" select="'m̄'"/>
        <xsl:map-entry key="'macutenull'" select="'ḿ'"/>
        <xsl:map-entry key="'combacute'" select="'&#x0301;'"/>
      </xsl:map>
    </xsl:variable>
    <!-- Combining marks, applied after the base letter. 'null' marks a letter
         Perseus could not encode at all; a ring below is the usual convention
         for the syllabic/retroflex consonants it stands in for. -->
    <xsl:variable name="oxy:betadiacritic" as="map(xs:string, xs:string)">
      <xsl:map>
        <xsl:map-entry key="'caron'" select="'&#x030C;'"/>
        <xsl:map-entry key="'tilde'" select="'&#x0303;'"/>
        <xsl:map-entry key="'circ'" select="'&#x0302;'"/>
        <xsl:map-entry key="'dot'" select="'&#x0323;'"/>
        <xsl:map-entry key="'udot'" select="'&#x0323;'"/>
        <xsl:map-entry key="'macr'" select="'&#x0304;'"/>
        <xsl:map-entry key="'macracute'" select="'&#x0304;&#x0301;'"/>
        <xsl:map-entry key="'acute'" select="'&#x0301;'"/>
        <xsl:map-entry key="'ogon'" select="'&#x0328;'"/>
        <xsl:map-entry key="'strok'" select="'&#x0335;'"/>
        <xsl:map-entry key="'null'" select="'&#x0325;'"/>
      </xsl:map>
    </xsl:variable>
    <xsl:function name="oxy:betacode-name" as="xs:string?">
      <xsl:param name="name"/>
      <xsl:variable name="n" select="normalize-space($name)"/>
      <xsl:variable name="base" select="substring($n, 1, 1)"/>
      <xsl:variable name="suffix" select="substring($n, 2)"/>
      <xsl:sequence select="
        if (map:contains($oxy:betacode, $n))
        then $oxy:betacode($n)
        else if (matches($base, '^[a-z]$') and map:contains($oxy:betadiacritic, $suffix))
        then normalize-unicode($base || $oxy:betadiacritic($suffix), 'NFC')
        else ()"/>
    </xsl:function>
    <!-- Returns the text with every recognized entity replaced, others intact. -->
    <xsl:function name="oxy:betacode" as="xs:string">
      <xsl:param name="text"/>
      <xsl:variable name="parts" as="xs:string*">
        <xsl:analyze-string select="$text" regex="\[([a-z][a-z]+) *\]">
          <xsl:matching-substring>
            <xsl:sequence select="(oxy:betacode-name(regex-group(1)), string(.))[1]"/>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:sequence select="string(.)"/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:variable>
      <xsl:sequence select="string-join($parts, '')"/>
    </xsl:function>
    {for $param in $params
      return <xsl:param name="{$param}" />}
    {for key $match value $template in $templates
      return <xsl:template match="{$match}">
        {$template}
      </xsl:template>}
    {$body}
  </xsl:stylesheet>
};

declare function xsm:attr($name as xs:string, $value as xs:string) as element() {
    <xsl:attribute name="{$name}">
      <xsl:value-of select="{$value}" />
    </xsl:attribute>
};

declare function xsm:keep($select as xs:string := "@*|node()") as element() {
  <xsl:copy>
    <xsl:apply-templates select="{$select}" />
  </xsl:copy>
};
