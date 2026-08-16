module namespace tr = "oxytone/translate";
import module namespace p = "paginate";
import module namespace urn = "urn";

(: The English translation of one page of a work, from the Perseus editions
   `just translations` puts in the `translations` DB.

   A page is a range of citations rather than a document, so the translation is
   assembled by keeping the TEI blocks whose own citation falls on the requested
   page. Which citation that is varies by work — see repo/cite.xqm — so the key is
   resolved per request against the treebank rather than assumed.

   Most works have no translation: 128 of the 180 that paginate. That returns an
   empty <translation>, not an error, and the frontend hides the link. :)

(: The lowest div that carries a citation, i.e. the blocks the reader actually
   sees. A <div> holding only other divs is structure, not a passage. :)
declare %private function tr:passages($tei as node()) as element()* {
  $tei//*:div[@n][not(*:div)]
};

(: A passage's text. Perseus regularizes place names against the Getty thesaurus
   and keeps both forms — <reg>Bodrum [27.466,37.5] (inhabited place), Mugla
   Ili…</reg> beside <placeName>Halicarnassus</placeName> — so taking the string
   value whole splices a gazetteer entry into the middle of the sentence. The
   <reg> is apparatus; the reading text is what is left. :)
declare %private function tr:text($passage as element()) as xs:string {
  normalize-space(string-join($passage//text()[not(ancestor::*:reg)]))
};

(: The page a passage belongs to, which is the leading segment of its citation
   under the page division: section 1.32.4 of Herodotus is on book 1. Cards
   number from the line they start at, so a card's own @n is its position within
   the book, not the book — hence the walk up to the enclosing book div. :)
declare %private function tr:page-of($passage as element(), $depth as xs:integer) as xs:string {
  let $chain := ($passage/ancestor-or-self::*:div[@n]
                   [not(lower-case((@subtype, @type)[1]) = ('edition', 'translation'))])
  return string(($chain[$depth], $chain[last()])[1]/@n)
};

declare
  %rest:path("/translate/{$author}/{$work-page=.+}")
  %output:method("html")
  function tr:get-page($author, $work-page) {
    let $wp := urn:work-page($work-page)
    let $work := $wp?work
    let $tei := db:get('translations', `{$author}/{$work}`)[1]
    let $pager := p:pager(`{$author}/{$work}`)
    let $page := if (exists($pager)) then ($wp?page otherwise head($pager?list)) else $wp?page
    return
      if (empty($tei)) then <div class="translation" data-empty="yes" />
      else
        let $passages := tr:passages($tei)
        (: Unpaginated works are read whole, so every passage belongs. :)
        let $on-page :=
          if (empty($page)) then $passages
          else $passages[tr:page-of(., 1) = string($page)]
        return
          <div class="translation" lang="en">
            <hgroup>
              <h1>{normalize-space(string(($tei//*:titleStmt/*:title)[1]))}</h1>
              <p class="author">{normalize-space(string(($tei//*:titleStmt/*:author)[1]))}</p>
            </hgroup>
            <main class="body">{
              for $passage in $on-page
              return <p id="{$passage/@n}">
                <a class="nbr section-nbr" href="#{$passage/@n}">{string($passage/@n)}</a>
                {tr:text($passage)}
              </p>
            }</main>
          </div>
};
