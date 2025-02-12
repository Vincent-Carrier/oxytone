db: lsj treebanks lit catalog

lsj:
    basex -c "DROP DATABASE lsj" \
          -c "CREATE DB lsj lsj/"

treebanks:
    basex -c "DROP DATABASE treebanks" \
          -c "DROP DATABASE flatbanks" \
          -c "CREATE DB treebanks" \
          -c "CREATE DB flatbanks" \
          -Q treebanks.xq

lit:
    basex -c "DROP DATABASE lit" \
          -c "CREATE DB lit lit/" \
          -Q lit.xq

catalog:
    basex -c "DROP DATABASE catalog" \
          -c "CREATE DB catalog" \
          -Q catalog.xq
