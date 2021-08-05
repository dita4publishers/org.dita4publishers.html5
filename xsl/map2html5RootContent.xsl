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
  exclude-result-prefixes="#all"
  version="3.0"
>

  <!-- generate root pages -->
  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-root-pages">
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:choose>
      <xsl:when test="$indexIsFirstTopicBoolean">
        <xsl:apply-templates select="./*[df:isTopicRef(.)][not(contains(@class, ' mapgroup-d/keydef '))][not(@scope = ('peer', 'external'))]
                          [not(@format) or (@format = 'dita')][1]" mode="generate-root-first-topic-page"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:apply-templates select="." mode="generate-root-nav-page"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

   <xsl:template match="*" mode="generate-root-pages"/>

   <xsl:template mode="generate-root-first-topic-page" match="*[df:isTopicRef(.)]">
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
        <xsl:variable name="tempTopic" as="document-node()">
          <xsl:document>
            <xsl:apply-templates select="$topic" mode="href-fixup">
              <xsl:with-param name="topicResultUri" select="$indexUri" tunnel="yes"/>
            </xsl:apply-templates>
         </xsl:document>
        </xsl:variable>

        <xsl:apply-templates select="$tempTopic" mode="#current">
          <xsl:with-param name="topicref" as="element()*" select="." tunnel="yes"/>
          <xsl:with-param name="collected-data" select="$collected-data" as="element()" tunnel="yes"/>
        </xsl:apply-templates>


      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[df:class(., 'topic/topic')]" mode="generate-root-first-topic-page">
    <!-- This template generates the output file for a referenced topic.
    -->
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <!-- The topicref that referenced the topic -->
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <!-- Enumerables structure: -->
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>

    <xsl:variable name="resultUri" as="xs:string" select="relpath:newFile($outdir, $indexUri)"/>

    <xsl:message> + [INFO] Writing first topic to HTML file "<xsl:sequence select="$resultUri"/>"...</xsl:message>

     <xsl:result-document format="{$xsloutput}" href="{$indexUri}">
      <xsl:apply-templates mode="generate-html5-page" select=".">
        <xsl:with-param name="resultUri" as="xs:string" select="$resultUri" tunnel="yes"/>
        <xsl:with-param name="is-root" as="xs:boolean" select="false()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:result-document>

     <xsl:message> + [INFO] Done !</xsl:message>

  </xsl:template>


  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-root-nav-page">
    <!-- Generate the root output page. By default this page contains the root
         navigation elements. The direct output of this template goes to the
         default output target of the XSLT transform.
    -->
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>
    <xsl:param name="firstTopicUri" as="xs:string?" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:variable name="initialTopicUri"
      as="xs:string"
      select="
      if ($firstTopicUri != '')
       then $firstTopicUri
       else htmlutil:getInitialTopicrefUri($uniqueTopicRefs, $topicsOutputPath, $outdir, $rootMapDocUrl)
       "
    />
    <xsl:message> + [INFO] Generating root index HTML document <xsl:sequence select="$indexUri"/>...</xsl:message>
   <xsl:result-document format="{$xsloutput}" href="{$indexUri}">
      <xsl:apply-templates mode="generate-html5-page" select=".">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
        <xsl:with-param name="resultUri" as="xs:string" select="$indexUri" tunnel="yes"/>
        <xsl:with-param name="is-root" as="xs:boolean" select="true()"  tunnel="yes"/>
        <xsl:with-param name="firstTopicUri" as="xs:string?" tunnel="yes" select="$initialTopicUri" />
      </xsl:apply-templates>
    </xsl:result-document>
  </xsl:template>

</xsl:stylesheet>
