#!/usr/bin/env python3
"""Distill the kaikki.org Wiktionary dump into seed/wiktionary-defs.tsv.

Only needed to refresh the data — `just seed` reads the tracked TSV, not the
dump. The upstream .jsonl is marked deprecated and slated for removal (the
replacement is a 23 GB all-languages extract), hence the tracked copy.

The dump is streamed line by line, so memory stays constant regardless of the
390 MB uncompressed size.
"""

import gzip
import json
import sys
import tempfile
import urllib.request
from pathlib import Path

URL = (
    'https://kaikki.org/dictionary/Ancient%20Greek/'
    'kaikki.org-dictionary-AncientGreek.jsonl.gz'
)

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'wiktionary-defs.tsv'
CACHE = Path(tempfile.gettempdir()) / 'kaikki-grc.jsonl.gz'

# The Greek letters themselves, not words — ~20% of entries.
SKIP_POS = {'character', 'symbol'}


def download(dest: Path) -> None:
    if dest.exists() and dest.stat().st_size > 0:
        print(f'using cached {dest} ({dest.stat().st_size / 1e6:.1f} MB)')
        return
    print(f'downloading {URL} -> {dest}')
    urllib.request.urlretrieve(URL, dest)
    print(f'downloaded {dest.stat().st_size / 1e6:.1f} MB')


def clean(text: str) -> str:
    """Collapse whitespace so the field can't break the TSV."""
    return ' '.join(text.split())


def gloss(sense: dict) -> str | None:
    """Prefer raw_glosses: it keeps the register label — "(derogatory) a bitch".

    It is present on only ~23% of senses, so glosses (always present) is the
    fallback.

    Wiktextract flattens sub-senses into extra list entries, so a gloss can
    arrive as ['The meaning is uncertain. Possibilities include:', 'inviolable']
    where the real definition is the tail. Joining keeps it; taking [0] alone
    would leave a dangling colon.
    """
    for key in ('raw_glosses', 'glosses'):
        values = sense.get(key)
        if values:
            return clean(' '.join(values))
    return None


def entry_rows(entry: dict):
    """Yield (lemma, pos, joined-glosses) for one dump entry, if it has any."""
    if entry.get('pos') in SKIP_POS:
        return

    senses = entry.get('senses') or []
    # Drop inflected-form stubs ("present active participle of κῠ́ω"); if every
    # sense is one, the entry carries no definition at all.
    content = [s for s in senses if not (s.get('form_of') or s.get('alt_of'))]
    glosses = [g for g in (gloss(s) for s in content) if g]
    if not glosses:
        return

    word = entry.get('word')
    pos = entry.get('pos')
    if not word or not pos:
        return

    # Preserve sense order, but drop repeats — some entries restate a gloss
    # across senses that differ only in tags. A parent sense also arrives
    # alongside each of its sub-senses, which repeat it verbatim as their own
    # prefix ("… Possibilities include:" then "… Possibilities include: X"), so
    # drop any gloss another one merely extends.
    unique = [
        g
        for i, g in enumerate(glosses)
        if not any(o != g and o.startswith(g) for o in glosses)
        and g not in glosses[:i]
    ]
    yield clean(word), clean(pos), ' | '.join(unique)


def main() -> int:
    download(CACHE)

    rows: list[tuple[str, str, str]] = []
    entries = 0
    with gzip.open(CACHE, 'rt', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            entries += 1
            rows.extend(entry_rows(entry))

    # Deterministic output so refreshes produce clean diffs. Sorting by lemma
    # then pos also groups each lemma's parts of speech together, which is the
    # order seed/wiktionary.xq folds them into an array.
    rows.sort(key=lambda r: (r[0], r[1]))

    with OUT.open('w', encoding='utf-8', newline='\n') as f:
        f.write('lemma\tpos\tdef\n')
        for lemma, pos, defs in rows:
            f.write(f'{lemma}\t{pos}\t{defs}\n')

    lemmas = len({r[0] for r in rows})
    print(f'{entries} entries in -> {len(rows)} rows ({lemmas} lemmas) -> {OUT}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
