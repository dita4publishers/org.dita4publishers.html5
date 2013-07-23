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
  
  <xsl:template match="*" mode="generate-javascript-includes">  
		<xsl:apply-templates select="." mode="generate-d4p-javascript" />
  </xsl:template>
  
  
  <!-- this template is used to add compressed or none-compressed javascripts links -->
  <xsl:template match="*" mode="generate-d4p-javascript">
  	<xsl:choose>
  		<xsl:when test="$DBG='yes'">
  			<xsl:apply-templates select="." mode="generate-d4p-uncompressed-javascript" />
  		</xsl:when>  		
  		<xsl:otherwise>
  			<xsl:apply-templates select="." mode="generate-d4p-compressed-javascript" />		
  		</xsl:otherwise> 	
  	</xsl:choose>		
  </xsl:template>
  
  <!-- This template render ons script element per script element declared in the theme config.xml -->  
  <xsl:template match="*" mode="generate-d4p-uncompressed-javascript">
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes" />
    <xsl:for-each select="$HTML5THEMECONFIGDOC/html5/script">
    	<script type="text/javascript" charset="utf-8" src="{relpath:assets-uri($relativePath, @path)}"></script><xsl:sequence select="'&#x0a;'"/>
    </xsl:for-each>
    <xsl:apply-templates select="." mode="generate-d4p-javascript-initializer" />	
  </xsl:template>
  
   
  <!-- 
    used to generate the js links 
    FIXME: find a way to translate javascript variables.
    ex: d4p.locale: {
      'property': 'value',
      'property2': 'value2',
      ...    
    }
  --> 
  <xsl:template match="*" mode="generate-d4p-compressed-javascript">
  	<xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes" />
  	
    <script type="text/javascript" src="{relpath:fixRelativePath($relativePath, $JS)}">
  		<xsl:sequence select="'&#x0a;'"/>
  	</script>
    <xsl:sequence select="'&#x0a;'"/>
    
    <xsl:apply-templates select="." mode="generate-d4p-javascript-initializer" />	

  </xsl:template>
  
 <xsl:template match="*" mode="generate-d4p-javascript-initializer">
   <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes" />
   <xsl:variable name="json" as="xs:string">
   
   
   	<xsl:choose>
   		<xsl:when test="$JSONVARFILE!=''">
   			<xsl:value-of select="unparsed-text($JSONVARFILE, 'UTF-8')" />
   		</xsl:when>
   		<xsl:otherwise><xsl:value-of select="''" /></xsl:otherwise>
   	</xsl:choose>
   </xsl:variable>
   
	<xsl:if test="$HTML5THEMECONFIGDOC/html5/d4p/init='true'">
    	<script type="text/javascript"><xsl:sequence select="'&#x0a;'"/>
   		  		
   		<xsl:if test="$json != ''">
			<xsl:value-of select="$json" /><xsl:text>;</xsl:text>
			<xsl:sequence select="'&#x0a;'"/>
		</xsl:if>	

   		<xsl:text>$(function(){d4p.init({</xsl:text>
   		<xsl:text>relativePath:'</xsl:text><xsl:value-of select="$relativePath"/><xsl:text>'</xsl:text>
     			
   			<xsl:if test="$jsoptions != ''">
   				<xsl:text>, </xsl:text>
				<xsl:value-of select="$jsoptions" />
			</xsl:if>
		<xsl:text>});});</xsl:text>
		</script><xsl:sequence select="'&#x0a;'"/>
 	</xsl:if>
 </xsl:template>
 
</xsl:stylesheet>
