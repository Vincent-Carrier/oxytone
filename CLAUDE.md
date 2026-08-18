# Oxytone

Web app for reading Ancient Greek with integrated lexical, syntactic, and
morphological analysis. Renders the [GLAUx](https://github.com/alekkeersmaekers/glaux)
treebank corpus with LSJ and Wiktionary definitions, and Anki flashcard export.

## Stack

- **Frontend**: SvelteKit 5 + TypeScript + Tailwind 4 (`adapter-node`). Words render as plain `<span class="w">` elements carrying their analysis as attributes.
- **XML backend**: BaseX RESTXQ endpoints (XQuery) serve normalized treebank HTML, dictionary definitions (LSJ + Wiktionary), and the Anki flashcard CSV.
- **Reverse proxy**: Caddy routes `/basex/*` → BaseX (8080), else → SvelteKit (3000).
- **LLM**: browser-direct streaming calls to a user-supplied API key (`src/lib/llm/`). No accounts, no server involvement — the key stays in `localStorage`.

## Commands

- `just dev` — whole stack behind Caddy on http://localhost:5000 (**preferred**: makes `/basex/*` same-origin, which BaseX needs since it sends no CORS headers)
- `pnpm dev` — SvelteKit alone on :5173 (or `just svelte`); BaseX fetches fail cross-origin
- `pnpm build` / `pnpm check` / `pnpm lint` / `pnpm format`
- `just basex` — start BaseX HTTP server
- `just seed` — build all BaseX databases from the corpus (see [docs/data-pipeline.md](docs/data-pipeline.md))
- `just install` — install JS (`pnpm`) deps
- `just corpus` — download the corpus zip (needed before seeding)
- `just wiktionary` — refresh `seed/wiktionary-defs.tsv` from the kaikki.org dump (only to update the data; the TSV is tracked)
- `basex -Q path/to/query.xq` — run an XQuery file

## Debugging the backend

`curl` against BaseX (`:8080` directly, or `:5000/basex/` behind Caddy) is the
fastest way to check server output — much cheaper than driving a browser:

- `/read/{author}/{work}/{page}` — what the frontend consumes: `#tb-content`
  with `<span class="w">` word elements. Served from the `normalized` write-through cache, so a
  second request does not re-normalize. Set the `debug` option to bypass it.
- **`/plain/{author}/{work}/{page}`** — the same normalized tree rendered as
  bare `<span>`s without the `w` class or the reading UI, carrying every morphology attribute
  (`lemma`, `pos`, `case`, `relation`, …), with `#section-ref[1.1.1]` markers and
  `*verb*` emphasis. Nothing in `src/` calls it: it exists for reading a text as
  text — inspecting normalization output, or pasting a passage into an LLM.
  Never cached, so it always reflects the current XQuery.
- `/translate/{author}/{work}/{page}?ed=` — the Perseus English translation of
  that page, each passage a `<p>` whose `@id` is its full dotted citation, so the
  ids match the Greek side's section anchors. Returns `data-empty` rather than a
  404 for the 128 of 180 paginated works that have no translation. `ed` picks
  among the editions a work has (127 of 634 have 2–5); absent or unknown, the
  oldest wins. `repo/translations.xqm` reads translator and date out of the TEI
  headers, and the read page lists them above its page list.
- `/define/lsj/{lemma}` — dictionary fragment. `/flashcards?author=&work=&w=` — Anki CSV.

Page labels are usually numbers, but not always (`praef`, `priora`, `17/18`).
The route takes everything after the work as the page, so slashed labels work:
`/read/tlg0081/tlg001/17/18`. Requesting a paginated work with no page at all
(`/read/tlg0012/tlg001`) renders its first page.

## Code style

- oxfmt: **tabs, single quotes, no semicolons, 100 char width** (`.oxfmtrc.json`).
- TypeScript strict. Svelte 5 runes only.
- `$` is aliased to `src/` (see `svelte.config.js`).
- camelCase for vars/functions, PascalCase for components.

### XQuery: never put `(: … :)` inside an element constructor

Inside a direct element constructor, everything between the tags is element
_content_. `(: … :)` is comment syntax in query context only, so there it is
literal text and is copied into the output:

```xquery
(: WRONG — the comment renders into the page :)
<hgroup>
  <h1>{$title}</h1>
  (: which edition this is :)
  {$credit}
</hgroup>
```

It is easy to miss, because the damage is often invisible where you look
first: an XSLT that pulls named children (`head/title`, `head/books`) skips
stray text, so a leaked comment sits in the output — and in the `normalized`
cache — while the rendered page looks correct.

Bind the value in a `let` above and interpolate it, keeping the comment in
query context:

```xquery
(: which edition this is :)
let $credit := <p class="translator">{$who}</p>
return <hgroup>
  <h1>{$title}</h1>
  {$credit}
</hgroup>
```

A comment is also fine _between_ the map entries of an `xsm:stylesheet`, which
is query context — that is where the `"books"` / `"translation"` template notes
in `webapp/read.xqm` live.

To check, grep for a `(:` whose preceding line ends in `>` or `}`, and confirm
with `curl … | grep -c '(:.*:)'` — the count should be 0 on every endpoint.
Match the closing `:)` too: a bare `(:` also hits Tailwind's `:not(…)` selectors
in the served CSS.

## Layout

- `src/` — SvelteKit frontend ([docs/architecture.md](docs/architecture.md))
- `src/lib/llm/` — provider adapters, SSE streaming, prompts. `providers.ts` is pure (describes requests); `stream.ts` holds the only fetch.
- `webapp/` — BaseX RESTXQ endpoints (`.xqm`)
- `repo/` — shared XQuery modules (normalize, paginate, postag, translations, urn, …)
- `seed/` — XQuery scripts that build the databases, plus the tracked `wiktionary-defs.tsv` and the Python script that regenerates it
- `glaux/`, `tei/`, `lsj/` — source corpus files (from `corpus.zip`). `corpus.zip`
  ships only Homer's Greek TEI, the sole input to `m:merge`'s quotation markup.
  `just translations` adds Perseus English translations (770 files, 634 works).

## Details

- [docs/architecture.md](docs/architecture.md) — request flow, treebank rendering, frontend components
- [docs/data-pipeline.md](docs/data-pipeline.md) — corpus, databases, normalization
