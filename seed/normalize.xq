(: Warms the `normalized` write-through cache offline, so the first visitor to a
   page does not pay for normalizing it. webapp/read.xqm fills the same cache
   lazily on each cold request, so this is optional — but running it after a
   reseed means nobody hits an empty cache.

   Caches the default (first) page of each work; other pages are cached as they are
   requested. db:put is an updating expression, so it must be the return expression
   rather than a `let` binding, which raises XUST0001. :)
import module namespace urn = 'urn';
import module namespace n = 'normalize';

for $path in db:list('glaux')
  let $work := urn:work($path)
  let $parts := tokenize($work, '/')
  return db:put('normalized', n:get-normalized($parts[1], $parts[2]), $work)
