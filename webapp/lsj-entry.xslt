<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"/>
    
    
    <!-- Main template for entryFree -->
    <xsl:template match="entryFree">
        <div class="entry">
            <link href="/static/style.css" rel="stylesheet" />
            <h2 class="headword">
                <xsl:apply-templates select="orth"/>
            </h2>
            <div class="senses">
                <xsl:apply-templates select="sense"/>
            </div>
        </div>
    </xsl:template>
    
    <!-- Template for orthographic form -->
    <xsl:template match="orth">
        <span class="greek-text">
            <xsl:value-of select="."/>
        </span>
    </xsl:template>
    
    <!-- Template for sense -->
    <xsl:template match="sense">
        <div class="sense">
            <xsl:if test="@n">
                <span class="sense-number">
                    <xsl:value-of select="@n"/>. 
                </span>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- Template for bibliographic references -->
    <xsl:template match="bibl">
        <span class="bibl">
            <xsl:apply-templates select="author"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="title"/>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="biblScope"/>
        </span>
    </xsl:template>
    
    <!-- Template for citations -->
    <xsl:template match="cit">
        <div class="citation">
            <span class="quote greek-text">
                <xsl:apply-templates select="quote"/>
            </span>
            <xsl:apply-templates select="bibl"/>
        </div>
    </xsl:template>
    
    <!-- Template for text nodes - preserve spaces -->
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>
    
</xsl:stylesheet>