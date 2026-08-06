module namespace n = "normalize";
import module namespace pt = "postag";
import module namespace p = 'paginate';
import module namespace m = 'merge';

(: Normalization turns a GLAUx treebank — a flat stream of <sentence>/<word> with
   the structure carried on attributes — into a nested document the stylesheets in
   webapp/ can render directly. Which nesting a work gets depends on its genre;
   see n:normalize. :)

(: The layout a work is rendered in, from its GLAUx genre. :)
declare function n:style($author, $work) {
  let $_ := store:read('glaux')
  let $meta := store:get(`{$author}/{$work}`)
  return switch ($meta?genre)
    case ("Epic poetry", "Lyric poetry") return "verse"
    case ("Tragedy", "Comedy") return "theater"
    case ("Philosophic Dialogue", "Dialogue") return "dialogue"
    default return "prose"
};

(: The tumbling windows below are how the flat stream gets its nesting: each one
   closes a group when the attribute naming the division changes on the next node,
   so consecutive words sharing a @line become a line, consecutive sentences
   sharing a @speaker become a speech, and so on. Artificial words (GLAUx's
   elliptical placeholders) are dropped, having no surface form to display. :)

(: Verse: lines, with no higher grouping — the page is already one book. :)
declare function n:normalize-verse($tb) as element()* {
  for tumbling window $line in $tb//word[not(@artificial)]
    end $e next $n
    when $e/@line != $n/@line
    return n:line($line, $e/@line)
};

(: Drama: a speaker heading, then that speech's verse lines. :)
declare function n:normalize-theater($tb) as element()* {
  for tumbling window $speech in $tb//sentence
    end $e next $n
    when ($e/word/@speaker)[1] != ($n/word/@speaker)[1]
    return (
      <speaker>{$e/word[1]/@speaker/string()}</speaker>,
      for tumbling window $line in $speech//word[not(@artificial)]
        end $e next $n
        when $e/@line != $n/@line
        return n:line($line, $e/@line)
    )
};

(: Prose dialogue: a speaker heading, then that speech as a paragraph. :)
declare function n:normalize-dialogue($tb) as element()* {
  for tumbling window $speech in $tb//sentence
    end $e next $n
    when ($e/word/@speaker)[1] != ($n/word/@speaker)[1]
    return (
      <speaker>{$e/word[1]/@speaker/string()}</speaker>,
      <p>{for $sen in $speech
        return n:sentence($sen)}</p>
    )
};

(: Prose: chapters and sections, whichever of them the text actually carries.
   Editions divide prose inconsistently, so the branches run from finest to
   coarsest and take the first that applies — chapters subdivided into sections,
   else a single level of sections or fables rendered as chapters, else bare
   sentences. A <chapter> is therefore the outermost division present, not
   necessarily a chapter. :)
declare function n:normalize-prose($tb) as element()* {
  if (exists($tb//word/@div_chapter)) then
  	for tumbling window $chapter in $tb//sentence
  		end $e next $n
      when ($e/word/@div_chapter)[1] != ($n/word/@div_chapter)[1]
      return
        <chapter id="{($e/word/@div_chapter)[1]}">{
          for tumbling window $section in $chapter
            end $e next $n
            when ($e/word/@div_section)[1] != ($n/word/@div_section)[1]
            return <section id="{($e/word/@div_section)[1]}">{
        		  for $sen in $section
       			    return n:sentence($sen)
            }</section>
        }</chapter>
  else if (exists ($tb//word/@div_section)) then
    for tumbling window $section in $tb//sentence
      end $e next $n
      when ($e/word/@div_section)[1] != ($n/word/@div_section)[1]
      return <chapter id="{($e/word/@div_section)[1]}">{
  		  for $sen in $section
 			    return n:sentence($sen)
      }</chapter>
  else if (exists ($tb//word/@div_fable)) then
   	for tumbling window $fable in $tb//sentence
  		end $e next $n
      when ($e/word/@div_fable)[1] != ($n/word/@div_fable)[1]
      return
        <chapter id="{($e/word/@div_fable)[1]}">{
          for $sen in $fable
            return n:sentence($sen)
        }</chapter>
  else
    for $sen in $tb//sentence
      return n:sentence($sen)
};

declare function n:normalize($tb, $style := "prose") as element() {
  <body>{
    switch ($style)
      case "verse" return n:normalize-verse($tb)
      case "theater" return n:normalize-theater($tb)
      case "dialogue" return n:normalize-dialogue($tb)
      default return n:normalize-prose($tb)
  }</body>
};

(: One <w>, carrying everything the frontend's ox-w element reads: the dependency
   links, the sentence it belongs to, and the positional tag expanded into named
   morphology attributes. A leading or trailing hyphen marks an elided part of a
   crasis — the hyphen is dropped from the text, and a word that is only a trailing
   fragment is hidden, since the whole form is already shown on its other half. :)
declare function n:word($w) {
  element w {
    $w/@*[name()=("id", "head", "relation")],
    attribute sentence {$w/../@id},
    attribute lemma {normalize-unicode($w/@lemma, 'NFC')},
    if (matches($w/@form, "-$")) then attribute hidden {},
    if ($w/@postag) then pt:expand($w/@postag),
    concat(replace($w/@form, '^-(.*)', '$1'))
  }
};

(: Whether a space belongs between $w and the next word $n. Greek is not uniformly
   space-separated: closing punctuation and enclitics hug the word before them,
   opening brackets and an elided apostrophe hug the word after. :)
declare function n:pad-right($w, $n) {
  not($n/@form = ("]", ")", "”", "·", ",", ";", ":", "."))
  and not($w/@form = ("[", "(", "“"))
  and not(matches($w/@form, '’$'))
  and $n/@lemma != "τε"
};

(: A sentence's words, spaced. The sliding window pairs each word with the next so
   n:pad-right can see both, which also means the last word is never a window start
   — hence the trailing space added after the loop. Stephanus page markers are
   emitted at the point the page number changes. :)
declare function n:sentence($sen) {
  <sentence xml:space="preserve">{
    $sen/@*,
    for sliding window $win in $sen/word[not(@artificial)]
      start $w at $i end $n at $j
      when $j - $i = 1
      return (
        n:word($w),
        if (n:pad-right($w, $n)) then "&#x20;",
        if ($w/@div_stephanus_section != $n/@div_stephanus_section)
          then <stephanus id="{$n/@div_stephanus_section}" />
      ),
    "&#x20;"
  }</sentence>
};

(: One verse line, paired the same way as n:sentence. :)
declare function n:line($line, $id) {
  <ln id="{$id}" xml:space="preserve">{
    for sliding window $win in $line
      start $w at $i end $n at $j
      when $j - $i = 1
      return (
        n:word($w),
        if (n:pad-right($w, $n)) then "&#x20;"
      )
  }</ln>
};

(: The normalized <treebank> for one page of a work: a <head> of display metadata
   and page links, and the nested body. This is what webapp/read.xqm caches and
   both it and webapp/plain.xqm render. :)
declare %public function n:get-normalized($author, $work, $page := ()) {
  let $tb := db:get('glaux', `{$author}/{$work}/`)[1]
  let $style := n:style($author, $work)
  let $pager := p:pager(`{$author}/{$work}`)
  (: A paginated work requested with no page (read/tlg0012/tlg001) falls back to
     its first page, so the title and the body agree on which one was rendered. :)
  let $page := if (exists($pager)) then ($page otherwise head($pager?list)) else $page
  let $paged := if (exists($pager)) then $pager?get($tb, $page) else $tb
  let $analysis := $paged/treebank/sentence[1]/@analysis
  (: GLAUx leaves quotation marks as the ASCII " it inherited, so they are paired
     off into typographic quotes by position: odd occurrences open, even ones close.
     "G?" is its placeholder for an illegible passage. :)
  let $fixed := $paged update {
    replace value of node filter(.//word[@form = '"'], fn ($w, $i) { $i mod 2 = 1 })/@form with '“'
  } update {
    replace value of node .//word[@form = '"']/@form with '”'
  } update {
    replace value of node .//word[@form = 'G?']/@form with '[…]'
  }
  let $normalized := $fixed => n:normalize($style) => m:merge($author, $work, $page)
  let $_ := store:read('glaux')
  let $meta := store:get(`{$author}/{$work}`)
  return <treebank>
     <head>
      <title>{$meta?english-title}{if (exists($pager)) then `, {$pager?format($page)}`}</title>
      <author>{$meta?english-author}</author>
      {if (exists($pager)) then <books terse="{if ($pager?terse) then 'yes' else 'no'}">
        {for $n in $pager?list
          return <book id="{$n}">{$pager?label($n)}</book>}
        </books>}
      <style>{$style}</style>
      <analysis>{$analysis/string()}</analysis>
    </head>
    {$normalized}
  </treebank>
};
