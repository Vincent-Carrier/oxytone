seed: lsj treebanks flatbanks lit catalog

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
          -O ATTRINCLUDE=id,head,form,lemma,relation,speaker,div_chapter,div_section \
          -c "CREATE DB glaux glaux/"

lit:
    basex -O AUTOFLUSH=false \
          -O FTINCLUDE=body -O DIACRITICS=true -O CASESENS=true \
          -c "CREATE DB lit" \
          -Q seed/lit.xq

catalog:
    basex -O AUTOFLUSH=false -c "CREATE DB catalog" \
          -Q seed/catalog.xq
