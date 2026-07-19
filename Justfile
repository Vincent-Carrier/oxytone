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

[group('dev')]
fastapi:
  uv run fastapi dev


[group('install')]
install:
  uv pip sync pyproject.toml
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

# NOTE: Some changes may not take effect until Cloudflare cache is purged or `normalized` DB is reset.
build:
  git pull
  pnpm build
  systemctl restart paroxytone.target
