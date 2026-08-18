(: Warms the `normalized` write-through cache offline, so the first visitor to a
   page does not pay to build it. webapp/read.xqm fills the same cache lazily on
   each cold request, so this is optional — but running it after a reseed means
   nobody hits an empty cache.

   Stores the rendered markup, as read.xqm does: the cache holds what the endpoint
   serves, so a hit is a read and nothing else. Both must agree on that, or a
   warmed entry would be served as-is having never been through the stylesheet.

   Caches the default (first) page of each work; other pages are cached as they are
   requested. db:put is an updating expression, so it must be the return expression
   rather than a `let` binding, which raises XUST0001. :)
import module namespace urn = 'urn';
import module namespace n = 'normalize';
import module namespace r = 'oxytone/read' at '../webapp/read.xqm';

for $path in db:list('glaux')
  let $work := urn:work($path)
  let $parts := tokenize($work, '/')
  return db:put('normalized', r:render(n:get-normalized($parts[1], $parts[2])), $work)
