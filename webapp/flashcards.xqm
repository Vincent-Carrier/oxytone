module namespace fc = "oxytone/flashcards";
import module namespace def = "oxytone/define" at "define.xqm";

(: Builds an Anki-importable CSV from the selected lemmas. Each row is a Basic
   note: Front = lemma, Back = the same LSJ definition HTML the /define endpoint
   serves, tagged `author-… work-…`. The leading #-directives tell Anki how to
   read the file (tab-separated, HTML enabled, Basic note type, target deck, and
   which column holds the tags); csv:serialize handles the quoting of fields that
   contain tabs, commas, quotes or newlines. :)
declare
  %rest:path("flashcards")
  %rest:query-param("author", "{$author}")
  %rest:query-param("work", "{$work}")
  %rest:query-param("w", "{$w}")
  %rest:GET
  %output:method("text")
  function fc:flashcards($author, $work, $w as xs:string*) {
    let $tags := `author-{$author} work-{$work}`
    let $rows :=
      <csv>{
        for $lemma in $w
        return <record>
          <front>{$lemma}</front>
          <back>{serialize(def:definition-html($lemma))}</back>
          <tags>{$tags}</tags>
        </record>
      }</csv>
    let $body := csv:serialize($rows,
      { 'field-delimiter': codepoints-to-string(9), 'header': false() })
    let $directives := string-join((
      '#separator:Tab',
      '#html:true',
      '#notetype:Basic',
      '#deck:Greek Vocabulary',
      '#tags column:3',
      ''), codepoints-to-string(10))
    return (
      web:response-header(
        { 'media-type': 'text/csv; charset=utf-8' },
        { 'Content-Disposition': 'attachment; filename="greek-flashcards.csv"' }),
      $directives || $body
    )
};
