# Architecture

Two services behind a Caddy reverse proxy (`Caddyfile`):

| Path prefix     | Service   | Port | Role                                                         |
| --------------- | --------- | ---- | ------------------------------------------------------------ |
| `/basex/*`      | BaseX     | 8080 | Serves treebank HTML, LSJ definitions, and the flashcard CSV |
| everything else | SvelteKit | 3000 | UI, static files, SPA fallback                               |

`src/lib/api.ts` exposes a `ky` client, `basex`, pointed at `PUBLIC_BASEX_URL`.

## Request flow (reading a text)

1. User navigates to `/read/<author>/<work>/<page>` (a rest param, `[...urn]`).
2. `src/routes/read/[...urn]/+page.ts` fetches `basex.get('read/<urn>')` as text.
3. BaseX `webapp/read.xqm` (`r:get-page`) resolves the normalized treebank
   (from the `normalized` DB cache, or builds it on demand via `normalize.xqm`)
   and runs an XSLT transform producing HTML.
4. The page injects that HTML; each word becomes an `<ox-w>` custom element.

The XSLT lives in `read.xqm` as `$r:xslt`, built with the `xsm` helper module
(`repo/xsm.xqm`). It maps `<w>` → `<ox-w>` (copying all attributes), lines to
`.line` divs, chapters/sections/speakers to their containers, etc.

## Treebank markup

A rendered word carries its full morphology and dependency info as attributes:

```html
<ox-w
	id="100004224"
	head="100004219"
	relation="ATR"
	sentence="1"
	lemma="ὄλλυμι"
	pos="adj."
	number="sg."
	gender="fem."
	case="acc."
	>οὐλομένην</ox-w
>
```

`id`/`head` encode the dependency tree; `sentence` groups words; the rest is
expanded morphology (see `repo/postag.xqm` for postag → attribute expansion).

## Frontend components (`src/lib/`)

- `word.svelte` — the `ox-w` custom element; interactivity per word.
- `definition.svelte` — LSJ definition lookup (via `webapp/define.xqm`).
- `morphology.svelte` — displays a word's parsed morphology.
- `flashcards-button.svelte` — links selected lemmas to the BaseX `/flashcards`
  endpoint to download an Anki-importable CSV.
- `nav.svelte`, `ref.svelte`, `tooltip.svelte`, `toggle.svelte`, `button.svelte` — UI.
- `global-state.svelte.ts`, `local-storage.svelte.ts` — rune-based shared state.
- `class-map.ts` — batch add/remove CSS classes across a set of elements
  (used for dependency-tree highlighting).

`WordElement` (typed in `src/app.d.ts`) documents the attributes and methods a
word element exposes.

## Flashcards (`webapp/flashcards.xqm`)

`GET /flashcards?author=&work=&w=<lemma>&w=<lemma>…` — for each lemma, builds a
row whose Front is the lemma and Back is the LSJ definition HTML (via the shared
`def:definition-html` helper in `webapp/define.xqm`, the same HTML the `/define`
endpoint serves). The rows are tab-serialized with `csv:serialize` and prefixed
with Anki's `#`-directives (`#notetype:Basic`, `#deck:Greek Vocabulary`,
`#tags column`, …), returned as a downloadable `greek-flashcards.csv`. Imports
into Anki as Basic notes tagged `author-… work-…`. No Python involved.

## Deploy

`just build` pulls, runs `pnpm build`, and restarts `paroxytone.target`
(systemd). Note: some changes need the Cloudflare cache purged or the
`normalized` DB reset (it caches rendered pages).
