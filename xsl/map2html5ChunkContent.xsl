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
  exclude-result-prefixes="df xs relpath htmlutil xd"
  version="2.0"
>

  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-chunked-map-content">
    <xsl:param name="uniqueTopicRefs" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="indexUri" as="xs:string" tunnel="yes"/>
    <xsl:param name="documentation-title" as="xs:string" tunnel="yes"/>

    <xsl:variable name="topics">
      <xsl:document>
        <xsl:apply-templates select="*" mode="generate-chunked-map-content">
           <xsl:with-param name="resultUri" as="xs:string" select="$indexUri" tunnel="yes"/>
           <xsl:with-param name="topicResultUri" select="$indexUri" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:document>
    </xsl:variable>

    <xsl:variable name="content">
      <xsl:apply-templates select="$topics/*" mode="render"/>
    </xsl:variable>

    <xsl:result-document format="html5" href="{$indexUri}">
      <xsl:apply-templates mode="generate-html5-page" select=".">
        <xsl:with-param name="resultUri" as="xs:string" select="$indexUri" tunnel="yes"/>
        <xsl:with-param name="is-root" as="xs:boolean" select="true()"/>
        <xsl:with-param name="content" select="$content" tunnel="yes"/>
        <xsl:with-param name="topic-title" select="$documentation-title" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:result-document>

    <xsl:message> + [INFO] Content generated.</xsl:message>
  </xsl:template>

  <xsl:template match="*" mode="render">
    <xsl:apply-templates select="." />
  </xsl:template>

   <xsl:template match="*[df:class(., 'topic/topic')][not(ancestor::*[df:class(., 'topic/topic')])]" mode="render">
      <article>
        <xsl:call-template name="set_an_anchor" />
        <xsl:apply-templates select="*" />
      </article>
   </xsl:template>

   <xsl:template match="*[df:isTopicRef(.)]" mode="generate-chunked-map-content">
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="collected-data" as="element()" tunnel="yes"/>
    <xsl:param name="resultUri" as="xs:string" tunnel="yes"/>

    <xsl:variable name="topic" select="df:resolveTopicRef(.)" as="element()*"/>

    <xsl:choose>
      <xsl:when test="not($topic)">
        <xsl:message> + [WARNING] generate-content: Failed to resolve topic reference to href "<xsl:sequence
            select="string(@href)"/>"</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{name($topic)}">
           <xsl:sequence select="$topic/@*, $topic/node()" />
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>
