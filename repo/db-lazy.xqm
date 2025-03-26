module namespace dbl = 'db-lazy';
import module namespace n = 'normalize';
import module namespace m = 'merge';
import module namespace p = 'paginate';

declare function dbl:file-matches($dir, $pattern) as xs:string* {
  for $f in file:children($dir)
    where matches($f, $pattern)
    return $f
};

declare %updating function dbl:get-flatbank($author, $work, $page := ()) {
  let $urn := string-join(($author, $work, $page), '/')
  let $path := db:list('flatbanks', $urn)[1]
  return
    if ($path)
      then db:get('flatbanks', $path)[1]
      else
        let $path := (
          dbl:file-matches('treebanks/agldt/v2.1/', `{$author}\.{$work}\.`),
          file:children(`glaux/{$author}/{$work}/`)
        )[1] => file:resolve-path()
        return if (trace($path, "PATH: ")) then
          let $style := trace(n:style($author, $work), "STYLE: ")
          let $doc := doc($path)
          let $pager := p:pager(`{$author}/{$work}`)
          let $paged := if (exists($pager)) then $pager?get($doc, $page) else $doc
          let $first_sentence := trace($paged//sentence[1], "=== EXCERPT: ")
          let $tb := $paged => n:normalize($style) => m:merge($author, $work, $page)
          let $_ := if (not(db:option('debug'))) then db:put('flatbanks', $tb, $urn)
          return $tb
        else db:get('flatbanks', $path)[1]
};
