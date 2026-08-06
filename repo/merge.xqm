module namespace m = "merge";
import module namespace p = "paginate";

(: Rebuilds a book of Homer in the order and grouping of the Perseus TEI edition,
   pulling each line's words from the normalized treebank. GLAUx has the morphology
   but no quotation or card structure; the TEI has both. Walking the TEI is what
   picks up its <q> speeches as blockquotes and its card milestones as rules.

   Lines the TEI does not mention are dropped, as are GLAUx's bare `"` words, which
   the TEI marks up structurally instead. :)
declare function m:merge-homer($tb, $tei, $book) {
  let $tei-book := $tei//div[lower-case(@subtype)="book" and @n=$book]
  return
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
    </body> transform with { delete nodes .//w[@lemma = '"'] }
};

(: Enriches a normalized treebank from a second source where one exists. Homer is
   the only such text — `tei/` holds nothing else — so every other work passes
   through untouched. :)
declare function m:merge($tb, $author, $work, $part := ()) {
  switch ($author)
    case 'tlg0012' return m:merge-homer($tb, db:get('tei', `{$author}/{$work}`)[1], $part)
    default return $tb
};
