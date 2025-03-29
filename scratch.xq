let $tb := db:get('glaux', 'tlg0059/tlg005')

return $tb update {
  delete nodes //sentence[4 to last()],
  for $ref in distinct-values(//@div_stephanus_section)
    let $w := (//word[@div_stephanus_section = $ref])[1]
    return insert node <ref id="{$ref}" /> into $w/..
}
