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
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:json="http://json.org/"
  exclude-result-prefixes="#all"
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
  <xsl:template match="*" mode="generate-css-js">
    <xsl:param name="location" as="xs:string?" select="'head'"/>

    <xsl:if test="$location = 'head'">
      <xsl:call-template name="d4p-variables"/>
    </xsl:if>

    <xsl:apply-templates select="." mode="generate-d4p-css-js">
          <xsl:with-param name="location" as="xs:string" select="$location" tunnel="yes" />
    </xsl:apply-templates>

  </xsl:template>

  <!-- this template is used to change the output when debug mode = 0 -->
  <xsl:template match="*" mode="generate-d4p-css-js">
    <xsl:param name="location" as="xs:string?" />
    <xsl:choose>
      <xsl:when test="$debugBoolean">
        <xsl:apply-templates select="$HTML5THEMECONFIGDOC/html5/tag" mode="generate-d4p-uncompressed-css-js"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="$HTML5THEMECONFIGDOC/html5/tag" mode="generate-d4p-compressed-css-js"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- tag with @output = no should not be rendered -->
  <xsl:template match="tag[output = 'no']" mode="generate-d4p-uncompressed-css-js" priority="100" />
  <xsl:template match="tag[output = 'no']" mode="generate-d4p-compressed-css-js" priority="100" />

  <!-- This template render ons script element per script element declared in the theme config.xml -->
  <xsl:template match="tag[count(source/file) &gt; 0 ][output != 'no']" mode="generate-d4p-uncompressed-css-js">
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>
    <xsl:param name="location" as="xs:string" tunnel="yes"/>

    <xsl:variable name="tagLocation" select="if (boolean(@location)) then string(@location) else 'head'"/>

    <xsl:if test="$location = $tagLocation">

      <xsl:variable name="attributes">
        <xsl:for-each select="attributes/*">
          <xsl:if test="name(.) != 'href'">
            <attribute name="{name(.)}" value="{.}"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="name">
        <xsl:call-template name="theme-get-tag-name">
          <xsl:with-param name="name" select="name" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:for-each select="./source/file">

        <xsl:variable name="extension" select="relpath:getExtension(@path)"/>

        <xsl:if test="prefix and prefix != ''">
          <xsl:value-of select="prefix" disable-output-escaping="yes"/>
        </xsl:if>

        <xsl:element name="{$name}">

          <xsl:for-each select="$attributes/*">
            <xsl:attribute name="{@name}" select="@value"/>
          </xsl:for-each>

          <xsl:if test="$extension = 'css'">
            <xsl:attribute name="href" select="relpath:assets-uri($relativePath, @path)" />
          </xsl:if>

          <xsl:if test="$extension = 'js'">
            <xsl:attribute name="src" select="relpath:assets-uri($relativePath, @path)" />
          </xsl:if>

        </xsl:element>

        <xsl:if test="suffix and suffix != ''">
          <xsl:value-of select="suffix" disable-output-escaping="yes"/>
        </xsl:if>

        <xsl:value-of select="'&#x0a;'"/>
      </xsl:for-each>

    </xsl:if>
  </xsl:template>

  <!-- This template render ons script element per script element declared in the theme config.xml -->
  <xsl:template match="tag[count(source/file) = 0 ][output != 'no']" mode="generate-d4p-uncompressed-css-js">
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>
    <xsl:param name="location" as="xs:string" tunnel="yes"/>

    <xsl:variable name="tagLocation" select="if (boolean(@location)) then  string(@location) else 'head'"/>

    <xsl:if test="$location = $tagLocation">

      <xsl:variable name="attributes">
        <xsl:for-each select="attributes/*">
          <attribute name="{name(.)}" value="{.}"/>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="extension">
        <xsl:choose>

          <xsl:when test="attributes/href">
            <xsl:value-of select="relpath:getExtension(@path)"/>
          </xsl:when>

          <xsl:when test="attributes/src">
             <xsl:value-of select="relpath:getExtension(@path)"/>
          </xsl:when>

          <xsl:otherwise>
             <xsl:value-of select="relpath:getExtension(@path)"/>
          </xsl:otherwise>

        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="name">
        <xsl:call-template name="theme-get-tag-name">
            <xsl:with-param name="name" select="name" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:if test="prefix and prefix != ''">
        <xsl:value-of select="prefix" disable-output-escaping="yes"/>
      </xsl:if>

      <xsl:element name="{$name}">
        <xsl:for-each select="$attributes/*">
          <xsl:attribute name="{@name}" select="@value"/>
        </xsl:for-each>

        <xsl:value-of select="value"  disable-output-escaping="yes" />
      </xsl:element>

      <xsl:if test="suffix and suffix != ''">
        <xsl:value-of select="suffix"/>
      </xsl:if>

      <xsl:value-of select="'&#x0a;'"/>
    </xsl:if>
  </xsl:template>

  <!-- When a tag specify an external file, the rendering code is the samne than in the uncompressed generate-d4p-uncompressed-css-js mode -->
  <xsl:template match="tag[count(source/file) = 0 ][output != 'no']" mode="generate-d4p-compressed-css-js">
    <xsl:apply-templates select="." mode="generate-d4p-uncompressed-css-js" />
  </xsl:template>

  <!-- Compressed mode use the information from filename -->
  <xsl:template match="tag[count(source/file) &gt; 0 ][output != 'no']" mode="generate-d4p-compressed-css-js">
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>
    <xsl:param name="location" as="xs:string" tunnel="yes"/>

    <xsl:variable name="tagLocation" select="if (boolean(@location)) then  string(@location) else 'head'"/>

    <xsl:if test="$location = $tagLocation">

      <xsl:variable name="filename" as="xs:string" select="filename" />
      <xsl:variable name="extension" select="relpath:getExtension($filename)"/>

      <xsl:variable name="name">
        <xsl:call-template name="theme-get-tag-name">
          <xsl:with-param name="name" select="name" />
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="dir">
        <xsl:choose>
          <xsl:when test="$extension = 'css'">css</xsl:when>
          <xsl:when test="$extension = 'js'">js</xsl:when>
          <xsl:otherwise>unknown</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="content" select="value" />

      <xsl:variable name="path" select="concat($html5absolulteuri, $HTML5THEMEDIR, '/', $siteTheme, '/', $extension, '/', $filename)"/>

      <xsl:if test="prefix and prefix != ''">
        <xsl:value-of select="prefix" disable-output-escaping="yes"/>
      </xsl:if>

      <xsl:element name="{$name}">

        <xsl:for-each select="attributes/*">
          <xsl:attribute name="{name(.)}" select="."/>
        </xsl:for-each>

        <xsl:if test="not(attributes/href) and $extension = 'css'">
          <xsl:attribute name="href" select="if($html5absolulteuri = '') then relpath:fixRelativePath($relativePath, $path) else $path" />
        </xsl:if>

        <xsl:if test="not(attributes/src) and $extension = 'js'">
          <xsl:attribute name="src" select="if($html5absolulteuri = '') then relpath:fixRelativePath($relativePath, $path) else $path" />
        </xsl:if>

        <xsl:value-of select="translate(string($content), '&#10;', '')" />

      </xsl:element>
      <xsl:if test="suffix and suffix != ''">
        <xsl:value-of select="suffix" disable-output-escaping="yes"/>
      </xsl:if>
      <xsl:value-of select="'&#x0a;'"/>

   </xsl:if>
  </xsl:template>

  <!-- Swicth tage name -->
  <xsl:template name="theme-get-tag-name">
    <xsl:param name="name" />
    <xsl:choose>
      <xsl:when test="$name = 'link'">link</xsl:when>
      <xsl:when test="$name = 'script'">script</xsl:when>
      <xsl:when test="$name = 'style'">style</xsl:when>
      <xsl:otherwise>meta</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- output D4p javascript object -->
  <xsl:template name="d4p-variables">
    <xsl:param name="relativePath" tunnel="yes" as="xs:string*" select="''"/>
    <xsl:param name="isChunkedMap" as="xs:boolean" select="false()" tunnel="yes"/>
    <xsl:param name="is-root" as="xs:boolean"  tunnel="yes" select="false()" />
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <xsl:param name="documentation-title" as="xs:string" select="''" tunnel="yes" />

    <xsl:variable name="nextTopicHref" as="xs:string?">
       <xsl:call-template name="getNextTopicHref"/>
    </xsl:variable>
    <xsl:variable name="previousTopicHref" as="xs:string?">
       <xsl:call-template name="getPrevTopicHref"/>
    </xsl:variable>
    <xsl:variable name="strippedNextTopicHref" select="replace($nextTopicHref, $OUTEXT, $jsOutExt)"/>
    <xsl:variable name="strippedPreviousTopicHref" select="replace($previousTopicHref, $OUTEXT, $jsOutExt)"/>

    <xsl:variable name="d4p-js-object">
      <d4p>
         <relativePath><xsl:value-of select="$relativePath" /></relativePath>
         <dev><xsl:value-of select="if($debugBoolean) then 'true' else 'false'"/></dev>
         <debug><xsl:value-of select="if($debugBoolean) then 'true' else 'false'"/></debug>
         <draft><xsl:value-of select="if(ISDRAFT) then 'true' else 'false'"/></draft>
         <nextTopicHref><xsl:sequence select="$strippedNextTopicHref"/></nextTopicHref>
         <previousTopicHref><xsl:sequence select="$strippedPreviousTopicHref"/></previousTopicHref>
         <ext><xsl:value-of select="$jsOutExt"/></ext>
         <root><xsl:value-of select="$is-root"/></root>
         <topic>
           <chunked><xsl:sequence select="string($topicref/ancestor-or-self::*[1]/@chunk)"/></chunked>
         </topic>
         <map>
           <title><xsl:value-of select="$documentation-title"/></title>
           <xsl:if test="$version != ''">
             <version><xsl:value-of select="$version"/></version>
           </xsl:if>
           <chunked><xsl:value-of select="$isChunkedMap"/></chunked>
         </map>
         <search>
           <minlength><xsl:value-of select="$searchEngineMinLength" /></minlength>
         </search>
         <xsl:if test="$HTML5THEMECONFIGDOC/html5/d4p/l">
          <l>
            <xsl:for-each select="$HTML5THEMECONFIGDOC/html5/d4p/l/var">
              <xsl:element name="{@name}">
                <xsl:sequence select="dita-ot:get-variable(., @string)"/>
              </xsl:element>
             </xsl:for-each>
           </l>
          </xsl:if>
         <!-- extension point -->
         <xsl:apply-templates select="." mode="d4p-js-properties" />
      </d4p>
    </xsl:variable>

    <script type="text/javascript">
      <xsl:text>var d4p = </xsl:text><xsl:value-of select="json:generate($d4p-js-object/d4p)"/>
    </script><xsl:value-of select="'&#x0a;'"/>

  </xsl:template>

  <!-- template to add javascript properties to the D4P object -->
  <xsl:template match="*" mode="d4p-js-properties"/>

  <!-- functions -->
  <xsl:function name="relpath:assets-uri" as="xs:string">
    <xsl:param name="relativePath" as="xs:string*"/>
    <xsl:param name="path" as="xs:string*"/>


    <xsl:variable name="pathwithdir">
      <xsl:choose>
        <xsl:when test="$html5absolulteuri != ''">
          <xsl:value-of select="concat($html5absolulteuri, $HTML5THEMEDIR, '/', $path)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="relpath:fixRelativePath($relativePath, concat($HTML5THEMEDIR, '/', $path))" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$pathwithdir"/>
  </xsl:function>

</xsl:stylesheet>
