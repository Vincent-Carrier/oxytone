<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="no" encoding="UTF-8"/>
    <xsl:template match="body">
      <body>
          <xsl:apply-templates />
      </body>
    </xsl:template>

    <xsl:template match="sentence">
        <div class="sentence">
            <xsl:apply-templates select="w"/>
            <xsl:apply-templates select="br"/>
        </div>
    </xsl:template>

    <xsl:template match="w">
        <ox-w>
            <xsl:copy-of select="./*|@*|text()"/>
        </ox-w>
    </xsl:template>

    <xsl:template match="br">
        <br/>
    </xsl:template>
</xsl:stylesheet>
