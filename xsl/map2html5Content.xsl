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
  xmlns:date="java:java.util.Date"
  exclude-result-prefixes="#all"
  version="2.0"
>

  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-content">
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:message> + [INFO] Generating content...</xsl:message>
    <xsl:if test="false() and $debugBoolean">
      <xsl:message> + [DEBUG] ------------------------------- + [DEBUG] Unique topics: <xsl:for-each
          select="$uniqueTopicRefs"> + [DEBUG] <xsl:sequence select="name(.)"/>: generated id="<xsl:sequence
            select="generate-id(.)"/>", URI=<xsl:sequence select="document-uri(root(.))"/>
        </xsl:for-each> + [DEBUG] ------------------------------- </xsl:message>
    </xsl:if>
    <xsl:apply-templates select="$uniqueTopicRefs" mode="generate-content"/>
    <!--xsl:message> + [INFO] Generating title-only topics for topicheads...</xsl:message-->
    <!--xsl:apply-templates select=".//*[df:isTopicHead(.)]" mode="generate-content"/-->
    <xsl:message> + [INFO] Content generated.</xsl:message>
  </xsl:template>


  <xsl:template mode="generate-content"
                match="*[df:isTopicRef(.)]
                          [not(@scope = ('peer', 'external'))]
                          [not(@format) or (@format = 'dita')]"
    >
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>
    <xsl:if test="$debugBoolean">
      <xsl:message> + [DEBUG] Handling topicref to "<xsl:sequence select="string(@href)"/>" in mode
        generate-content</xsl:message>
    </xsl:if>

    <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>

    <xsl:choose>
      <xsl:when test="not($topic)">
        <xsl:message> + [WARNING] generate-content: Failed to resolve topic reference to href "<xsl:sequence
            select="string(@href)"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="topicResultUri" 
          select="htmlutil:getTopicResultUrl2($outdir, root($topic), ., $rootMapDocUrl)"
          as="xs:string"/>
        <xsl:variable name="topicRelativeUri" select="relpath:getRelativePath($outdir, $topicResultUri)"
          as="xs:string"/>

        <xsl:variable name="tempTopic" as="document-node()">
          <xsl:document>
            <xsl:apply-templates select="$topic" mode="href-fixup">
              <xsl:with-param name="topicResultUri" select="$topicResultUri" tunnel="yes"/>
            </xsl:apply-templates>
         </xsl:document>
        </xsl:variable>
        
        <xsl:apply-templates select="$tempTopic" mode="#current">
          <xsl:with-param name="topicref" as="element()*" select="." tunnel="yes"/>
          <xsl:with-param name="collected-data" select="$collected-data" as="element()" tunnel="yes"/>
          <xsl:with-param name="resultUri" select="$topicResultUri" tunnel="yes"/>
          <xsl:with-param name="topicRelativeUri" select="$topicRelativeUri" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/topic')]" mode="generate-content">
    <!-- This template generates the output file for a referenced topic.
    -->
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <!-- The topicref that referenced the topic -->
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <!-- Enumerables structure: -->
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>

    <xsl:param name="baseUri" as="xs:string" tunnel="yes"/>
    <!-- Result URI to which the document should be written. -->
    <xsl:param name="resultUri" as="xs:string" tunnel="yes"/>
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="startTime" select="date:getTime(date:new())" as="xs:integer"/>
    

    <xsl:variable name="docUri" select="relpath:toUrl(@xtrf)" as="xs:string"/>
    <xsl:variable name="parentDocUri" select="relpath:getParent($resultUri)" as="xs:string"/>

    <xsl:variable name="parentPath" select="$outdir" as="xs:string"/>
    <!--xsl:variable name="parentPath" select="relpath:getParent($baseUri)" as="xs:string"/-->
    <xsl:variable name="relativePath" select="concat(relpath:getRelativePath($parentDocUri, $parentPath), '')"
      as="xs:string"/>

    <!--xsl:message>docUri is: <xsl:value-of select="$docUri"/></xsl:message>
      <xsl:message>resultUri is: <xsl:value-of select="$resultUri"/></xsl:message>
       <xsl:message>map:  <xsl:value-of select="$baseUri"/></xsl:message>
      <xsl:message>parentPath is: <xsl:value-of select="$parentPath"/></xsl:message>
      <xsl:message>relativePath is: <xsl:value-of select="$relativePath"/></xsl:message>
    <xsl:message>topic-title is: <xsl:value-of select="$topic-title"/></xsl:message-->
        
    <xsl:if test="$doDebug">
      <xsl:message  > + [DEBUG] Writing topic <xsl:sequence select="document-uri(root(.))"/> to HTML file "<xsl:sequence
        select="$resultUri"/>"...</xsl:message>
    </xsl:if>

    <xsl:variable name="generatePageStartTime" as="xs:integer" select="date:getTime(date:new())"/>

    <xsl:result-document format="{$xsloutput}" href="{$resultUri}">
      <xsl:apply-templates mode="generate-html5-page" select=".">
        <xsl:with-param name="relativePath" select="$relativePath" as="xs:string" tunnel="yes"/>
        <xsl:with-param name="resultUri" as="xs:string" select="$resultUri" tunnel="yes"/>
        <xsl:with-param name="topicref" select="$topicref" as="element()?" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:result-document>
    
    <xsl:if test="$doDebug">
      <xsl:variable name="stopTime" as="xs:integer" select="date:getTime(date:new())"/>
      <xsl:message> + [TIMING] generate-html5-page took <xsl:value-of select="($stopTime - $generatePageStartTime) div 1000"/> seconds</xsl:message>
      <xsl:message> + [TIMING] Total generation time: <xsl:value-of select="($stopTime - $startTime) div 1000"/> seconds</xsl:message>
      <xsl:variable name="phase1" as="xs:integer" select="$stopTime - $generatePageStartTime"/>
      <xsl:variable name="full" as="xs:integer" select="$stopTime - $startTime"/>
      <xsl:message> + [TIMING] CSV: generate-content,<xsl:sequence select="$phase1"/>,<xsl:sequence select="$full"/>,<xsl:sequence select="$resultUri"></xsl:sequence></xsl:message>
    </xsl:if>
    
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/topic')]" priority="100" mode="map-driven-content-processing">
    <!-- This template is a general dispatch template that applies
      templates to the topicref in a distinct mode so processors
      can do topic output processing based on the topicref context
      if they want to. -->
    <xsl:param name="topicref" as="element()?" tunnel="yes"/>
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>

    <xsl:choose>
      <xsl:when test="$topicref">
        <xsl:apply-templates select="$topicref" mode="topicref-driven-content">
          <xsl:with-param name="topic" select="." as="element()?"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <!-- Do default processing -->
        <xsl:apply-templates select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="topicref-driven-content" match="*[df:class(., 'map/topicref')][not(@processing-role = 'resource-only')]">
    <!-- Default topicref-driven content template. Simply applies normal processing
      in the default context to the topic parameter. -->
    <xsl:param name="topic" as="element()?"/>
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>

    <xsl:if test="false() and $debugBoolean">
      <xsl:message> + [DEBUG] topicref-driven-content: topicref="<xsl:sequence select="name(.)"/>, class="<xsl:sequence
          select="string(@class)"/>"</xsl:message>
    </xsl:if>
    <xsl:variable name="topicref" select="." as="element()"/>
    <xsl:for-each select="$topic">
      <!-- Process the topic in the default mode, meaning the base Toolkit-provided
        HTML output processing.

        By providing the topicref as a tunneled parameter it makes it available
        to custom extensions to the base Toolkit processing.
      -->
      <xsl:apply-templates select=".">
        <xsl:with-param name="topicref" select="$topicref" as="element()?" tunnel="yes"/>
        <xsl:with-param name="collected-data" select="$collected-data" as="element()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

  <xsl:template
    match="
    *[df:class(., 'topic/body')]//*[df:class(., 'topic/indexterm')] |
    *[df:class(., 'topic/shortdesc')]//*[df:class(., 'topic/indexterm')] |
    *[df:class(., 'topic/abstract')]//*[df:class(., 'topic/indexterm')]
    "
    priority="10">
    <xsl:if test="false() and $debugBoolean">
      <xsl:message> + [DEBUG] Found an index item in topic content: [<xsl:sequence select="string(.)"/>]</xsl:message>
    </xsl:if>
    <a id="{generate-id()}" class="indexterm-anchor"/>
  </xsl:template>

  <!-- NOTE: the body of this template is taken from the base dita2xhtmlImpl.xsl -->
  <xsl:template match="*[df:class(., 'topic/topic')]/*[df:class(., 'topic/title')]">
    <xsl:param name="topicref" select="()" as="element()?" tunnel="yes"/>
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>

    <xsl:param name="headinglevel">
      <xsl:choose>
        <xsl:when test="count(ancestor::*[contains(@class,' topic/topic ')]) > 6">6</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:variable name="htmlClass" select="concat('topictitle', $headinglevel)" as="xs:string"/>
    <xsl:element name="h{$headinglevel}">
      <xsl:attribute name="class" select="$htmlClass"/>
      <xsl:call-template name="commonattributes">
        <xsl:with-param name="default-output-class" select="$htmlClass" as="xs:string"/>
      </xsl:call-template>
      <xsl:apply-templates select="$topicref" mode="enumeration"/>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*[df:class(., 'map/topicmeta')]" priority="10"/>


</xsl:stylesheet>
