module namespace n = "normalize";
import module namespace pt = "postag";
import module namespace p = 'paginate';
import module namespace m = 'merge';

declare function n:style($author, $work) {
  let $_ := store:read('glaux')
  let $meta := store:get(`{$author}/{$work}`)
  return switch ($meta?genre)
    case ("Epic poetry", "Lyric poetry") return "verse"
    case ("Tragedy", "Comedy") return "theater"
    case ("Philosophic Dialogue", "Dialogue") return "dialogue"
    default return "prose"
};

declare function n:normalize-verse($tb) as element()* {
  for tumbling window $line in $tb//word[not(@artificial)]
    end $e next $n
    when $e/@line != $n/@line
    return n:line($line, $e/@line)
};

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

declare function n:pad-right($w, $n) {
  not($n/@form = ("]", ")", "”", "·", ",", ";", ":", "."))
  and not($w/@form = ("[", "(", "“"))
  and not(matches($w/@form, '’$'))
  and $n/@lemma != "τε"
};

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

declare %public function n:get-normalized($author, $work, $page := ()) {
  let $tb := db:get('glaux', `{$author}/{$work}/`)[1]
  let $style := trace(n:style($author, $work), "STYLE: ")
  let $pager := p:pager(`{$author}/{$work}`)
  let $paged := if (exists($pager)) then $pager?get($tb, $page) else $tb
  let $analysis := trace($paged/treebank/sentence[1]/@analysis, "===== ANALYSIS: ")
  let $fixed := $paged update {
    replace value of node filter(.//word[@form = '"'], fn ($w, $i) { $i mod 2 = 1 })/@form with '“'
  } update {
    replace value of node .//word[@form = '"']/@form with '”'
  } update {
    replace value of node .//word[@form = 'G?']/@form with '[…]'
  }
  let $normalized := $fixed => n:normalize($style) => m:merge($author, $work, $page)
  let $_ := store:read('glaux')
  let $meta := trace(store:get(`{$author}/{$work}`), "METADATA: ")
  return <treebank>
    <head>
      <title>{$meta?english-title}{if (exists($pager)) then `, {$pager?format($page)}`}</title>
      <author>{$meta?english-author}</author>
      {if (exists($pager)) then <books>
        {for $n in $pager?list
          return <book id="{$n}">{$pager?format($n)}</book>}
        </books>}
      <style>{$style}</style>
      <analysis>{$analysis/string()}</analysis>
    </head>
    {$normalized}
  </treebank>
};
