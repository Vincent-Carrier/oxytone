module namespace r = "oxytone/read";
import module namespace xsm = "xsm";
import module namespace n = "normalize";
import module namespace urn = "urn";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

(: Author over title, the way a title page reads, and each navigation list under
   a heading of its own. The <hgroup> that used to wrap them is gone: it exists to
   tie a heading to its own subheading, and what follows the title here is two
   lists of links, not a tagline. :)
declare variable $r:xslt := xsm:stylesheet({
  "/treebank":
    <div id="tb-content">
      {xsm:attr('class', "concat('treebank ', head/style)")}
      {xsm:attr('data-analysis', 'head/analysis')}
      <header class="work">
        <p class="author">
          <xsl:value-of select="head/author" />
        </p>
        <h1>
          <xsl:value-of select="oxy:strip-diacritics(normalize-unicode(head/title, 'NFD'))" />
        </h1>
        <xsl:apply-templates select="head/translations" />
        <xsl:apply-templates select="head/books" />
      </header>
      <xsl:apply-templates select="head/pages" />
      <main class="body" lang="grc">
        <xsl:apply-templates select="body" />
      </main>
      <xsl:apply-templates select="head/pages" />
    </div>,
  (: The English translations of this work, each named by its translator so the
     choice is between people rather than between opaque edition ids. Above the
     page list because it is a choice about the whole work, where that is a
     choice within it.

     data-single marks the ordinary case — 507 of the 634 translated works have
     exactly one edition — which treebank.css renders as a plain credited link
     rather than a list of one. :)
  "translations":
    <nav class="nav-group translations">
      {xsm:attr("data-single", "if (count(translation) = 1) then 'yes' else 'no'")}
      <h2>Translations</h2>
      <ul>
        <xsl:apply-templates select="translation" />
      </ul>
    </nav>,
  (: "Translator (year)", the whole of it the link. The date earns its place by
     telling apart translations of the same text a century apart, and belongs
     inside the link because it names the same thing the translator does.

     Parenthesised only when there is a year: 11 of the 770 editions have no
     usable imprint date, and an empty "()" after a name reads as broken. :)
  "translation":
    <li>
      <a>
        {xsm:attr("href",
          "concat('/translation/', ../@urn, '?ed=', encode-for-uri(@edition))")}
        <xsl:value-of select="." />
        <xsl:if test="@date != ''">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="@date" />
          <xsl:text>)</xsl:text>
        </xsl:if>
      </a>
    </li>,
  (: Step to the page either side of this one, above and below the text, so a
     reader who has finished a book is not sent back to the page list to start
     the next. Rendered from the same <pages> element in both places.

     The ends of a work leave one side absent rather than disabled: a control
     that cannot act is still a target, and "Book 1" has no previous.

     rel=prev/next is what the markup is for, and Firefox and Safari prefetch on
     it; the class carries the position so the CSS can space the two apart. :)
  "pages":
    <nav class="nav-group pages">
      <xsl:apply-templates select="prev" />
      <xsl:apply-templates select="next" />
    </nav>,
  "prev":
    <a class="page-step prev" rel="prev">
      {xsm:attr("href", "concat('/read/', ../@urn, '/', @id)")}
      <span class="arrow" aria-hidden="true">&#8592;</span>
      <span class="label"><xsl:value-of select="." /></span>
    </a>,
  "next":
    <a class="page-step next" rel="next">
      {xsm:attr("href", "concat('/read/', ../@urn, '/', @id)")}
      <span class="label"><xsl:value-of select="." /></span>
      <span class="arrow" aria-hidden="true">&#8594;</span>
    </a>,
  (: data-terse drives the dense numeral grid in treebank.css. The heading is the
     division's own plural — "Books", "Fables", "Psalms" — rather than a fixed
     word, so it agrees with the entries beneath it. :)
  "books":
    <nav class="nav-group books">
      {xsm:attr("data-terse", "@terse")}
      <h2><xsl:value-of select="@heading" /></h2>
      <ol>
        <xsl:apply-templates select="book" />
      </ol>
    </nav>,
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
  (: A span rather than an <ox-w>: the words stopped being custom elements when a
     page of 33,000 of them made registering a component apiece cost half a second
     of upgrade, and a tag that looks bespoke invites the reader to expect one.
     The class is what the CSS and the click handler match on — `span` alone would
     also catch the sentence wrapper above. :)
  "w":
    <span class="w">
      <xsl:copy-of select="@*" />
      <xsl:value-of select="normalize-unicode(., 'NFC')" />
    </span>,
  "blockquote|p": xsm:keep("node()")
});

(: One page of a text, as the #tb-content markup the frontend renders as words.
   Cached in the `normalized` database write-through: the first request for a page
   pays for it and every later one is a lookup.

   The *rendered* markup is what is stored, not the normalized tree it came from.
   Both halves are expensive at the sizes this corpus reaches — normalizing a book
   of Herodotus, and then transforming its 33,000 words through the stylesheet,
   which alone took about two seconds and used to run on every request, cache hit
   or not. Storing the output makes a hit a read and nothing else.

   The cost of that is a cache keyed to the stylesheet as well as to the
   normalization: edit either and the entries are stale, where before a stylesheet
   change took effect immediately. `just normalized` recreates the database empty,
   which is the fix, and the `debug` option bypasses the cache while working on
   the XQuery. :)
declare
  %updating
  %rest:path("/read/{$author}/{$work-page=.+}")
  %output:method("html")
  function r:get-page($author, $work-page) {
    let $wp := urn:work-page($work-page)
    let $path := string-join(($author, $work-page), '/')
    let $cached := db:get('normalized', $path)[1]
    return
      if (db:option('debug'))
        then update:output(r:render(n:get-normalized($author, $wp?work, $wp?page)))
      else if (exists($cached))
        then update:output($cached)
      else
        (: db:put and update:output are both updating expressions, so the whole
           function is %updating and needs no MIXUPDATES. :)
        let $rendered := r:render(n:get-normalized($author, $wp?work, $wp?page))
        return (
          db:put('normalized', $rendered, $path),
          update:output($rendered)
        )
};

declare function r:render($tb) {
  xslt:transform($tb, $r:xslt)
};
