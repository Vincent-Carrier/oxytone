module namespace idx = "oxytone/index";

declare %rest:path("")
        %rest:GET
        %output:method("html")
        function idx:get-index() {
  let $_ := store:read('glaux')
  for $k in store:keys()
    let $text := store:get($k)
    where $text?tokens > 500
    group by $genre := $text?genre
    return <section class="genre">
      <h2>{$genre}</h2>
      <ul class="authors">{
        for $author-in-genre in $text
          group by $author := $author-in-genre?author
          return
            if (count($author-in-genre) > 5) then
              <li>
                <details>
                  <summary>{$author}</summary>
                  <ul class="works">
                    {for $t in $author-in-genre
                      return
                          <li>
                            <a href="{'/read/' || $t?tlg}">{$t?title}</a>
                          </li>}
                  </ul>
                </details>
              </li>
            else
              <li>
                <h3>{$author}</h3>
                <ul class="works">
                  {for $t in $author-in-genre
                    return
                        <li>
                          <a href="{'/read/' || $t?tlg}">{$t?title}</a>
                        </li>}
                </ul>
              </li>
      }</ul>
    </section>
};
