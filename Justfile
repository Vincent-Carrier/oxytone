set unstable
set script-interpreter := ["bash", "-euxo", "pipefail"]

export BASEX_HOME := x"~/.basex"

[group('db')]
[doc('Build every BaseX database, in order')]
seed: lsj glaux tei wiktionary-seed index divisions pagers normalized

[group('db')]
[doc('Build the lsj dictionary DB plus short-defs')]
lsj:
  basex -Q seed/shortdefs.xq
  basex -O ATTRINCLUDE=id -O TEXTINDEX=false \
        -c "CREATE DB lsj" \
        -Q seed/lsj.xq

# Load seed/wiktionary-defs.tsv into the shared store under 'wikt/' keys. Must run
# after `lsj` (whose shortdefs.xq clears the store) and before `index` (which
# writes the store out) — see the header comment in seed/wiktionary.xq.
[group('db')]
[doc('Load Wiktionary glosses into the shared store')]
wiktionary-seed:
  basex -Q seed/wiktionary.xq

[group('db')]
[doc('Create the empty normalized write-through cache DB')]
normalized:
  basex -c "CREATE DB normalized"

[group('db')]
[doc('Build the glaux treebank DB')]
glaux:
  basex -O MAXCATS=10000 -O ATTRINCLUDE=id,head,form,lemma,relation,speaker,div_chapter,div_section,analysis \
        -c "CREATE DB glaux glaux/"

# Homer only. m:merge is the sole reader of this DB, and it switches on
# 'tlg0012', so the other 88 authors in tei/ were 98% of the database (216 MB ->
# 5 MB) and were never queried. Speaker labels for the tragedians and Plato come
# from @speaker on the GLAUx treebank, not from TEI.
#
# Added under an explicit tlg0012 path rather than `CREATE DB tei tei/tlg0012`,
# which would strip that segment and break the `{$author}/{$work}` lookup.
[group('db')]
[doc('Build the tei DB (Homer only)')]
tei:
  basex -O STRIPNS=true -c "CREATE DB tei"
  basex -O STRIPNS=true -c "OPEN tei; ADD TO tlg0012 tei/tlg0012"

[group('db')]
[doc('Build the work-metadata index')]
index:
  basex -Q seed/index.xq

# Decide the page division for works that paginate automatically. Extends the
# metadata `index` writes, so it has to run after it.
[group('db')]
[doc('Decide page divisions for auto-paginated works')]
divisions:
  basex -Q seed/divisions.xq

# Store the hand-curated per-work book lists that `p:curated-pager` reads. Writes
# into the same store as `index`, so it has to run after it.
[group('db')]
[doc('Store the hand-curated per-work book lists')]
pagers:
  basex -Q seed/pagers.xq


# Syntactic-complexity measures (MDD, MHD, non-projectivity) over a sample of the
# treebank, written to out/*.tsv. Analysis, not seeding — reads the glaux DB and
# the store, writes neither, so it can run any time after `just seed`.
[group('db')]
[doc('Syntactic-complexity measures over the treebank -> out/*.tsv')]
complexity:
  basex -Q seed/complexity.xq

[group('dev')]
[doc('Start the BaseX HTTP server')]
basex:
  basexhttp -d

[group('dev')]
[doc('Run SvelteKit alone on :5173 (no Caddy)')]
svelte:
  pnpm dev

# Run the whole stack behind Caddy on http://localhost:5000.
#
# Going through Caddy (rather than hitting `pnpm dev` on :5173) is what makes
# /basex/* same-origin: BaseX sends no CORS headers, so the browser blocks a
# direct cross-port fetch. PUBLIC_BASEX_URL is baked in at build time, so it has
# to be set here too — same reason as `build-local`.
#
# BaseX is started only if it isn't already running, and is left running on exit;
# Caddy and Vite are stopped with the recipe.
[group('dev')]
[doc('Run the whole stack behind Caddy on http://localhost:5000')]
dev:
  #!/usr/bin/env bash
  set -euo pipefail
  # Job control, so each background job leads its own process group and can be
  # killed as a group (see cleanup below).
  set -m
  if ! curl -sf -o /dev/null http://localhost:8080/; then
    # -S detaches; plain `basexhttp` (and `-d`, which only enables debug output)
    # runs in the foreground and would block the rest of this recipe.
    echo "starting basex ..."
    basexhttp -S
    until curl -sf -o /dev/null http://localhost:8080/; do sleep 0.5; done
  fi
  caddy run --config Caddyfile.dev &
  caddy_pid=$!
  PUBLIC_BASEX_URL=/basex/ pnpm dev --port 5173 --strictPort &
  vite_pid=$!
  # Kill each child's whole process group: pnpm spawns vite as a grandchild, so
  # signalling pnpm alone would strand the dev server holding port 5173.
  cleanup() {
    trap - EXIT INT TERM
    for pid in $caddy_pid $vite_pid; do
      kill -- -$pid 2>/dev/null || kill $pid 2>/dev/null || true
    done
    # Escalate: both hold their listening sockets open briefly after SIGTERM, and
    # a lingering vite keeps :5173 bound so the next `just dev` fails to start.
    for _ in 1 2 3 4 5 6 7 8 9 10; do
      if ! kill -0 $caddy_pid 2>/dev/null && ! kill -0 $vite_pid 2>/dev/null; then
        return 0
      fi
      sleep 0.2
    done
    for pid in $caddy_pid $vite_pid; do
      kill -9 -- -$pid 2>/dev/null || kill -9 $pid 2>/dev/null || true
    done
  }
  trap cleanup EXIT INT TERM
  echo "oxytone -> http://localhost:5000"
  wait -n $caddy_pid $vite_pid


[group('install')]
[doc('Install JS dependencies with pnpm')]
install:
  pnpm install

# Refresh seed/wiktionary-defs.tsv from the kaikki.org dump (41.5 MB download).
# Only needed to update the data: the TSV is tracked in git and `just seed` reads
# it, not the dump. The upstream .jsonl is deprecated and may be removed.
[group('install')]
[doc('Refresh seed/wiktionary-defs.tsv from the kaikki.org dump')]
wiktionary:
  python3 seed/wiktionary.py

[group('install')]
[doc('Download and unzip corpus.zip')]
corpus:
  wget https://github.com/Vincent-Carrier/oxytone/releases/download/1.1/corpus.zip
  unzip corpus.zip

[group('install')]
[doc('Install Saxon-HE into the BaseX custom lib dir')]
saxon:
  wget https://github.com/Saxonica/Saxon-HE/releases/download/SaxonHE12-5/SaxonHE12-5J.zip
  unzip -o SaxonHE12-5J.zip -d saxon-he/
  mkdir -p "$BASEX_HOME/lib/custom/"
  # Saxon needs its main jar plus the xmlresolver jars (nested under lib/).
  # Skip the test/xqj/jline jars: unused, and test/xqj can shadow classes.
  cp saxon-he/saxon-he-12.5.jar \
     saxon-he/lib/xmlresolver-5.2.2.jar \
     saxon-he/lib/xmlresolver-5.2.2-data.jar \
     "$BASEX_HOME/lib/custom/"
  rm -rf SaxonHE12-5J.zip saxon-he/


# Only Homer's TEI is shipped: m:merge is the sole consumer of tei/ and switches
# on tlg0012, so the other 88 authors were 175 MB of the archive that nothing
# ever read. Speaker labels come from @speaker on the treebank, not from TEI.
[group('install')]
[doc('Zip the corpus and publish it as a GitHub release')]
release tag:
  zip -r corpus.zip glaux/ tei/tlg0012/ lsj/
  gh release create {{tag}} corpus.zip --title {{tag}} --notes "Corpus archive: glaux/, tei/tlg0012/, lsj/"
  rm -f corpus.zip

# Build the SvelteKit adapter-node output for production. PUBLIC_BASEX_URL is a
# build-time ($env/static/public) var, so it must be set here for the deployed
# app to reach BaseX through Caddy. During SSR the relative prefix is swapped for
# a direct localhost call (see src/lib/api.ts). Produces a self-contained build/
# (see ssr.noExternal in vite.config.ts).
[group('deploy')]
[doc('Build the production SvelteKit output into build/')]
build-local:
  PUBLIC_BASEX_URL=/basex/ pnpm build

# Deploy to the droplet in deploy/inventory.ini. Builds the frontend first, then
# runs the Ansible playbook (which rsyncs webapp/, repo/, the prebuilt data/ DBs,
# and build/). See DEPLOYMENT.md for the pre-flight checklist.
[group('deploy')]
[doc('Build, then deploy to the droplet via Ansible')]
deploy: build-local
  ansible-playbook -i deploy/inventory.ini deploy/oxytone.yml -e @deploy/vars.yml

[group('deploy')]
[doc('Tail the BaseX service log on the droplet')]
logs-basex:
  ansible oxytone -i deploy/inventory.ini -a 'journalctl -u oxytone-basex -f -n 200'

[group('deploy')]
[doc('Tail the web service log on the droplet')]
logs-web:
  ansible oxytone -i deploy/inventory.ini -a 'journalctl -u oxytone-web -f -n 200'

[group('deploy')]
[doc('Show systemd status for both services on the droplet')]
status:
  ansible oxytone -i deploy/inventory.ini -a 'systemctl status oxytone-basex oxytone-web --no-pager'
