module namespace m = "merge";
import module namespace p = "paginate";

declare function m:merge-homer($tb, $tei, $book) {
  let $tei-book := $tei//div[lower-case(@subtype)="book" and @n=$book]
  return <treebank>
    <body n="{$book}">
      {
        for $el in $tei-book/*
        return typeswitch ($el) {
          case element(milestone)
            return if ($el/@unit = "card") then <hr />
          case element(l)
            return $tb//ln[@id=concat($book, '.', $el/@n)]
          case element(q)
            return <blockquote>{
              for $ln in $el/l
                return $tb//ln[@id=concat($book, '.', $ln/@n)]
            }</blockquote>
          default return ()
        }
      }
    </body>
  </treebank> transform with {
    delete nodes .//w[@lemma = '"']
  }
};

declare function m:merge($tb, $author, $work, $part := ()) {
  switch ($author)
    case 'tlg0012' return m:merge-homer($tb, db:get('lit', `{$author}/{$work}`)[1], $part)
    default return $tb
};
