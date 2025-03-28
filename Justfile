seed: lsj treebanks flatbanks tei catalog

# DB commands
lsj:
    basex -O AUTOFLUSH=false \
          -O ATTRINCLUDE=id -O TEXTINDEX=false \
          -c "CREATE DB lsj" \
          -Q seed/lsj.xq -Q seed/shortdefs.xq

syntax:
    basex -O AUTOFLUSH=false -c "CREATE DB syntax" \
          -Q seed/syntax.xq

glaux:
    basex -O AUTOFLUSH=false \
          -O ATTRINCLUDE=id,head,form,lemma,relation,speaker,div_chapter,div_section,analysis \
          -c "CREATE DB glaux glaux/"

tei:
    basex -O AUTOFLUSH=false -O STRIPNS=true \
          -O FTINCLUDE=body -O DIACRITICS=true -O CASESENS=true \
          -c "CREATE DB tei tei/" \

index:
    basex -Q seed/index.xq

# Dev commands
basex:
  basexhttp -d

svelte:
  pnpm dev

fastapi:
  fastapi dev
