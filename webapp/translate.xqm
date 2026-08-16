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

(: The div chain a passage sits under, outermost first, skipping the edition
   wrapper whose @n is the work's URN rather than a citation. :)
declare %private function tr:chain($passage as element()) as xs:string* {
  $passage/ancestor-or-self::*:div[@n]
    [not(lower-case((@subtype, @type)[1]) = ('edition', 'translation'))]
    ! string(@n)
};

(: A passage's full dotted citation, "2.35.1" rather than the "1" its own @n
   carries. Chapter and section numbering restarts in every book, so the local
   number alone repeats across the work — it would collide as an id, and it is the
   dotted form that GLAUx's @div_section holds and repo/cite.xqm joins on. :)
declare %private function tr:cite($passage as element()) as xs:string {
  string-join(tr:chain($passage), '.')
};

(: The page a passage belongs to: the leading segment of its citation, so section
   1.32.4 of Herodotus is on book 1. :)
declare %private function tr:page-of($passage as element()) as xs:string {
  head(tr:chain($passage))
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
          else $passages[tr:page-of(.) = string($page)]
        return
          <div class="translation" lang="en">
            <hgroup>
              <h1>{normalize-space(string(($tei//*:titleStmt/*:title)[1]))}</h1>
              <p class="author">{normalize-space(string(($tei//*:titleStmt/*:author)[1]))}</p>
            </hgroup>
            <main class="body">{
              for $passage in $on-page
              let $cite := tr:cite($passage)
              return <p id="{$cite}">
                (: Labelled with the local number, as the Greek side is: the page
                   is already one book, so repeating it on every paragraph is
                   noise. The id keeps the full citation for linking. :)
                <a class="nbr section-nbr" href="#{$cite}">{string($passage/@n)}</a>
                {tr:text($passage)}
              </p>
            }</main>
          </div>
};
