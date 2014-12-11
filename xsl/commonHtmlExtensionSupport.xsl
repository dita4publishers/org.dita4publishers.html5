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
  xmlns:random="org.dita.dost.util.RandomUtils"
  xmlns:java="org.dita.dost.util.ImgUtils"
  xmlns:json="http://json.org/"
  exclude-result-prefixes="random xs xd df relpath mapdriven index-terms java xsl mapdriven json"
  version="1.0">

  <!-- Process standard attributes that may appear anywhere. Previously this was "setclass" -->
  <xsl:template name="commonattributes">
    <xsl:param name="default-output-class"/>
    <xsl:apply-templates select="@xml:lang"/>
    <xsl:apply-templates select="@dir"/>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"/>

    <xsl:apply-templates select="." mode="set-output-class">
      <xsl:with-param name="default" select="$default-output-class"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="set-data-attr" />

  <xsl:template match="*[contains(@class, ' topic/data-about ')]" mode="set-data-attr">
    <xsl:variable name="json">
      <xsl:apply-templates select="*" mode="json-serialize"/>
    </xsl:variable>
    <xsl:attribute name="data-options"><xsl:value-of  select="json:generate($json)" /></xsl:attribute>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/desc ')]" mode="set-data-attr">

    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/data ')]" mode="json-serialize">
    <xsl:if test="@name">
      <xsl:variable name="value">
        <xsl:choose>
          <xsl:when test="@value">
            <xsl:value-of select="@value"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:element name="{@name}">
        <xsl:choose>
           <xsl:when test="*[contains(@class, ' topic/data ')]">
             <xsl:apply-templates select="*" mode="json-serialize"/>
           </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$value" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="process.note.common-processing">
    <xsl:param name="type" select="@type"/>

    <xsl:param name="title">
      <xsl:call-template name="getString">
        <!-- For the parameter, turn "note" into "Note", caution => Caution, etc -->
        <xsl:with-param name="stringName"
             select="concat(translate(substring($type, 1, 1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
                            substring($type, 2))"/>
      </xsl:call-template>
    </xsl:param>

    <xsl:variable name="flagrules">
      <xsl:call-template name="getrules"/>
    </xsl:variable>
    <!-- note, attention, caution, fastpath, important, notice, remember, restriction, tip, warning, other -->
    <xsl:variable name="html5NoteElement">
      <xsl:choose>
        <xsl:when test="@importance='low' or @importance='obsolete'">
          <xsl:value-of select="'details'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'aside'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:element name="{$html5NoteElement}">

      <xsl:attribute name="class" select="concat('note', ' ', $type, ' ', @importance)"/>

      <xsl:call-template name="gen-style">
        <xsl:with-param name="flagrules" select="$flagrules"/>
      </xsl:call-template>

      <xsl:call-template name="setidaname"/>

      <xsl:call-template name="start-flagit">
        <xsl:with-param name="flagrules" select="$flagrules"/>
      </xsl:call-template>

      <span class="title">
        <xsl:value-of select="$title"/>
        <xsl:call-template name="getString">
          <xsl:with-param name="stringName" select="'ColonSymbol'"/>
        </xsl:call-template>
      </span>

      <xsl:text> </xsl:text>

      <xsl:call-template name="revblock">
        <xsl:with-param name="flagrules" select="$flagrules"/>
      </xsl:call-template>

      <xsl:call-template name="end-flagit">
        <xsl:with-param name="flagrules" select="$flagrules"/>
      </xsl:call-template>

    </xsl:element>
  </xsl:template>


  <xsl:template match="*[contains(@class,' topic/image ')]" name="topic.image">
  <xsl:variable name="flagrules">
    <xsl:call-template name="getrules"/>
  </xsl:variable>
  <!-- build any pre break indicated by style -->
  <xsl:choose>
    <xsl:when test="parent::fig[contains(@frame,'top ')]">
      <!-- NOP if there is already a break implied by a parent property -->
    </xsl:when>
    <xsl:otherwise>
     <xsl:choose>
      <xsl:when test="(@placement='break')"><br/>
        <xsl:call-template name="start-flagit"><xsl:with-param name="flagrules" select="$flagrules"/></xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
       <xsl:call-template name="flagcheck"/>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:call-template name="start-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="setaname"/>
  <xsl:choose>


   <xsl:when test="@placement='break'"><!--Align only works for break-->
      <div class="block wide">
       <xsl:call-template name="topic-image"/>
      </div>
   </xsl:when>

   <xsl:otherwise>
    <xsl:call-template name="topic-image"/>
   </xsl:otherwise>
  </xsl:choose>

  <xsl:call-template name="end-revflag">
    <xsl:with-param name="flagrules" select="$flagrules"/>
  </xsl:call-template>
  <xsl:call-template name="end-flagit">
    <xsl:with-param name="flagrules" select="$flagrules"></xsl:with-param>
  </xsl:call-template>
  <!-- build any post break indicated by style -->
  <xsl:if test="not(@placement='inline')"><br/></xsl:if>
  <!-- image name for review -->
  <xsl:if test="$ARTLBL='yes'"> [<xsl:value-of select="@href"/>] </xsl:if>
</xsl:template>

<!-- @see https://bugzilla.mozilla.org/show_bug.cgi?id=276431-->
<xsl:template name="topic-image">

  <xsl:variable name="ends-with-svg">
    <xsl:call-template name="ends-with">
      <xsl:with-param name="text" select="@href"/>
      <xsl:with-param name="with" select="'.svg'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="ends-with-svgz">
    <xsl:call-template name="ends-with">
      <xsl:with-param name="text" select="@href"/>
      <xsl:with-param name="with" select="'.svgz'"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="scale-to-fit">
  <xsl:choose>
    <xsl:when test="@scalefit='yes'">
      <xsl:value-of select="'d4p-ui-scale2fit'" />
    </xsl:when>
  </xsl:choose>
  </xsl:variable>

  <xsl:variable name="isSVG" select="$ends-with-svg = 'true' or $ends-with-svgz = 'true'"/>

<xsl:choose>
 <xsl:when test="$isSVG">
        <!-- @see article
            http://e.metaclarity.org/52/cross-browser-svg-issues/
        -->
        <object type="image/svg+xml" data="{@href}">
      <xsl:call-template name="commonattributes">
            <xsl:with-param name="default-output-class">
              <xsl:if test="@placement='break'">
                <!--Align only works for break-->
                <xsl:choose>
                  <xsl:when test="@align='left'">imageleft</xsl:when>
                  <xsl:when test="@align='right'">imageright</xsl:when>
                  <xsl:when test="@align='center'">imagecenter</xsl:when>
                </xsl:choose>
              </xsl:if>
            </xsl:with-param>
          </xsl:call-template>
           <xsl:apply-templates select="@height|@width"/>
    </object>
      </xsl:when>
<xsl:otherwise>
  <img>
    <xsl:attribute name="class">
    <xsl:value-of select="concat(@placement, ' ', @align, ' ', $scale-to-fit)" />
    </xsl:attribute>

    <xsl:call-template name="setid"/>

    <xsl:apply-templates select="@href|@height|@width"/>
    <!-- Add by Alan for Bug:#2900417 on Date: 2009-11-23 begin -->
    <xsl:apply-templates select="@scale"/>
    <!-- Add by Alan for Bug:#2900417 on Date: 2009-11-23 end   -->
    <xsl:choose>
      <xsl:when test="*[contains(@class,' topic/alt ')]">
        <xsl:variable name="alt-content"><xsl:apply-templates select="*[contains(@class,' topic/alt ')]" mode="text-only"/></xsl:variable>
        <xsl:attribute name="alt"><xsl:value-of select="normalize-space($alt-content)"/></xsl:attribute>
      </xsl:when>
      <xsl:when test="@alt">
        <xsl:attribute name="alt"><xsl:value-of select="@alt"/></xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </img>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<!-- This is an override of the same template from dita2htmlmpl.xsl. It
       uses xtrf rather than $OUTPUTDIR to provide the location of the
       graphic as authored, not as output.
    -->
  <xsl:template match="*[contains(@class,' topic/image ')]/@scale" priority="10">

    <xsl:variable name="xtrf" as="xs:string" select="../@xtrf"/>
    <xsl:variable name="baseUri" as="xs:string"
      select="relpath:getParent($xtrf)"/>

    <xsl:variable name="width">
      <xsl:choose>
        <xsl:when test="not(contains(../@href,'://'))">
          <xsl:value-of select="java:getWidth($baseUri, string(../@origHref))"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="height">
      <xsl:choose>
        <xsl:when test="not(contains(../@href,'://'))">
          <xsl:value-of select="java:getHeight($baseUri, string(../@origHref))"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="not(../@width) and not(../@height)">
      <xsl:attribute name="height">
        <xsl:value-of select="format-number(floor(number($height) * number(.) div 100),'#.##')"/>
      </xsl:attribute>
      <xsl:attribute name="width">
        <xsl:value-of select="format-number(floor(number($width) * number(.) div 100),'#.##')"/>
      </xsl:attribute>
    </xsl:if>
     <xsl:attribute name="class" select="../@align" />
  </xsl:template>


  <!-- Function to look up a target in the keyref file -->
  <xsl:template match="*" mode="find-keyref-target">
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>
    <xsl:param name="keys" select="@keyref"/>
    <xsl:param name="target">
      <xsl:value-of select="$keydefs//*[@keys = $keys]/@href"/>
    </xsl:param>

    <xsl:choose>
      <xsl:when test="contains($target, '://')">
        <xsl:value-of select="$target"/>
      </xsl:when>
      <!-- edited  on 2010-12-17 for keyref bug:3114411 start-->
      <xsl:when test="contains($target, '#')">
        <xsl:value-of select="concat($relativePath, substring-before(substring-before($target, '#'), '.'), $OUTEXT, '#', substring-after($target, '#'))"/>
      </xsl:when>
      <xsl:when test="$target = ''">
        <xsl:value-of select="$OUTEXT"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat($relativePath, substring-before($target, '.'), $OUTEXT)"/>
      </xsl:otherwise>
      <!-- edited  on 2010-12-17 for keyref bug:3114411 end-->
    </xsl:choose>
  </xsl:template>

 <xsl:template name="dotable">

  <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>

  <xsl:variable name="id">
    <xsl:choose>
      <xsl:when test="@id">
        <xsl:value-of select= "@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('ID', random:getRandomNum())" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:call-template name="setaname"/>

  <table id="{$id}">

    <xsl:variable name="colsep">
      <xsl:choose>
        <xsl:when test="*[contains(@class, ' topic/tgroup ')]/@colsep"><xsl:value-of select="*[contains(@class, ' topic/tgroup ')]/@colsep"/></xsl:when>
        <xsl:when test="@colsep"><xsl:value-of select="@colsep"/></xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="rowsep">
      <xsl:choose>
        <xsl:when test="*[contains(@class, ' topic/tgroup ')]/@rowsep"><xsl:value-of select="*[contains(@class, ' topic/tgroup ')]/@rowsep"/></xsl:when>
        <xsl:when test="@rowsep"><xsl:value-of select="@rowsep"/></xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="commonattributes"/>

    <xsl:apply-templates select="*" mode="set-data-attr"/>

    <xsl:apply-templates select="." mode="generate-table-summary-attribute"/>
    <xsl:call-template name="setscale"/>
    <!-- When a table's width is set to page or column, force it's width to 100%. If it's in a list, use 90%.
         Otherwise, the table flows to the content -->
    <xsl:choose>
      <xsl:when test="(@expanse = 'page' or @pgwide = '1')and (ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')] )">
        <xsl:attribute name="width">90%</xsl:attribute>
      </xsl:when>
      <xsl:when test="(@expanse = 'column' or @pgwide = '0') and (ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')] )">
        <xsl:attribute name="width">90%</xsl:attribute>
      </xsl:when>
      <xsl:when test="(@expanse = 'page' or @pgwide = '1')">
        <xsl:attribute name="width">100%</xsl:attribute>
      </xsl:when>
      <xsl:when test="(@expanse = 'column' or @pgwide = '0')">
        <xsl:attribute name="width">100%</xsl:attribute>
      </xsl:when>
    </xsl:choose>
    <!--xsl:choose>
      <xsl:when test="@frame = 'all' and $colsep = '0' and $rowsep = '0'">
        <xsl:attribute name="border">0</xsl:attribute>
      </xsl:when>
      <xsl:when test="not(@frame) and $colsep = '0' and $rowsep = '0'">
        <xsl:attribute name="border">0</xsl:attribute>
      </xsl:when>
      <xsl:when test="@frame = 'sides'">
        <xsl:attribute name="frame">vsides</xsl:attribute>
        <xsl:attribute name="border">1</xsl:attribute>
      </xsl:when>
      <xsl:when test="@frame = 'top'">
        <xsl:attribute name="frame">above</xsl:attribute>
        <xsl:attribute name="border">1</xsl:attribute>
      </xsl:when>
      <xsl:when test="@frame = 'bottom'">
        <xsl:attribute name="frame">below</xsl:attribute>
        <xsl:attribute name="border">1</xsl:attribute>
      </xsl:when>
      <xsl:when test="@frame = 'topbot'">
        <xsl:attribute name="frame">hsides</xsl:attribute>
        <xsl:attribute name="border">1</xsl:attribute>
      </xsl:when>
      <xsl:when test="@frame = 'none'">
        <xsl:attribute name="frame">void</xsl:attribute>
        <xsl:attribute name="border">1</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="frame">border</xsl:attribute>
        <xsl:attribute name="border">1</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose-->
    <!--xsl:choose>
      <xsl:when test="@frame = 'all' and $colsep = '0' and $rowsep = '0'">
        <xsl:attribute name="border">0</xsl:attribute>
      </xsl:when>
      <xsl:when test="not(@frame) and $colsep = '0' and $rowsep = '0'">
        <xsl:attribute name="border">0</xsl:attribute>
      </xsl:when>
      <xsl:when test="$colsep = '0' and $rowsep = '0'">
        <xsl:attribute name="rules">none</xsl:attribute>
        <xsl:attribute name="border">0</xsl:attribute>
      </xsl:when>
      <xsl:when test="$colsep = '0'">
        <xsl:attribute name="rules">rows</xsl:attribute>
      </xsl:when>
      <xsl:when test="$rowsep = '0'">
        <xsl:attribute name="rules">cols</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="rules">all</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose-->
    <xsl:call-template name="place-tbl-lbl"/>
    <!-- title and desc are processed elsewhere -->
    <xsl:apply-templates select="*[contains(@class, ' topic/tgroup ')]"/>
    </table><xsl:value-of select="$newline"/>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
</xsl:template>



 <!--create the next and previous links, with accompanying parent link if any; create group for each unique parent, as well as for any next and previous links that aren't in the same group as a parent-->
  <xsl:template name="next-prev-parent-links">
    <xsl:for-each select="descendant::*
     [contains(@class, ' topic/link ')]
     [(@role='parent' and
          generate-id(.)=generate-id(key('link',concat(ancestor::*[contains(@class, ' topic/related-links ')]/parent::*[contains(@class, ' topic/topic ')]/@id, ' ', @href,@type,@role,@platform,@audience,@importance,@outputclass,@keyref,@scope,@format,@otherrole,@product,@otherprops,@rev,@class,child::*))[1])
     ) or (@role='next' and
          generate-id(.)=generate-id(key('link',concat(ancestor::*[contains(@class, ' topic/related-links ')]/parent::*[contains(@class, ' topic/topic ')]/@id, ' ', @href,@type,@role,@platform,@audience,@importance,@outputclass,@keyref,@scope,@format,@otherrole,@product,@otherprops,@rev,@class,child::*))[1])
     ) or (@role='previous' and
          generate-id(.)=generate-id(key('link',concat(ancestor::*[contains(@class, ' topic/related-links ')]/parent::*[contains(@class, ' topic/topic ')]/@id, ' ', @href,@type,@role,@platform,@audience,@importance,@outputclass,@keyref,@scope,@format,@otherrole,@product,@otherprops,@rev,@class,child::*))[1])
     )]/parent::*">
      <xsl:value-of select="$newline"/>

      <div class="familylinks"><xsl:value-of select="$newline"/>

      <xsl:if test="$NOPARENTLINK='no' and contains($include.roles, ' parent ')">
        <xsl:choose>
          <xsl:when test="*[@href][@role='parent']">
            <xsl:for-each select="*[@href][@role='parent']">
              <xsl:call-template name="compas">
                <xsl:with-param name="direction" select="'parent'" />
              </xsl:call-template>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="*[@href][@role='ancestor'][last()]">
              <xsl:call-template name="compas">
                <xsl:with-param name="direction" select="'parent'" />
              </xsl:call-template>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="contains($include.roles, ' previous ')">
        <xsl:for-each select="*[@href][@role='previous']">
          <xsl:call-template name="compas">
            <xsl:with-param name="direction" select="'previous'" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>

        <xsl:if test="contains($include.roles, ' next ')">
          <xsl:for-each select="*[@href][@role='next']">
            <xsl:call-template name="compas">
              <xsl:with-param name="direction" select="'next'" />
            </xsl:call-template>
          </xsl:for-each>
        </xsl:if>
      </div>
      <xsl:value-of select="$newline"/>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
