#!/usr/bin/env bash
# Rebuild the glaux/ corpus dir from the GLAUx source repo.
#
# corpus.zip ships glaux/, so this is only needed to rebuild it from a local
# clone of https://github.com/alekkeersmaekers/glaux — to pick up upstream
# changes, or before cutting a new release. Source files are named by their
# TLG id (e.g. 0012-001.xml); the app expects them laid out to match tei/, i.e.
# glaux/tlg<author>/tlg<work>/<id>.xml (path derived from the TLG column of
# metadata.txt, matching the remap in seed/index.xq).
set -euo pipefail

GLAUX_SRC="${GLAUX_SRC:-../glaux}"
DEST="glaux"

meta="$GLAUX_SRC/metadata.txt"
[ -f "$meta" ] || { echo "metadata.txt not found at $meta" >&2; exit 1; }

rm -rf "$DEST"
count=0
missing=0

# Skip header; column 2 is the TLG id (e.g. 0012-001).
while IFS=$'\t' read -r _glaux_id tlg _rest; do
	[ -n "${tlg:-}" ] || continue
	src="$GLAUX_SRC/xml/$tlg.xml"
	if [ ! -f "$src" ]; then
		echo "WARN: missing source $src" >&2
		missing=$((missing + 1))
		continue
	fi
	author="${tlg%-*}"
	work="${tlg#*-}"
	dir="$DEST/tlg$author/tlg$work"
	mkdir -p "$dir"
	cp "$src" "$dir/$tlg.xml"
	count=$((count + 1))
done < <(tail -n +2 "$meta")

echo "Copied $count files ($missing missing) into $DEST/"
