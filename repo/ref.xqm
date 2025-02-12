module namespace ref = "ref";

declare function ref:from-str($str) {
    let $parts := tokenize($str, '-')
    return (
        attribute start {$parts[1]},
        attribute end {$parts[2]}
    )
};

declare function ref:get-book($tb, $book as xs:integer) {
    <body>{
        for $s in $tb/treebank/body/sentence
        let $parts := ref:from-str($s/@subdoc/string())
        let $book := tokenize($parts[1], '\.')[1] => parse-integer()
        where $book = $book
        return $s
    }</body>
};
