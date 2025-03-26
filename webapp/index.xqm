module namespace idx = "oxytone/index";
import module namespace p = "paginate";

declare %rest:path("")
        %rest:GET
        %output:method("html")
        function idx:get-index() {
  let $_ := store:read('glaux')
  for $k in store:keys()
    let $work := store:get($k)
    where $work?tokens > 500
    group by $genre := $work?genre
    return <section class="genre">
      <h2>{$genre}</h2>
      <ul class="authors">{
        for $author-in-genre in $work
          group by $author := $author-in-genre?author
          return
            if (count($author-in-genre) > 5) then
              <li>
                <details class="author" open="">
                  <summary>{$author}</summary>
                  <ul class="works">
                    {for $work in $author-in-genre return idx:render-work($work)}
                  </ul>
                </details>
              </li>
            else
              <li>
                <h3>{$author}</h3>
                <ul class="works">
                  {for $work in $author-in-genre return idx:render-work($work)}
                </ul>
              </li>
      }</ul>
    </section>
};

declare function idx:render-work($work) {
  let $pager := p:pager($work?tlg)
  return
    <li>
      {if (exists($pager)) then
        <details class="work" open="">
          <summary>{$work?title}</summary>
          <ol class="pages">
          {for $n in $pager?list()
            return <li>
              <a href="{`read/{$work?tlg}/{$n}`}">{$pager?format($n)}</a>
            </li>}
          </ol>
        </details>
      else
        <a href="{`read/{$work?tlg}`}">{$work?title}</a>}
    </li>
};
