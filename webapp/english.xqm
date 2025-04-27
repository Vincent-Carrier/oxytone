module namespace eng = "oxytone/eng";
import module namespace xsm = "xsm";

declare namespace xsl = "http://www.w3.org/1999/XSL/Transform";

declare variable $eng:xslt := xsm:stylesheet({
  "/":
    <main>
      <xsl:apply-templates />
    </main>,
  "div[@subtype='section']": <section><xsl:apply-templates /></section>,
  "label": <i><xsl:apply-templates /></i>,
  "p|q": xsm:keep('node()'),
  "note|head": ()
});


declare
  %rest:path("/english/{$author}/{$work}")
  %output:method("html")
  function eng:get-work($author, $work) {
    let $tei := db:get('english', `{$author}/{$work}`)[1]
    let $_ := trace(($tei//body//p)[1])
    return xslt:transform($tei/TEI/text/body, $eng:xslt)
};
