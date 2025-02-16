db: lsj treebanks flatbanks lit catalog

lsj:
    basex -O AUTOFLUSH=false -c "CREATE DB lsj lsj/"

treebanks:
    basex -O AUTOFLUSH=false -c "CREATE DB treebanks" \
          -Q treebanks.xq

flatbanks:
    basex -O MAINMEM=true -O ATTRINCLUDE=id,sentence_id -O TEXTINDEX=false \
          -c "CREATE DB flatbanks" \
          -Q flatbanks.xq

lit:
    basex -O AUTOFLUSH=false -c "CREATE DB lit" \
          -Q lit.xq

catalog:
    basex -O AUTOFLUSH=false -c "CREATE DB catalog" \
          -Q catalog.xq
