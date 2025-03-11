module namespace l = 'dblazy';
import module namespace n = 'normalize';

declare function l:get-flatbank($author, $work) {
  let $urn := `{$author}/{$work}`
  let $paths := db:list('flatbanks', $urn)

  return
    if (count($paths)) then db:get('flatbanks', $urn)[1]
    else
      let $path := file:list('treebanks/agldt/v2.1/', pattern := `{$author}.{$work}.*.tb.xml`)[1]
      let $is-verse := n:is-verse($author, $work)
      let $fb := n:normalize(doc($path), $is-verse)
      let $_ := db:put('flatbanks', $fb, $urn)
      return $fb
};
