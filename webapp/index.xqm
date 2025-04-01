module namespace idx = "oxytone/index";
import module namespace p = "paginate";

declare %rest:path("")
        %rest:GET
        %output:method("html")
        function idx:get-index() {
  let $_ := store:read('glaux')
  for $k in store:keys()
    let $work := store:get($k)
    where $work?tokens > 2000
    group by $date := $work?date
    return <section class="century">
      <h2>
        {abs(1 + round($date div 100)) * 100}
        <small>s   </small>{" "}
        {if ($date > -101) then 'AD' else 'BC'}
      </h2>
      <ul class="authors">{
        for $author-in-date in $work
        group by $author := $author-in-date?english-author
          return
            <li>
              <details class="author">
                {if (count($author-in-date) <= 20) then attribute open {}}
                <summary><span>{$author}</span></summary>
                <ul class="works">
                  {for $work in $author-in-date return idx:work($work)}
                </ul>
              </details>
            </li>
      }</ul>
    </section>
};

declare function idx:work($work) {
  let $pager := p:pager($work?tlg)
  return
    <li>
      {if (exists($pager)) then
        <details class="work">
          {if (count($pager?list) <= 5 ) then attribute open {}}
          <summary>{$work?english-title}</summary>
          <ol class="pages">
          {for $n in $pager?list
            return <li>
              <a data-sveltekit-preload-code="" href="{`read/{substring($work?tlg, 1, 14)}/{$n}`}">{$pager?format($n)}</a>
            </li>}
          </ol>
        </details>
      else
        <a data-sveltekit-preload-code="" href="{`read/{substring($work?tlg, 1, 14)}`}">{$work?english-title}</a>}
    </li>
};
