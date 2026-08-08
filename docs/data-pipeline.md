# Data pipeline

## Source corpus

Downloaded via `just corpus` (unzips `corpus.zip`) into:

- `glaux/` — the [GLAUx](https://github.com/alekkeersmaekers/glaux) treebank
  corpus. Most texts are machine-annotated
  ([Keersmaekers 2021](https://aclanthology.org/2021.lchange-1.6/)); accuracy
  varies. Built on Perseus/Perseids data.
- `tei/` — TEI XML texts, laid out `tlg<author>/tlg<work>/…` (e.g.
  `tlg0012/tlg001/`). **Homer only.** `m:merge` is the sole consumer and it
  switches on `tlg0012`, so the other 88 authors were 175 MB that nothing read.
- `lsj/` — LSJ dictionary ([Celano's Unicode version](https://github.com/gcelano/LSJ_GreekUnicode)).

`just release` re-zips `glaux/ tei/tlg0012/ lsj/` and publishes a GitHub release.
The `tei/tlg0012/` prefix is deliberate: the paths inside the archive have to
match what the `tei` recipe adds, or `db:get('tei', '{$author}/{$work}')` misses.
(`zip` is not installed by default on Void — `xbps-install -S zip`.)

### Wiktionary glosses

`seed/wiktionary-defs.tsv` (`lemma`, `pos`, pipe-joined defs) is **tracked in
git**, unlike the corpus above — the upstream [kaikki.org](https://kaikki.org/dictionary/Ancient%20Greek/)
Ancient Greek `.jsonl` dump it derives from is marked deprecated and slated for
removal (the replacement is a 23 GB all-languages extract). `just seed` reads
the TSV, never the dump.

`just wiktionary` (`seed/wiktionary.py`) regenerates it: streams the 41.5 MB
gzipped dump, drops `character`/`symbol` entries and inflected-form stubs
(`form_of`/`alt_of`), prefers `raw_glosses` over `glosses` to keep register
labels, and sorts for clean diffs. This covers 5.4k lemmas that have no LSJ
entry at all — mostly Koine and Biblical proper nouns.

### The `glaux/` layout

`corpus.zip` ships `glaux/` directly, so `just corpus` is the whole story — no
clone of the [GLAUx source repo](https://github.com/alekkeersmaekers/glaux) is
needed.

Upstream names its files by TLG id (`0012-001.xml`); in `glaux/` they are laid
out to match `tei/`, i.e. `glaux/tlg<author>/tlg<work>/<id>.xml` (`0012-001` →
`tlg0012/tlg001`), the same remap used in `seed/index.xq`. The files are
otherwise unmodified — the GLAUx `<treebank>` XML is already the format
`normalize.xqm` consumes.

## BaseX databases

`just seed` runs, in order: `lsj glaux tei wiktionary-seed index divisions pagers
normalized`. Each recipe in the `Justfile` creates one database with specific
indexing options:

- **`lsj`** — the dictionary, plus short-defs (`seed/shortdefs.xq`, `seed/lsj.xq`).
- **`wiktionary-seed`** — not a database: it appends Wiktionary glosses to the
  shared store under `wikt/` keys (`seed/wiktionary.xq`). Order matters — it must
  run after `lsj` (whose `shortdefs.xq` clears the store) and before `index`
  (which writes the store out).
- **`glaux`** — the treebank corpus, indexed on the attributes the app queries
  (`id, head, form, lemma, relation, speaker, div_*`, `analysis`).
- **`tei`** — **Homer only** (`tei/tlg0012`). `m:merge` is the sole reader and it
  switches on `tlg0012`, using the TEI `<q>` and `<milestone>` markup to add
  quotation blocks the treebank does not carry. Seeding all 91 authors made this
  216 MB instead of 5 MB, with 811 of 814 documents never queried. Speaker labels
  for the tragedians and Plato do _not_ come from here — they come from
  `@speaker` on the GLAUx treebank.
- **`index`** — the browse/search index (`seed/index.xq`).
- **`divisions`** — picks the page division for works that paginate
  automatically, extending the metadata `index` writes (`seed/divisions.xq`).
- **`pagers`** — stores the hand-curated per-work book lists that
  `p:curated-pager` reads, under `books/` keys (`seed/pagers.xq`).
- **`normalized`** — starts empty; a **write-through cache** of rendered pages.
  `seed/normalize.xq` warms it offline; `webapp/read.xqm` fills it lazily.

## Normalization (`repo/normalize.xqm`)

`n:get-normalized($author, $work, $page)` turns a raw GLAUx treebank into the
`<treebank>` intermediate representation the XSLT consumes:

1. Load the raw treebank from the `glaux` DB.
2. Determine layout `style` from genre metadata: `verse`, `theater`,
   `dialogue`, or `prose`.
3. Paginate (`repo/paginate.xqm`) to the requested page.
4. Fix quote/gap characters (`"` → `“`/`”`, `G?` → `[…]`).
5. Normalize into lines/sentences/chapters per style, then merge
   (`repo/merge.xqm`).
6. Wrap with a `<head>` (title, author, book list, style, analysis).

Each `<w>` keeps `id`/`head`/`relation`, gains a `sentence` attribute, has its
`lemma` NFC-normalized, and expands its `postag` into morphology attributes
(`repo/postag.xqm`). Padding/spacing between words is handled by `n:pad-right`.

Results are cached in the `normalized` DB by `read.xqm`; in debug mode
(`db:option('debug')`) they are recomputed every request instead. To force a
rebuild, reset the `normalized` DB (`just normalized`).

## Intermediate representation

The normalized `<treebank>` (with `<head>`, `<ln>`/`<sentence>`, `<w>` elements)
is what the `read.xqm` XSLT transforms into `<ox-w>`-based HTML.

## Samples

The same lines of the _Iliad_ (1.1–1.3) at each stage of the pipeline.

### 1. Source GLAUx treebank (`glaux/tlg0012/tlg001/0012-001.xml`)

Raw dependency treebank. `postag` is a positional morphology string; `line` /
`div_book` carry the reference.

```xml
<treebank version="2" xml:lang="grc">
  <sentence struct_id="411" id="1" document_id="0012-001" analysis="manual">
    <word id="100004219" form="μῆνιν" line="1.1" div_book="1" lemma="μῆνις" postag="n-s---fa-" head="100004220" relation="OBJ"/>
    <word id="100004220" form="ἄειδε" line="1.1" div_book="1" lemma="ἀείδω" postag="v2spma---" head="100004250" relation="PRED_CO"/>
    <word id="100004221" form="θεὰ" line="1.1" div_book="1" lemma="θεά" postag="n-s---fv-" head="100004220" relation="ExD"/>
    <word id="100004222" form="Πηληϊάδεω" line="1.1" div_book="1" lemma="Πηληϊάδης" postag="n-s---mg-" head="100004223" relation="ATR"/>
    <word id="100004223" form="Ἀχιλῆος" line="1.1" div_book="1" lemma="Ἀχιλλεύς" postag="n-s---mg-" head="100004219" relation="ATR"/>
    <word id="100004224" form="οὐλομένην" line="1.2" div_book="1" lemma="ὄλλυμι" postag="a-s---fa-" head="100004219" relation="ATR"/>
    <!-- … -->
  </sentence>
</treebank>
```

### 2. Normalized intermediate representation

Output of `n:get-normalized` (`repo/normalize.xqm`): a `<head>` with English
metadata + book list, and a `<body>` split into `<ln>` lines whose `<w>`
elements carry expanded morphology (`postag` → `pos`/`number`/`gender`/`case`/…)
and a `sentence` attribute. This is what gets cached in the `normalized` DB.

```xml
<treebank>
  <head>
    <title>Iliad, Book 1 (Α)</title>
    <author>Homer</author>
    <books>
      <book id="1">Book 1 (Α)</book>
      <!-- … -->
      <book id="24">Book 24 (Ω)</book>
    </books>
    <style>verse</style>
    <analysis>manual</analysis>
  </head>
  <body n="1">
    <hr/>
    <ln id="1.1" xml:space="preserve"><w id="100004219" head="100004220" relation="OBJ" sentence="1" lemma="μῆνις" pos="noun" number="sg." gender="fem." case="acc.">μῆνιν</w> <w id="100004220" head="100004250" relation="PRED_CO" sentence="1" lemma="ἀείδω" pos="verb" person="2nd" number="sg." tense="pres." mood="imperative" voice="act.">ἄειδε</w> <w id="100004221" head="100004220" relation="ExD" sentence="1" lemma="θεά" pos="noun" number="sg." gender="fem." case="voc.">θεὰ</w> <w id="100004222" head="100004223" relation="ATR" sentence="1" lemma="Πηληϊάδης" pos="noun" number="sg." gender="masc." case="gen.">Πηληϊάδεω</w> <w id="100004223" head="100004219" relation="ATR" sentence="1" lemma="Ἀχιλλεύς" pos="noun" number="sg." gender="masc." case="gen.">Ἀχιλῆος</w> </ln>
    <ln id="1.2" xml:space="preserve"><w id="100004224" head="100004219" relation="ATR" sentence="1" lemma="ὄλλυμι" pos="adj." number="sg." gender="fem." case="acc.">οὐλομένην</w><w id="100004225" head="100004241" relation="AuxX" sentence="1" lemma="," pos="punct.">,</w> <!-- … --></ln>
  </body>
</treebank>
```

### 3. Rendered frontend HTML

The `read.xqm` XSLT maps each `<w>` to an `<ox-w>` custom element (copying every
attribute) inside a `.line` div. `word.svelte` upgrades these on the client.

```html
<div class="line">
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
	><ox-w id="100004225" head="100004241" relation="AuxX" sentence="1" lemma="," pos="punct."
		>,</ox-w
	>
	<ox-w
		id="100004226"
		head="100004241"
		relation="SBJ"
		sentence="1"
		lemma="ὅς"
		pos="pronoun"
		number="sg."
		gender="fem."
		case="nom."
		>ἣ</ox-w
	>
	<ox-w
		id="100004227"
		head="100004229"
		relation="ATR"
		sentence="1"
		lemma="μυρίος"
		pos="adj."
		number="pl."
		gender="neut."
		case="acc."
		>μυρί’</ox-w
	><!-- … -->
</div>
```

See the full XSLT in `webapp/read.xqm` and the frontend rendering in
[architecture.md](architecture.md).
