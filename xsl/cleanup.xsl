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
  
  <!-- Reduces the stored size of result HTML files by squeezing out
       all unneeded white space.
    -->

  <xsl:function name="df:cleanNewLine" as="node()*">
    <xsl:param name="tree" as="node()*"/>
    
    <xsl:call-template name="cleanup-tree">
      <xsl:with-param name="tree" select="$tree" as="node()*"/>
    </xsl:call-template>
  </xsl:function>

  <xsl:template name="cleanup-tree">
    <xsl:param name="tree" as="node()*"/>
    <xsl:choose>
      <xsl:when test="$html5outputsizestrategyBoolean and not($ISDRAFT)">
        <xsl:apply-templates select="$tree" mode="clean-linebreaks"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$tree"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="clean-linebreaks" priority="10">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|node()" mode="clean-linebreaks">
    <xsl:sequence select="."/>
  </xsl:template>

  <!-- Thanks to Dimitre Novatchev -->
  <xsl:template match="text()[not(string-length(normalize-space()))]"  mode="clean-linebreaks" priority="10"/>

  <xsl:template match="text()[string-length(normalize-space()) > 0]"  mode="clean-linebreaks" priority="10">
    <xsl:value-of select="translate(.,'&#x20;&#xD;&#xA;', '  ')"/>
  </xsl:template>

  <xsl:template match="processing-instruction()|comment()"  mode="clean-linebreaks" priority="10"/>

  <xsl:template match="pre" mode="clean-linebreaks" priority="20">
    <xsl:sequence select="."/>
  </xsl:template>

</xsl:stylesheet>
