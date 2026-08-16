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

(: A passage's text, with the editorial apparatus left out. Two kinds of it sit
   inline and splice into the sentence if the string value is taken whole:

   <reg> holds a Getty-thesaurus regularization beside the reading text, so
   Herodotus is "of Bodrum [27.466,37.5] (inhabited place), Mugla Ili…
   Halicarnassus" rather than "of Halicarnassus".

   <note> holds a footnote whose body is usually its marker digit, so the Loeb
   Odyssey reads "flashing-eyed1 Athena". Dropping it loses the note itself, which
   this view does not show anyway.

   A <milestone/> line marker carries no text of its own, and the edition leans on
   it for the break, so the text nodes on either side run together as "upon the
   sea,seeking to win". It contributes a space; joining every node on one instead
   would space the punctuation off its word ("citadel of Troy ."), since
   <placeName>Troy</placeName> and the period that follows are separate nodes.

   Dropping an inline element leaves the whitespace that surrounded it, which then
   sits in front of the following punctuation — "of Halicarnassus , so that". The
   final replace closes that gap up. :)
declare %private function tr:text($passage as element()) as xs:string {
  let $text := normalize-space(string-join(
    $passage//node()[self::text() or self::*:milestone]
      [not(ancestor::*:reg or ancestor::*:note)]
      ! (if (self::*:milestone) then ' ' else string(.))
  ))
  return replace($text, '\s+([,.;:!?’”)])', '$1')
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
        (: <hgroup> and <main> as siblings rather than inside a wrapper:
           treebank.css styles the heading with `& > hgroup` on .treebank, so a
           wrapping div here would put it a level too deep and drop the styles. :)
        return (
            <hgroup>
              <h1>{normalize-space(string(($tei//*:titleStmt/*:title)[1]))}</h1>
              <p class="author">{normalize-space(string(($tei//*:titleStmt/*:author)[1]))}</p>
            </hgroup>,
            <main class="body" lang="en">{
              (: The marker shows the local number, as the Greek side does: the
                 page is already one book, so repeating it on every paragraph is
                 noise. The id keeps the full citation, which is what links. :)
              for $passage in $on-page
              let $cite := tr:cite($passage)
              return <p id="{$cite}"><a class="nbr section-nbr" href="#{$cite}">{
                string($passage/@n)
              }</a>{tr:text($passage)}</p>
            }</main>
          )
};
