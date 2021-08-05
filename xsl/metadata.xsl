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
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:mapdriven="http://dita4publishers.org/mapdriven"
  exclude-result-prefixes="#all"
  xmlns:java="org.dita.dost.util.ImgUtils"
  version="3.0">


  <xsl:template match="*" mode="getTopicMeta">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

   <xsl:template match="text()" mode="getTopicMeta"/>

  <xsl:template match="*[contains(@class, 'topic/data')]" mode="getTopicMeta">
    <xsl:if test="@name and @value">
      <meta name="{@name}" content="{@value}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class,' topic/pre ')][contains(@class,' pr-d/codeblock ')]">
    <xsl:if test="contains(@frame,'top')"><hr /></xsl:if>
    <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
    <xsl:call-template name="spec-title-nospace"/>
    <pre>
      <xsl:attribute name="class"><xsl:value-of select="name()"/></xsl:attribute>
      <xsl:call-template name="commonattributes"/>
      <xsl:if test="*[contains(@class,' topic/data-about ')]">
         <xsl:apply-templates select="*[contains(@class,' topic/data-about ')]" mode="html5-data-attributes" />
      </xsl:if>
      <xsl:call-template name="setscale"/>
      <xsl:call-template name="setidaname"/>
      <xsl:apply-templates/>
    </pre>
    <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    <xsl:if test="contains(@frame,'bot')"><hr /></xsl:if>
    <xsl:value-of select="'&#x0a;'"/>
  </xsl:template>

  <xsl:template match="*[contains(@class,' topic/data-about ')]" mode="html5-data-attributes">
      <xsl:for-each select="data">
        <xsl:choose>
          <xsl:when test="@href">
            <xsl:attribute name="data-{@name}"><xsl:value-of select="@href" /></xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="data-{@name}"><xsl:value-of select="@value" /></xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
  </xsl:template>

  <xsl:template match="*[contains(@class,' topic/data-about ')]" />
</xsl:stylesheet>
