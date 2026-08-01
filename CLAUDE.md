# Oxytone

Web app for reading Ancient Greek with integrated lexical, syntactic, and
morphological analysis. Renders the [GLAUx](https://github.com/alekkeersmaekers/glaux)
treebank corpus with LSJ definitions and Anki flashcard export.

## Stack

- **Frontend**: SvelteKit 5 + TypeScript + Tailwind 4 (`adapter-node`). Words render as `ox-w` custom elements.
- **XML backend**: BaseX RESTXQ endpoints (XQuery) serve normalized treebank HTML, LSJ definitions, and the Anki flashcard CSV.
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
- `basex -Q path/to/query.xq` — run an XQuery file

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
- `seed/` — XQuery scripts that build the databases
- `glaux/`, `tei/`, `lsj/` — source corpus files (from `corpus.zip`)

## Details

- [docs/architecture.md](docs/architecture.md) — request flow, treebank rendering, frontend components
- [docs/data-pipeline.md](docs/data-pipeline.md) — corpus, databases, normalization
