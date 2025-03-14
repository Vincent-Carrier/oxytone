module namespace m = "merge";

declare function m:tei-path($author, $work) as xs:string {
  db:list('lit', `{$author}/{$work}`)[1]
};

declare function m:merge-homer($tb, $tei, $book) {
  let $tei-book := $tei//div[lower-case(@subtype)="book" and @n=$book]
  let $tb-book := $tb//ln[starts-with(@n, `{$book}.`)]
  return <treebank>
    <book n="{$book}">
      {
        for $el in $tei-book/*
        return typeswitch ($el) {
          case element(milestone)
            return if ($el/@unit = "card") then <hr />
          case element(l)
            return $tb-book[@n=concat($book, '.', $el/@n)]
          case element(q)
            return <blockquote>{
              for $ln in $el/l
              return $tb-book[@n=concat($book, '.', $ln/@n)]
            }</blockquote>
          default return ()
        }
      }
    </book>
  </treebank>
};

declare function m:merge-tragedy($tb, $tei) {
  <treebank>
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
};

declare function m:merge($tb, $author, $work, $part := ()) {
  let $tei-path := m:tei-path($author, $work)
  let $tei := db:get('lit', $tei-path)
  return switch ($author)
    case 'tlg0012' return m:merge-homer($tb, $tei, $part)
    case 'tlg0011' return m:merge-tragedy($tb, $tei)
    default return $tb
};
