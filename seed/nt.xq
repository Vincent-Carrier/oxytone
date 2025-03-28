import module namespace p = 'paginate';
import module namespace pt = 'postag';

let $nt := doc('./treebanks/greek-nt.xml')
for $div at $i in $nt/proiel/source/div
  let $title := lower-case($div/title) => tokenize()
  let $book := string-join($title[1 to last() - 1], '_')
  group by $book
  for $d at $j in $div
    let $path := `nt/{$i[1]}_{$book}/{$j}`
    let $_ := message($path)
    let $tb := <treebank>
      <head>
        {$d/title}
      </head>
      <body>{
        for tumbling window $verse in $d//sentence/token
          end $e next $n when $e/@citation-part != $n/@citation-part
          return <verse id="{$e/@citation-part}">
              {$verse !
                <w>
                  {for key $k value $v in
                    {'sentence': ../@id, 'id': @id, 'head': @head-id,
                    'lemma': @lemma, 'relation': @relation}
                    return if ($v != "") then attribute {$k} {$v}
                  }
                  {pt:proiel-pos(@part-of-speech)}
                  {pt:expand-proiel(@morphology)}
                  {@form || @presentation-after}
                </w>}
                &#x20;
            </verse>
      }</body>
    </treebank>
    let $_ := db:put('flatbanks', $tb, $path)
    return $tb
