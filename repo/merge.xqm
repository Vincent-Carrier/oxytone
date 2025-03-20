module namespace m = "merge";

declare function m:merge-homer($tb, $tei, $book) {
  let $tei-book := $tei//div[lower-case(@subtype)="book" and @n=$book]
  let $tb-book := $tb//ln[starts-with(@n, `{$book}.`)]
  let $titleStmt := $tei/TEI/teiHeader/fileDesc/titleStmt
  return <treebank>
    <head>
      {$titleStmt/title}
      {$titleStmt/author}
    </head>
    <body n="{$book}">
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
    </body>
  </treebank>
};

declare function m:merge-tragedy($tb, $tei) {
  let $titleStmt := $tei/TEI/teiHeader/fileDesc/titleStmt
  return <treebank>
    <head>
      {$titleStmt/title}
      {$titleStmt/author}
    </head>
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

declare function m:merge-tei($tb, $tei) {
  let $titleStmt := $tei/TEI/teiHeader/fileDesc/titleStmt
  return <treebank>
    <head>
      {$titleStmt/title}
      {$titleStmt/author}
    </head>
    {$tb//body}
  </treebank>
};

declare function m:merge-glaux($tb, $author, $work) {
  let $_ := store:read('glaux')
  let $meta := store:get(`{$author}/{$work}`)
  let $_ := message(("====== ", $meta, "======"))
  return <treebank>
      <head>
        <title>{$meta?title}</title>
        <author>{$meta?author}</author>
      </head>
      {$tb//body}
    </treebank>
};



declare function m:merge($tb, $author, $work, $part := ()) {
  let $tei := db:get('lit', `{$author}/{$work}`)[1]
  return if ($tei) then
    switch ($author)
      case 'tlg0012' return m:merge-homer($tb, $tei, $part)
      case 'tlg0011' return m:merge-tragedy($tb, $tei)
      default return m:merge-glaux($tb, $author, $work)
    else switch($author)
      case 'nt' return $tb
      default return m:merge-glaux($tb, $author, $work)
};
