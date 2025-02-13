db: lsj treebanks flatbanks lit catalog

lsj:
    basex -O AUTOFLUSH=false -c "DROP DATABASE lsj" \
          -c "CREATE DB lsj lsj/"

treebanks:
    basex -O AUTOFLUSH=false -c "DROP DATABASE treebanks" \
          -c "CREATE DB treebanks" \
          -Q treebanks.xq

flatbanks:
    basex -O AUTOFLUSH=false -c "DROP DATABASE flatbanks" \
          -c "CREATE DB flatbanks" \
          -Q flatbanks.xq

lit:
    basex -O AUTOFLUSH=false -c "DROP DATABASE lit" \
          -c "CREATE DB lit" \
          -Q lit.xq

catalog:
    basex -O AUTOFLUSH=false -c "DROP DATABASE catalog" \
          -c "CREATE DB catalog" \
          -Q catalog.xq
