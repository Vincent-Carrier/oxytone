# Oxytone

Web app for reading Ancient Greek with integrated lexical, syntactic, and
morphological analysis. Renders the [GLAUx](https://github.com/alekkeersmaekers/glaux)
treebank corpus with LSJ and Wiktionary definitions, and Anki flashcard export.

## Stack

- **Frontend**: SvelteKit 5 + TypeScript + Tailwind 4 (`adapter-node`). Words render as `ox-w` custom elements.
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
  with `<ox-w>` elements. Served from the `normalized` write-through cache, so a
  second request does not re-normalize. Set the `debug` option to bypass it.
- **`/plain/{author}/{work}/{page}`** — the same normalized tree rendered as
  plain `<span>`s instead of `<ox-w>`, carrying every morphology attribute
  (`lemma`, `pos`, `case`, `relation`, …), with `#section-ref[1.1.1]` markers and
  `*verb*` emphasis. Nothing in `src/` calls it: it exists for reading a text as
  text — inspecting normalization output, or pasting a passage into an LLM.
  Never cached, so it always reflects the current XQuery.
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

## Layout

- `src/` — SvelteKit frontend ([docs/architecture.md](docs/architecture.md))
- `src/lib/llm/` — provider adapters, SSE streaming, prompts. `providers.ts` is pure (describes requests); `stream.ts` holds the only fetch.
- `webapp/` — BaseX RESTXQ endpoints (`.xqm`)
- `repo/` — shared XQuery modules (normalize, paginate, postag, urn, …)
- `seed/` — XQuery scripts that build the databases, plus the tracked `wiktionary-defs.tsv` and the Python script that regenerates it
- `glaux/`, `tei/`, `lsj/` — source corpus files (from `corpus.zip`). `tei/` is
  Homer only: `m:merge` is its sole consumer, for quotation markup.

## Details

- [docs/architecture.md](docs/architecture.md) — request flow, treebank rendering, frontend components
- [docs/data-pipeline.md](docs/data-pipeline.md) — corpus, databases, normalization
