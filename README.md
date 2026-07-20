# Oxytone

A web application for studying Ancient Greek texts with integrated lexical, syntactic, and morphological analysis tools.

## Project Description

Oxytone provides an interactive reading environment for Ancient Greek texts with:

- Integration with LSJ dictionary (taken from [Giuseppe Celano's Unicode version](https://github.com/gcelano/LSJ_GreekUnicode))
- Morphological analysis and highlighting of verb complements
- Flashcard generation for vocabulary learning via [Anki](https://ankiweb.net/)

Oxytone includes the full [GLAUx corpus](https://github.com/alekkeersmaekers/glaux), which contains most Ancient Greek texts. However, most of these texts have been annotated automatically through machine learning. See [Keersmaekers, Alek (2021)](https://aclanthology.org/2021.lchange-1.6/) for more details and a breakdown of annotation accuracy. GLAUx itself is based on the hard work of the people behind the Perseus and Perseids Projects, along many others.

## Project Structure

```
oxytone/
  webapp/           # BaseX RESTXQ endpoints
  repo/             # XQuery modules
  seed/             # XQuery seeding scripts
  src/              # SvelteKit frontend
  static/           # Static assets for SvelteKit
  glaux/            # GLAUx corpus files
  tei/              # TEI corpus files
  lsj/              # LSJ dictionary resources
```

## Architecture

Two services run side by side in development, tied together by a reverse proxy in production:

- **SvelteKit frontend** (port 5173 in dev, 3000 in prod) — the reading UI.
- **BaseX** (port 8080) — serves normalized treebank HTML and LSJ definitions from
  RESTXQ endpoints, and generates the Anki flashcard CSV.

See [docs/architecture.md](docs/architecture.md) and [docs/data-pipeline.md](docs/data-pipeline.md) for details.

## Requirements

Follow the installation instructions on their respective websites:

- [`basex`](https://basex.org/download/): XML database
- [`pnpm`](https://pnpm.io/installation): JavaScript package manager
- [`just`](https://just.systems/man/en/packages.html): Task runner
- [Saxon-HE](https://github.com/Saxonica/Saxon-HE/): XSLT processor for BaseX (this can be installed automatically with `just saxon`)

## Getting Started

### 1. Install dependencies

```bash
just install                  # pnpm install
just saxon                    # install Saxon-HE into BaseX (one time)
```

### 2. Fetch the corpus

```bash
just corpus                   # download and unzip corpus.zip (tei/, lsj/)
```

`corpus.zip` ships **without** the `glaux/` directory. Reconstruct it from a local
clone of the [GLAUx source repo](https://github.com/alekkeersmaekers/glaux):

```bash
git clone https://github.com/alekkeersmaekers/glaux ../glaux
just glaux-rebuild            # rebuilds glaux/ from ../glaux
```

`glaux-rebuild` reads `metadata.txt` from the GLAUx clone and copies each source
file into `glaux/tlg<author>/tlg<work>/<id>.xml` so the layout matches `tei/`.
Set `GLAUX_SRC` to point at a clone in a different location:

```bash
GLAUX_SRC=/path/to/glaux just glaux-rebuild
```

### 3. Seed the databases

```bash
just seed                     # builds lsj, glaux, tei, index, and normalized DBs
```

The `seed` recipe runs its steps in order, and that order matters: `index` reads
the store the `lsj` step (shortdefs) leaves behind and appends the work metadata to
it. BaseX keeps a single on-disk key/value store, so both the LSJ shortdefs (keyed
by Greek lemma) and the work metadata (keyed by `tlg…` path) live together in it —
their keys never collide. Re-run the whole `seed` (or at least `lsj` then `index`)
if the store ever looks wrong; running `index` alone on an empty store drops the
shortdefs.

### 4. Configure environment variables

The frontend reads the BaseX URL from a `.env` file (gitignored). Create one for
local development:

```bash
echo 'PUBLIC_BASEX_URL=http://localhost:8080/' > .env
```

The **trailing slash is required** — the frontend's `ky` client uses this as a
`prefixUrl`, so it must join cleanly with the relative RESTXQ paths it requests.

### 5. Run the dev servers

In separate terminals:

```bash
just basex                    # BaseX HTTP server on :8080
just svelte                   # SvelteKit dev server on :5173
```

Then open http://localhost:5173.

> **Port 8080 already in use?** BaseX binds to `0.0.0.0:8080`. If another service
> (e.g. a system Apache Tomcat) holds that port, `just basex` fails with
> `Address already in use`. Stop the other service first, or change BaseX's port.

## Production

The `build` recipe pulls, builds, and restarts the systemd target. In production a
[Caddy](Caddyfile) reverse proxy routes `/basex/*` → BaseX and everything else →
SvelteKit — so the production `.env` uses that proxy prefix
(e.g. `PUBLIC_BASEX_URL=/basex/`) rather than a direct port.

## Troubleshooting

- **`pnpm dev` crashes with `Failed to parse URL` / `Invalid URL`.** The `.env`
  file is missing, so `PUBLIC_BASEX_URL` is empty. See step 4 above. Remember the
  trailing slashes.

- **Every BaseX route returns `503 Service Unavailable`** (bare Jetty error page).
  The RESTXQ web context failed to start. Check the `just basex` output for a
  `ClassNotFoundException` — an outdated `webapp/WEB-INF/web.xml` can reference
  servlet/filter classes that no longer exist in the bundled Jetty (e.g.
  `CrossOriginFilter`, the WebDAV servlet). Remove the offending entries.

- **`read`/`define` return 500 with `xslt:error … TransformerFactoryImpl could not
be instantiated`.** Saxon can't start because its `xmlresolver` dependency is
  missing from `~/.basex/lib/custom/`. Re-run `just saxon` — it installs
  `saxon-he`, `xmlresolver`, and `xmlresolver-…-data` (the resolver jars live under
  `lib/` inside the Saxon zip and are easy to miss).

- **`index` returns 500 with `Input of lookup must be map or array`**, or the index
  page is empty. The shared store is missing the work metadata (or was overwritten
  with only shortdefs). Re-seed — see the note under step 3.

See [CLAUDE.md](./CLAUDE.md) for more detailed development guidelines.
