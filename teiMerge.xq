(: Homer :)
(: let $pairs := (
  { 'tb': 'tlg0012/tlg001/perseus-grc1', 'tei': 'tlg0012/tlg001/perseus-grc2' }
)
for $pair in $pairs
  let $tb := db:get("flatbanks", $pair?tb)[1]
  let $tei := db:get("lit", $pair?tei)[1]
  let $urn := tokenize($pair?tb, '/')
  for $n in (1 to 24)
    let $teiBook := $tei//div[@subtype="Book" and @n=$n]
    let $tbBook := $tb//ln[starts-with(@n, `{$n}.`)]
    let $merged := <treebank>
      <book n="{$n}">
        {
          for $el in $teiBook/*
          return typeswitch ($el) {
            case element(milestone)
              return if ($el/@unit = "card") then <hr />
            case element(l)
              return $tbBook[@n=concat("1.", $el/@n)]
            case element(q)
              return <blockquote>{
                for $ln in $el/l
                return $tbBook[@n=concat("1.", $ln/@n)]
              }</blockquote>
            default return ()
          }
        }
      </book>
    </treebank>
    let $path := string-join(($urn[1 to 2], 'merged', $n), '/')
    let $_ := message($path)
    return db:put('flatbanks', $merged, $path), :)

(: Tragedy :)
let $pairs := (
  { 'tb': 'tlg0011/tlg003/perseus-grc1', 'tei': 'tlg0011/tlg003/perseus-grc2' }
)
for $pair in $pairs
  let $tb := db:get("flatbanks", $pair?tb)[1]
  let $tei := db:get("lit", $pair?tei)[1]
  let $urn := tokenize($pair?tb, '/')
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
