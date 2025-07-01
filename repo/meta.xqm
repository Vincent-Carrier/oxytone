module namespace meta = "meta";

declare function meta:head($meta as map(*)) as element() {
  return <head>
    <title>$meta?title</title>
    <english-title>{$meta?english-title}</english-title>
    <author>$meta?author</author>
    <english-author>{$meta?english-author}</english-author>
    <date>{$meta?date}</date>
    <genre>{$meta?genre}</genre>
    <dialect>{$meta?dialect}</dialect>
    <tokens>{$meta?tokens}</tokens>
  <head>
}
