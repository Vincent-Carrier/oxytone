module namespace l = 'dblazy';
import module namespace n = 'normalize';
import module namespace m = 'merge';

declare %updating function l:get-flatbank($author, $work, $part := ()) {
  let $urn := string-join(($author, $work, $part), '/')
  let $path := db:list('flatbanks', $urn)[1]
  return
    if ((: not(db:option('debug')) and :) $path)
      then db:get('flatbanks', $path)[1]
      else
        let $path := file:list('treebanks/agldt/v2.1/', pattern := `{$author}.{$work}.*.tb.xml`)[1]
        let $is-verse := n:is-verse($author, $work)
        let $tb := n:normalize(doc('../treebanks/agldt/v2.1/' || $path), $is-verse)
        let $merged := m:merge($tb, $author, $work, $part)
        let $_ := db:put('flatbanks', $merged, $urn)
        return $merged
};
