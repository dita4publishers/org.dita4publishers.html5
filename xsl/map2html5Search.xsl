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
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:str="http://www.w3.org/2005/xpath-functions"
  xmlns:json="http://json.org/"
  exclude-result-prefixes="df xs relpath htmlutil xd json"
  version="2.0"
>

  <xsl:output name="json" method="text" indent="no" encoding="utf-8" omit-xml-declaration="yes"/>

  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-search-index">
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:message> + [INFO] Generating search index ...</xsl:message>

    <xsl:variable name="searchindex">
      <idx>
        <topics>
          <xsl:apply-templates select="$uniqueTopicRefs" mode="generate-search-index"/>
        </topics>
      </idx>
    </xsl:variable>

    <xsl:result-document format="json" href="search-index.json">
      <xsl:value-of select="json:generate($searchindex)"/>
    </xsl:result-document>

    <xsl:message> + [INFO] Search index generated.</xsl:message>
  </xsl:template>


  <xsl:template mode="generate-search-index"
                match="*[df:isTopicRef(.)]
                          [not(@scope = ('peer', 'external'))]
                          [not(@format) or @format = ('dita')]
    " >
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>

    <xsl:if test="false() and $debugBoolean">
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
          select="htmlutil:getTopicResultUrl2('', root($topic), ., $rootMapDocUrl)"
          as="xs:string"/>
        <xsl:variable name="number"><xsl:number value="position()" format="1" /></xsl:variable>


         <xsl:element name="{concat('t', $number)}">
          <xsl:apply-templates select="$topic" mode="#current">
            <xsl:with-param name="topicref" as="element()*" select="." tunnel="yes"/>
            <xsl:with-param name="collected-data" select="$collected-data" as="element()" tunnel="yes"/>
            <xsl:with-param name="resultUri" select="$topicResultUri" tunnel="yes"/>
            <xsl:with-param name="id"  as="xs:string" select="concat('t', $number)" tunnel="yes"/>
          </xsl:apply-templates>

        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--xsl:template match="*" mode="generate-content" priority="-1">
    <xsl:message> + [DEBUG] In catchall for generate-content, got
      <xsl:sequence select="."/></xsl:message>
  </xsl:template-->

  <xsl:template match="*[df:class(., 'topic/topic')]" mode="generate-search-index">
    <!-- This template generates the output file for a referenced topic.
    -->
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="id" as="xs:string" tunnel="yes"/>
    <!-- The topicref that referenced the topic -->
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <!-- Enumerables structure: -->
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>

    <xsl:param name="baseUri" as="xs:string" tunnel="yes"/>
    <!-- Result URI to which the document should be written. -->
    <xsl:param name="resultUri" as="xs:string" tunnel="yes"/>

    <xsl:variable name="docUri" select="relpath:toUrl(@xtrf)" as="xs:string"/>
    <xsl:variable name="parentDocUri" select="relpath:getParent($resultUri)" as="xs:string"/>

    <xsl:variable name="parentPath" select="$outdir" as="xs:string"/>

    <id><xsl:value-of select="$id" /></id>
    <href><xsl:value-of select="$resultUri" /></href>
    <title><xsl:value-of select="*[df:class(., 'topic/title')][1]" /></title>
    <desc>
      <xsl:value-of select="*[df:class(., 'topic/shortdesc')][1]" />
    </desc>
    <keywords>
      <xsl:apply-templates select="//*[df:class(., 'topic/keyword')]" mode="search-filter" />
    </keywords>

  </xsl:template>

  <xsl:template match="text()" mode="search-filter">

  <xsl:for-each select="str:tokenize(., ' ')">
     <xsl:choose>
       <xsl:when test="fn:string-length(.) &gt; $searchEngineMinLength">
         <xsl:value-of select="concat(., ' ')"/>
       </xsl:when>
       <xsl:otherwise/>
     </xsl:choose>
   </xsl:for-each>
  </xsl:template>


</xsl:stylesheet>
