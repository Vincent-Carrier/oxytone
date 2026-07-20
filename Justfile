set unstable
set script-interpreter := ["bash", "-euxo", "pipefail"]

export BASEX_HOME := x"~/.basex"

[group('db')]
seed: lsj glaux tei index normalized

[group('db')]
lsj:
  basex -Q seed/shortdefs.xq
  basex -O ATTRINCLUDE=id -O TEXTINDEX=false \
        -c "CREATE DB lsj" \
        -Q seed/lsj.xq

[group('db')]
syntax:
  basex -c "CREATE DB syntax" \
        -Q seed/syntax.xq

[group('db')]
normalized:
  basex -c "CREATE DB normalized"

[group('db')]
glaux:
  basex -O MAXCATS=10000 -O ATTRINCLUDE=id,head,form,lemma,relation,speaker,div_chapter,div_section,analysis \
        -c "CREATE DB glaux glaux/"

[group('db')]
tei:
  basex -O STRIPNS=true \
        -O FTINCLUDE=body -O DIACRITICS=true -O CASESENS=true \
        -c "CREATE DB tei tei/" \

english:
  basex -O STRIPNS=true \
        -O FTINCLUDE=body \
        -c "CREATE DB english eng/" \

[group('db')]
index:
  basex -Q seed/index.xq


[group('dev')]
basex:
  basexhttp -d

[group('dev')]
svelte:
  pnpm dev


[group('install')]
install:
  pnpm install

[group('install')]
corpus:
  wget https://github.com/Vincent-Carrier/oxytone/releases/download/1.0/corpus.zip
  unzip corpus.zip

# Rebuild glaux/ from the GLAUx source repo (corpus.zip ships without it).
# Set GLAUX_SRC to override the default ../glaux clone location.
[group('install')]
glaux-rebuild:
  bash seed/glaux-rebuild.sh

[group('install')]
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


release:
  zip -r corpus.zip glaux/ tei/ lsj/
  gh release create corpus.zip
  rm -f corpus.zip

# Build the SvelteKit adapter-node output for production. PUBLIC_BASEX_URL is a
# build-time ($env/static/public) var, so it must be set here for the deployed
# app to reach BaseX through Caddy. During SSR the relative prefix is swapped for
# a direct localhost call (see src/lib/api.ts). Produces a self-contained build/
# (see ssr.noExternal in vite.config.ts).
[group('deploy')]
build-local:
  PUBLIC_BASEX_URL=/basex/ pnpm build

# Deploy to the droplet in deploy/inventory.ini. Builds the frontend first, then
# runs the Ansible playbook (which rsyncs webapp/, repo/, the prebuilt data/ DBs,
# and build/). See DEPLOYMENT.md for the pre-flight checklist.
[group('deploy')]
deploy: build-local
  ansible-playbook -i deploy/inventory.ini deploy/oxytone.yml -e @deploy/vars.yml

[group('deploy')]
logs-basex:
  ansible oxytone -i deploy/inventory.ini -a 'journalctl -u oxytone-basex -f -n 200'

[group('deploy')]
logs-web:
  ansible oxytone -i deploy/inventory.ini -a 'journalctl -u oxytone-web -f -n 200'

[group('deploy')]
status:
  ansible oxytone -i deploy/inventory.ini -a 'systemctl status oxytone-basex oxytone-web --no-pager'
