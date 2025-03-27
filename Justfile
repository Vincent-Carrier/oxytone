db: lsj shortdefs treebanks flatbanks lit catalog

lsj:
    basex -O AUTOFLUSH=false \
          -O ATTRINCLUDE=id -O TEXTINDEX=false \
          -c "CREATE DB lsj" \
          -Q lsj.xq

shortdefs:
    basex -Q shortdefs.xq

treebanks:
    basex -O AUTOFLUSH=false -c "CREATE DB treebanks" \
          -Q treebanks.xq

glaux:
    basex -O AUTOFLUSH=false -c "CREATE DB glaux glaux/" \

flatbanks:
    basex -O AUTOFLUSH=false \
          -O FTINCLUDE=body -O DIACRITICS=true -O CASESENS=true \
          -O ATTRINCLUDE=id,sentence -O TEXTINDEX=false \
          -c "CREATE DB flatbanks" \
          -Q flatbanks.xq

lit:
    basex -O AUTOFLUSH=false \
          -O FTINCLUDE=body -O DIACRITICS=true -O CASESENS=true \
          -c "CREATE DB lit" \
          -Q lit.xq

catalog:
    basex -O AUTOFLUSH=false -c "CREATE DB catalog" \
          -Q catalog.xq
