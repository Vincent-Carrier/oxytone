module namespace idx = "oxytone/index";
import module namespace p = "paginate";

declare %rest:path("")
        %rest:GET
        %output:method("html")
        function idx:get-index() {
  let $_ := store:read('glaux')
  let $index := map:build(store:keys, value := fn($k) { store:get($k) })
  for key $tlg value $meta in $index
    where $meta?tokens > 2000
    group by $genre := $meta?genre
    return <section class="genre">
      <h2>{$genre}</h2>
      <ul class="authors">{
        for $author-in-genre in $meta
          group by $author := $author-in-genre?english-author
          return
            if (count($author-in-genre) > 5) then
              <li>
                <details class="author" open="" name="author">
                  <summary>{$author}</summary>
                  <ul class="works">
                    {for $meta in $author-in-genre return idx:work($meta)}
                  </ul>
                </details>
              </li>
            else
              <li>
                <h3>{$author}</h3>
                <ul class="works">
                  {for $meta in $author-in-genre return idx:work($meta)}
                </ul>
              </li>
      }</ul>
    </section>
};

declare function idx:work($meta) {
  let $pager := p:pager($meta?tlg)
  return
    <li>
      {if (exists($pager)) then
        <details class="work" open="" name="work">
          <summary>{$meta?english-title}</summary>
          <ol class="pages">
          {for $n in $pager?list
            return <li>
              <a href="{`read/{$meta?tlg}/{$n}`}">{$pager?format($n)}</a>
            </li>}
          </ol>
        </details>
      else
        <a href="{`read/{$meta?tlg}`}">{$meta?english-title}</a>}
    </li>
};
