import module namespace m = "merge";

(: Homer :)
for key $tbPath value $teiPath in
map:build(db:list('flatbanks', 'tlg0012'), value := m:teiPath#1)
  let $tb := db:get("flatbanks", $tbPath)[1]
  let $tei := db:get("lit", $teiPath)[1]
  let $urn := tokenize($tbPath, '/')
  for $n in (1 to 24)
    let $teiBook := $tei//div[lower-case(@subtype)="book" and @n=$n]
    let $tbBook := $tb//ln[starts-with(@n, `{$n}.`)]
    let $merged := <treebank>
      <book n="{$n}">
        {
          for $el in $teiBook/*
          return typeswitch ($el) {
            case element(milestone)
              return if ($el/@unit = "card") then <hr />
            case element(l)
              return $tbBook[@n=concat($n, '.', $el/@n)]
            case element(q)
              return <blockquote>{
                for $ln in $el/l
                return $tbBook[@n=concat($n, '.', $ln/@n)]
              }</blockquote>
            default return ()
          }
        }
      </book>
    </treebank>
    let $path := string-join(($urn[1 to 2], 'merged', $n), '/')
    let $_ := message($path)
    return db:put('flatbanks', $merged, $path),

(: Tragedy :)
for key $tbPath value $teiPath in
map:build(db:list('flatbanks', 'tlg0011'), value := m:teiPath#1)
  let $tb := db:get("flatbanks", $tbPath)[1]
  let $tei := db:get("lit", $teiPath)[1]
  let $urn := tokenize($tbPath, '/')
  let $merged := <treebank>
    <body>
      {
        for $el in $tei//body//*
        return typeswitch ($el) {
          case element(milestone)
            return if ($el/@unit = "card") then <hr />
          case element(speaker)
            return <speaker>{$el/text()}</speaker>
          case element(l)
            return $tb//ln[@n=$el/@n]
          case element(q)
            return <blockquote>{
              for $ln in $el/l
              return $tb[@n=$ln/@n]
            }</blockquote>
          default return ()
        }
      }
    </body>
  </treebank>
  let $path := string-join(($urn[1 to 2], 'merged'), '/')
  let $_ := message($path)
  return db:put('flatbanks', $merged, $path)
