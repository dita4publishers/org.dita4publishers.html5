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
  xmlns:de="http://dnovatchev.wordpress.com"
  exclude-result-prefixes="df xs de relpath htmlutil xd"
  version="2.0"
 >

  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/relpath_util.xsl"/>

  <xsl:param name="html5dir" select="''" />
  <xsl:param name="html5sitetheme" select="''" />
  <xsl:param name="script" select="''" />
  <xsl:param name="outputdir" select="''" />
  <xsl:param name="themedir" select="''" />
  <xsl:param name="buildnumber" select="''" />

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/">
      <xsl:apply-templates select="*" mode="tag-preprocess" />
  </xsl:template>

  <xsl:template match="html5" mode="tag-preprocess">
    <project name="package" basedir="." default="packager.package">
       <xsl:comment>
          This file has been created by the Dita4Publishers Project.
          The html5 plugin is required in order to run this script.
       </xsl:comment>

       <xsl:variable name="dirList">
        <xsl:apply-templates select="*" mode="package-get-assets" />
       </xsl:variable>

       <import file="{concat($html5dir, '/', $script)}" />

        <target name="packager.package">
          <package-prepare theme="{$html5sitetheme}" />

          <xsl:apply-templates select="*" mode="package" />

          <package-get-assets>
            <xsl:attribute name="theme" select="$html5sitetheme" />
            <xsl:attribute name="dirlist" select="$dirList" />
          </package-get-assets>
          <package-get theme="{$html5sitetheme}" dir="{concat('${basedir}', '/../')}" />
        </target>
    </project>
  </xsl:template>

  <xsl:template match="tag[count(source/file) &gt; 0]" mode="package-get-assets">
    <xsl:for-each select="source/file">
    <xsl:value-of select="de:dirname(de:dirname(@path))" /><xsl:text>,</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tag[count(source/file) &gt; 0]" mode="package">
    <xsl:variable name="filename" select="filename"/>
    <xsl:variable name="extension" select="relpath:getExtension($filename)"/>

    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="$extension = 'js'">
          <xsl:value-of select="'js'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'css'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="filelist">
      <xsl:for-each select="source/file">
        <xsl:variable name="fileExtension" select="relpath:getExtension(@path)" />

        <xsl:choose>
            <xsl:when test="$extension = $fileExtension">
              <xsl:choose>
                <xsl:when test="position() = last()" >
                    <xsl:value-of select="@path"/>
                </xsl:when>
                 <xsl:otherwise>
                  <xsl:value-of select="concat(./@path, ',')"/>
                </xsl:otherwise>
              </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message> + [WARNING]: <xsl:value-of select="@path" /> has not a valid extension</xsl:message>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:for-each>
    </xsl:variable>


    <package type="{$type}" theme="{$html5sitetheme}" filelist="{$filelist}" to="{substring-before($filename, concat('.', $extension))}" version="{$buildnumber}" />

  </xsl:template>


  <xsl:template match="*"/>
  <xsl:template match="*"  mode="package"/>
  <xsl:template match="*"  mode="package-get-assets"/>

 <xsl:function name="de:basename" as="xs:string">
    <xsl:param name="pfile" as="xs:string"/>
    <xsl:sequence select=
     "de:reverseStr(substring-before(de:reverseStr($pfile), '/'))
     " />
  </xsl:function>

  <xsl:function name="de:dirname" as="xs:string">
    <xsl:param name="pfile" as="xs:string"/>
    <xsl:sequence select=
     "de:reverseStr(substring-after(de:reverseStr($pfile), '/'))
     " />
  </xsl:function>

   <xsl:function name="de:reverseStr" as="xs:string">
    <xsl:param name="pStr" as="xs:string"/>

    <xsl:sequence select=
    "codepoints-to-string(reverse(string-to-codepoints($pStr)))"/>
  </xsl:function>

</xsl:stylesheet>
