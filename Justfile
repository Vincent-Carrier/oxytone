set unstable
set script-interpreter := ["bash", "-euxo", "pipefail"]

export BASEX_HOME := x"~/.local/share/basex"

[group('db')]
seed: lsj glaux tei index

[group('db')]
lsj:
  basex -O AUTOFLUSH=false \
        -O ATTRINCLUDE=id -O TEXTINDEX=false \
        -c "CREATE DB lsj" \
        -Q seed/lsj.xq -Q seed/shortdefs.xq

[group('db')]
syntax:
  basex -O AUTOFLUSH=false -c "CREATE DB syntax" \
        -Q seed/syntax.xq

[group('db')]
glaux:
  basex -O AUTOFLUSH=false \
        -O ATTRINCLUDE=id,head,form,lemma,relation,speaker,div_chapter,div_section,analysis \
        -c "CREATE DB glaux glaux/"

[group('db')]
tei:
  basex -O AUTOFLUSH=false -O STRIPNS=true \
        -O FTINCLUDE=body -O DIACRITICS=true -O CASESENS=true \
        -c "CREATE DB tei tei/" \

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
install: saxon corpus
  uv install
  pnpm install

[group('install')]
corpus:
  wget https://github.com/Vincent-Carrier/paroxytone/releases/download/0.1/corpus.zip
  unzip corpus.zip

[group('install')]
saxon:
  wget https://github.com/Saxonica/Saxon-HE/releases/download/SaxonHE12-5/SaxonHE12-5J.zip
  unzip SaxonHE12-5J.zip -d saxon-he/
  mkdir -p "$BASEX_HOME/lib/custom/"
  mv saxon-he/**.jar "$BASEX_HOME/lib/custom/"
  rm -rf SaxonHE12-5J.zip saxon-he/


release:
  zip -r corpus.zip glaux/ tei/
  gh release create corpus.zip
