(: Loads the English translations under tei/ into the `translations` DB.

   Stored under {author}/{work}/{edition}.xml rather than their tei/ path, so
   db:get('translations', '{$author}/{$work}') returns a work's editions the same
   way m:merge reaches the Greek ones in `tei`.

   Adds nothing when `just translations` has not been run, leaving the empty DB
   the recipe just created — webapp/translate.xqm reads that as "no translation
   for this work", which is the common case anyway. :)
(: fetch:doc rather than doc(): a db:add running against the open `translations`
   DB resolves a relative doc() path inside it, not on disk. :)
for $path in file:list('tei', true(), '*eng*.xml')
  let $rel := replace($path, '\\', '/')
  return db:add('translations', fetch:doc(file:resolve-path('tei/' || $rel)), $rel)
