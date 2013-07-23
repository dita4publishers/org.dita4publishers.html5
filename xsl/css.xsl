<?xml version="1.0" encoding="utf-8"?>   
<!--   
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
-->

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


  <!-- used to generate the css links -->
  <xsl:template match="*" mode="generate-css-includes">
     <xsl:apply-templates select="." mode="generate-d4p-css" />
  </xsl:template>
    
  <!-- this template is used to add compressed or none-compressed javascripts links -->
  <xsl:template match="*" mode="generate-d4p-css">
  	<xsl:choose>
  		<xsl:when test="$DBG='yes'">
  			<xsl:apply-templates select="." mode="generate-d4p-uncompressed-css" />
  		</xsl:when>  		
  		<xsl:otherwise>
  			<xsl:apply-templates select="." mode="generate-d4p-compressed-css" />		
  		</xsl:otherwise> 	
  	</xsl:choose>		
  </xsl:template>
  
  <!-- This template render ons script element per script element declared in the theme config.xml -->  
  <xsl:template match="*" mode="generate-d4p-uncompressed-css">
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes" />
    <xsl:for-each select="$HTML5THEMECONFIGDOC/html5/tag/source/file">
    	<link 
    		rel="stylesheet" 
    		type="text/css" 
    		href="{relpath:assets-uri($relativePath, @path)}" />
    	<xsl:sequence select="'&#x0a;'"/>
    </xsl:for-each>
  </xsl:template>

   <xsl:function name="relpath:assets-uri" as="xs:string">
    <xsl:param name="relativePath" as="xs:string*"/> 
    <xsl:param name="path" as="xs:string*"/>
    
	<xsl:variable name="pathwithdir">
    <xsl:choose>
    	<xsl:when test="$HTTPABSOLUTEURI != ''">
    		<xsl:value-of select="concat($HTTPABSOLUTEURI, $HTML5THEMEDIR, '/', $path)" />
   	
    	</xsl:when>    	
    	<xsl:otherwise>
    		<xsl:value-of select="relpath:fixRelativePath($relativePath, concat($HTML5THEMEDIR, '/', $path))" />
    	</xsl:otherwise>   	
    </xsl:choose>
    </xsl:variable>
    
    <xsl:sequence select="$pathwithdir" />   
  </xsl:function>
   
  
   <xsl:template match="*" mode="generate-d4p-compressed-css">
  <!-- prevent aboslute path to be rewritten -->
  	<xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes" />
    	
  	<xsl:if test="$CSS!=''">
     	<link rel="stylesheet" type="text/css" href="{relpath:fixRelativePath($relativePath, $CSS)}" />
    </xsl:if>
    
    <xsl:sequence select="'&#x0a;'"/>
    
    <link rel="stylesheet" type="text/css" href="{relpath:fixRelativePath($relativePath, concat($html5CSSPath, $HTML5THEMECONFIGDOC/html5/tag/output, '-min.css'))}" />
    	<xsl:sequence select="'&#x0a;'"/>
    
  </xsl:template>
  



</xsl:stylesheet>
