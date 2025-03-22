module namespace dbl = 'db-lazy';
import module namespace n = 'normalize';
import module namespace m = 'merge';

declare function dbl:file-matches($dir, $pattern) as xs:string* {
  for $f in file:children($dir)
    where matches($f, $pattern)
    return $f
};

declare %updating function dbl:get-flatbank($author, $work, $part := ()) {
  let $urn := string-join(($author, $work, $part), '/')
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
          let $tb := n:normalize(doc($path), $style)
          let $merged := m:merge($tb, $author, $work, $part)
          let $_ := if (not(db:option('debug'))) then db:put('flatbanks', $merged, $urn)
          return $merged
        else db:get('flatbanks', $path)[1]
};
