<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>

    <xsl:template match="body">
        <html>
            <head>
                <title>Greek Text</title>
                <style>
                    .sentence{display:block;margin:1em 0}
                    .ln{color:#666;margin-right:1em}
                    w-token,.word{display:inline-block;margin-right:.5em}
                    .definition,.pos,.case{color:#666;font-size:90%}
                </style>
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="sentence">
        <div class="sentence">
            <xsl:apply-templates select="word"/>
        </div>
    </xsl:template>

    <xsl:template match="word">
        <w-token>
            <xsl:attribute name="n">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
            <xsl:attribute name="lemma">
                <xsl:value-of select="@lemma"/>
            </xsl:attribute>
            <xsl:attribute name="flags">
                <xsl:value-of select="@postag"/>
            </xsl:attribute>
            <xsl:attribute name="role">
                <xsl:value-of select="@relation"/>
            </xsl:attribute>
            <xsl:value-of select="@form"/>
        </w-token>
    </xsl:template>

    <xsl:template match="br">
        <br/>
    </xsl:template>
    <xsl:template match="text()[normalize-space(.)='']"/>

</xsl:stylesheet>
