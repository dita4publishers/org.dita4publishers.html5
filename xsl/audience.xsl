<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="df xs relpath htmlutil xd dc"
  version="2.0">
  <!-- =============================================================

    DITA Map to HTML5 Transformation

    Root output page (navigation/index) generation. This transform
    manages generation of the root page for the generated HTML.
    It calls the processing to generate navigation structures used
    in the root page (e.g., dynamic and static ToCs).

    Copyright (c) 2012 DITA For Publishers

    Licensed under Common Public License v1.0 or the Apache Software Foundation License v2.0.
    The intent of this license is for this material to be licensed in a way that is
    consistent with and compatible with the license of the DITA Open Toolkit.

    This transform requires XSLT 2.
    ================================================================= --> 
   <xsl:variable name="activeAudience" select="/map/topicmeta/data[@name='active-audience'][1]/@value"/>
   
     
  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-audience-select">
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:message> + [INFO] Generating audience select </xsl:message>
    <span id="audience-widget">
    	<h1>
    		<xsl:value-of select="*[df:class(., 'map/topicmeta')]/*[contains(@class, ' topic/audience ')][@name=$activeAudience]/@othertype" />
    		<button class="audienceBtn">
    			<span class="ui-icon ui-icon-carat-2-n-s"><xsl:call-template name="getString">
                    <xsl:with-param name="stringName" select="'chooseAudience'"/>
                </xsl:call-template></span>
    		</button>
    	</h1>
		<ul id="audience-select">
    		<xsl:apply-templates select="*[df:class(., 'map/topicmeta')]" mode="generate-audience-select"/>
    	</ul>
    </span>
   
  </xsl:template>
  
<xsl:template match="*" mode="generate-audience-select">
	<xsl:apply-templates select="*" mode="generate-audience-select"/>
  </xsl:template>

 <xsl:template match="*[contains(@class, ' topic/audience ')]" mode="generate-audience-select">
  <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>
  <xsl:message> + [INFO] Generating audience <xsl:value-of select="@name" /> entry </xsl:message>
  <xsl:if test="@name != $activeAudience">
	<li>
		<a href="{concat($relativePath, $indexUri, '/../../', @name, '/')}">
			<xsl:value-of select="@othertype" />
			<span class="ligther"> <xsl:value-of select="upper-case(@name)" /></span>
		</a>
	</li>
</xsl:if>
  </xsl:template>

</xsl:stylesheet>
