module namespace xsm = "xsm";
declare default element namespace "http://www.w3.org/1999/XSL/Transform";

declare function xsm:stylesheet(
  $templates as map(xs:string, element()*),
  $body as element()* := (),
  $method as xs:string := "xml",
  $indent as xs:string := "no"
) as element() {
  <stylesheet version="3.0">
    <output method="{$method}" indent="{$indent}" encoding="UTF-8"/>
    {for key $match value $template in $templates
      return <template match="{$match}">
        {$template}
      </template>}
    {$body}
  </stylesheet>
};

declare function xsm:attr($name as xs:string, $value as xs:string) as element() {
    <attribute name="{$name}">
      <value-of select="{$value}" />
    </attribute>
};

declare function xsm:keep($select as xs:string := "@*|node()") as element() {
  <copy>
    <apply-templates select="{$select}" />
  </copy>
};
