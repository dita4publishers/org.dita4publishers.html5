<!--
<?xml version="1.0" encoding="utf-8"?>
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
  xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
  xmlns:local="urn:functions:local"
  exclude-result-prefixes="#all"
  version="2.0">

  <!-- Omit prereq links from unordered related-links (handled by mode="prereqs" template). -->
  <xsl:key name="omit-from-unordered-links" 
           match="*[@importance='required' and 
                    (not(@role) or @role= ('sibling', 'friend', 'cousin'))]"
                    use="1"/>

  <xsl:template match="*" mode="add-link-target-attribute">
    <xsl:if test="$html5ForceAccessibilityBoolean and 
                  ((@scope='external' or @type='external') or 
                   (matches(@format, 'pdf', 'i')) and 
                   not(@scope='local'))">
      <xsl:attribute name="target">_blank</xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getLowerCaseLang">
    <xsl:variable name="ancestorlangUpper">
      <!-- the current xml:lang value (en-us if none found) -->
      <xsl:choose>
        <!--xsl:when test="ancestor-or-self::*/@xml:lang">
          <xsl:value-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
        </xsl:when-->
        <xsl:when test="$TEMPLATELANG != ''">
          <xsl:value-of select="$TEMPLATELANG"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$DEFAULTLANG"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:sequence select="lower-case($ancestorlangUpper)"/>

  </xsl:template>

  <!-- Process standard attributes that may appear anywhere. Previously this was "setclass" -->
  <xsl:template name="commonattributes">

    <xsl:param name="default-output-class"/>
    <xsl:param name="parent-class" as="xs:string" select="''" tunnel="yes"/>

    <xsl:apply-templates select="@xml:lang"/>
    <xsl:apply-templates select="@dir"/>
    <xsl:apply-templates select="@keyref"/>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"/>

    <xsl:apply-templates select="." mode="set-output-class">
      <xsl:with-param name="default" select="$default-output-class"/>
      <xsl:with-param name="parent-class" select="$parent-class"/>
    </xsl:apply-templates>

  </xsl:template>


  <!-- Set the class attribute on the resulting output element. The default for a class of elements
     may be passed in with $default, but that default can be overridden with mode="get-output-class". -->
<xsl:template match="*" mode="set-output-class">
  <xsl:param name="default"/>
  <xsl:param name="parent-class" as="xs:string" select="''" tunnel="yes"/>

  <xsl:variable name="output-class">
    <xsl:apply-templates select="." mode="get-output-class"/>
  </xsl:variable>

  <xsl:variable name="draft-revs">
    <!-- If draft is on, add revisions to default class. Simplifies processing in DITA-OT 1.6 and earlier
         that created an extra div or span around revised content, just to hold @class with revs. -->
    <xsl:if test="$DRAFT = 'yes'">
      <xsl:for-each select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/revprop">
        <xsl:value-of select="@val"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="using-output-class">
    <xsl:choose>
      <xsl:when test="string-length(normalize-space($output-class)) > 0"><xsl:value-of select="$output-class"/></xsl:when>
      <xsl:when test="string-length(normalize-space($default)) > 0"><xsl:value-of select="$default"/></xsl:when>
      <xsl:when test="string-length(normalize-space($parent-class)) > 0"><xsl:value-of select="$parent-class"/></xsl:when>
    </xsl:choose>
    <xsl:if test="$draft-revs != ''">
      <xsl:text> </xsl:text>
      <xsl:value-of select="normalize-space($draft-revs)"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="ancestry">
    <xsl:if test="$PRESERVE-DITA-CLASS = 'yes'">
      <xsl:apply-templates select="." mode="get-element-ancestry"/>
    </xsl:if>
  </xsl:variable>
  <xsl:variable name="outputclass-attribute">
    <xsl:apply-templates select="@outputclass" mode="get-value-for-class"/>
  </xsl:variable>
  <!-- Revised design with DITA-OT 1.5: include class ancestry if requested; 
       combine user output class with element default, giving priority to the user value. -->
  <xsl:if test="string-length(normalize-space(concat($outputclass-attribute, $using-output-class, $ancestry))) > 0">
    <xsl:attribute name="class">
      <xsl:value-of select="$ancestry"/>
      <xsl:if test="string-length(normalize-space($ancestry)) > 0 and 
                    string-length(normalize-space($using-output-class)) > 0"><xsl:text> </xsl:text></xsl:if>
      <xsl:value-of select="normalize-space($using-output-class)"/>
      <xsl:if test="string-length(normalize-space(concat($ancestry, $using-output-class))) > 0 and
                    string-length(normalize-space($outputclass-attribute)) > 0"><xsl:text> </xsl:text></xsl:if>
      <xsl:value-of select="$outputclass-attribute"/>
    </xsl:attribute>
  </xsl:if>
</xsl:template>
 
  <xsl:template match="@keyref">
    <xsl:if test="$outputKeyrefBoolean">
      <xsl:attribute name="data-keyref"><xsl:value-of select="."/></xsl:attribute>
    </xsl:if>
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


 <!-- DL entry -->
<xsl:template match="*[contains(@class, ' topic/dlentry ')]" name="topic.dlentry">
  <xsl:apply-templates>
     <xsl:with-param name="parent-class" as="xs:string" select="if(string-length(normalize-space(@rev)) &gt; 0) then concat('props_rev_dlentry_', translate(@rev, '.', '_')) else ''" tunnel="yes"/>
  </xsl:apply-templates>
</xsl:template>


  <xsl:template match="*" mode="process.note.common-processing">
    <xsl:param name="type" select="@type"/>
    <xsl:param name="title">
      <xsl:call-template name="getVariable">
        <xsl:with-param name="id" select="concat(upper-case(substring($type, 1, 1)), substring($type, 2))"/>
      </xsl:call-template>
    </xsl:param>
    
    <!-- note, attention, caution, fastpath, important, notice, remember, restriction, tip, warning, other -->
    <xsl:variable name="html5NoteElement" 
      select="if (@importance='low' or @importance='obsolete')
                 then 'details'
                 else 'aside'"
    />

    <xsl:element name="{$html5NoteElement}">

      <xsl:call-template name="commonattributes">
        <xsl:with-param name="default-output-class" select="string-join(($type, concat('note_', $type)), ' ')"/>
      </xsl:call-template>
      <xsl:call-template name="setidaname"/>
      <!-- Normal flags go before the generated title; revision flags only go on the content. -->
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/prop" mode="ditaval-outputflag"/>
      <span class="note__title">
        <xsl:copy-of select="$title"/>
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'ColonSymbol'"/>
        </xsl:call-template>
      </span>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/revprop" mode="ditaval-outputflag"/>
      <xsl:apply-templates/>
      <!-- Normal end flags and revision end flags both go out after the content. -->
      <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
      
    </xsl:element>
  </xsl:template>


  <xsl:template match="*[contains(@class,' topic/image ')]" name="topic.image">
 
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

  <!-- build any post break indicated by style -->
  <xsl:if test="not(@placement='inline')"><br/></xsl:if>
  <!-- image name for review -->
  <xsl:if test="$ARTLBL='yes'"> [<xsl:value-of select="@href"/>] </xsl:if>
</xsl:template>

<!-- @see https://bugzilla.mozilla.org/show_bug.cgi?id=276431-->
<xsl:template name="topic-image">

  <xsl:variable name="ends-with-svg" select="ends-with(@href, '.svg')" as="xs:boolean"/>
  <xsl:variable name="ends-with-svgz" select="ends-with(@href, '.svgz')" as="xs:boolean"/>
  <xsl:variable name="scale-to-fit">
    <xsl:choose>
      <xsl:when test="@scalefit='yes'">
        <xsl:value-of select="'d4p-ui-scale2fit'" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="isSVG" select="$ends-with-svg or $ends-with-svgz" as="xs:boolean"/>

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

    </object>
      </xsl:when>
<xsl:otherwise>
  <img>
    <xsl:attribute name="class">
    <xsl:value-of select="concat(@placement, ' ', @align, ' ', $scale-to-fit)" />
    </xsl:attribute>

    <xsl:call-template name="setid"/>

    <xsl:apply-templates select="@href"/>
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

     <xsl:attribute name="class" select="../@align" />
  </xsl:template>



 <xsl:template name="dotable">

  <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>

  <xsl:call-template name="setaname"/>

  <table>
    <xsl:call-template name="setid"/>
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

<xsl:template match="*[contains(@class,' topic/related-links ')]" name="topic.related-links">

    <div>
      <xsl:call-template name="commonattributes"/>

      <xsl:if test="contains($include.roles, ' child ') or contains($include.roles, ' descendant ')">
        <xsl:call-template name="ul-child-links"/>
        <!--handle child/descendants outside of linklists in collection-type=unordered or choice-->

        <xsl:call-template name="ol-child-links"/>
        <!--handle child/descendants outside of linklists in collection-type=ordered/sequence-->
      </xsl:if>

      <!--
          Group all unordered links (which have not already been handled by prior sections).
          Skip duplicate links.
      -->
      <!--
          NOTE: The actual grouping code for related-links:group-unordered-links is common between
                transform types, and is located in ../common/related-links.xsl. Actual code for
                creating group titles and formatting links is located in XSL files specific to each type.
      -->

      <xsl:apply-templates select="." mode="related-links:group-unordered-links">
        <xsl:with-param name="nodes" select="descendant::*[contains(@class, ' topic/link ')]
       [count(. | key('omit-from-unordered-links', 1)) != count(key('omit-from-unordered-links', 1))]
       [generate-id(.)=generate-id((key('hideduplicates', concat(ancestor::*[contains(@class, ' topic/related-links ')]/parent::*[contains(@class, ' topic/topic ')]/@id, ' ',@href,@scope,@audience,@platform,@product,@otherprops,@rev,@type,normalize-space(child::*))))[1])]"/>
      </xsl:apply-templates>

      <!--linklists - last but not least, create all the linklists and their links, with no sorting or re-ordering-->
      <xsl:apply-templates select="*[contains(@class,' topic/linklist ')]"/>
    </div>
  </xsl:template>

 <!--create the next and previous links, with accompanying parent link if any; create group for each unique parent, as well as for any next and previous links that aren't in the same group as a parent-->
  <xsl:template name="next-prev-parent-links">
    <xsl:for-each select="descendant::*
     [contains(@class, ' topic/link ')]
     [(@role='parent' and
       generate-id(.)=generate-id(
          key('link',
               concat(ancestor::*[contains(@class, ' topic/related-links ')]/parent::*[contains(@class, ' topic/topic ')]/@id,
                      ' ',
                      local:getLinkKey(.)))[1])) or
       (@role='next' and
        generate-id(.)=generate-id(
           key('link',
               concat(ancestor::*[contains(@class, ' topic/related-links ')]/parent::*[contains(@class, ' topic/topic ')]/@id,
                      ' ',
                      local:getLinkKey(.)))[1])) or
       (@role='previous' and
        generate-id(.)=generate-id(
            key('link',
                concat(ancestor::*[contains(@class, ' topic/related-links ')]/parent::*[contains(@class, ' topic/topic ')]/@id,
                       ' ',
                       local:getLinkKey(.)))[1])
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

  <xsl:function name="local:getLinkKey" as="xs:string">
    <xsl:param name="linkElem" as="element()"/>
    <xsl:variable name="childContent">
      <xsl:value-of select="$linkElem/*"></xsl:value-of>
    </xsl:variable>
    <xsl:variable name="result"
      select="concat($linkElem/@href,
              $linkElem/@type,
              $linkElem/@role,
              $linkElem/@platform,
              $linkElem/@audience,
              $linkElem/@importance,
              $linkElem/@outputclass,
              $linkElem/@keyref,
              $linkElem/@scope,
              $linkElem/@format,
              $linkElem/@otherrole,
              $linkElem/@product,
              $linkElem/@otherprops,
              $linkElem/@rev,
              $linkElem/@class,
              normalize-space($childContent))"
    />
    <xsl:sequence select="$result"/>
  </xsl:function>

  <!-- section processor - div with no generated title -->
  <xsl:template match="*[contains(@class, ' topic/section ')]" name="topic.section">
    <xsl:choose>
      <xsl:when test="$html5AnchorStrategyBoolean">
         <div class="section" id="{local:getIdForHtmlSection(.)}">
           <xsl:call-template name="commonattributes"/>
           <xsl:call-template name="set_an_anchor" />
           <xsl:apply-templates select="."  mode="section-fmt" />
         </div><xsl:value-of select="$newline"/>
      </xsl:when>
      <xsl:otherwise>
         <div class="section" id="{df:getIdForElement(.)}">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="."  mode="section-fmt" />
         </div><xsl:value-of select="$newline"/>
       </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- child topics get a div wrapper and fall through -->
  <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="child.topic" name="child.topic">
    <xsl:param name="nestlevel">
      <xsl:choose>
          <!-- Limit depth for historical reasons, could allow any depth. Previously limit was 5. -->
          <xsl:when test="count(ancestor::*[contains(@class, ' topic/topic ')]) > 9">9</xsl:when>
          <xsl:otherwise><xsl:value-of select="count(ancestor::*[contains(@class, ' topic/topic ')])"/></xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$html5AnchorStrategyBoolean">
        <section id="{local:getIdForHtmlSection(.)}">
          <xsl:call-template name="commonattributes">
            <xsl:with-param name="default-output-class" select="concat('nested', $nestlevel, ' ', @outputclass)" />
          </xsl:call-template>
          <xsl:call-template name="set_an_anchor" />
          <xsl:call-template name="gen-topic"/>
          <xsl:apply-templates/>
        </section><xsl:value-of select="$newline"/>
      </xsl:when>
      <xsl:otherwise>
        <section id="{local:getIdForHtmlSection(.)}">
          <xsl:call-template name="commonattributes">
            <xsl:with-param name="default-output-class" select="concat('nested', $nestlevel, ' ', @outputclass)" />
          </xsl:call-template>
          <xsl:call-template name="gen-topic"/>
          <xsl:apply-templates/>
        </section><xsl:value-of select="$newline"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="set_an_anchor">
    <xsl:variable name="anchorid" select="df:getIdForElement(.)"/>
    <a>
      <xsl:attribute name="id" select="$anchorid"/>
      <xsl:attribute name="class" select="'anchor'"/>
    </a>
  </xsl:template>

  <xsl:template name="gen-topic">
    <xsl:param name="nestlevel">
      <xsl:choose>
          <!-- Limit depth for historical reasons, could allow any depth. Previously limit was 5. -->
          <xsl:when test="count(ancestor::*[contains(@class, ' topic/topic ')]) > 9">9</xsl:when>
          <xsl:otherwise><xsl:value-of select="count(ancestor::*[contains(@class, ' topic/topic ')])"/></xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:choose>
      <xsl:when test="parent::dita and not(preceding-sibling::*)">
        <!-- Do not reset xml:lang if it is already set on <html> -->
        <!-- Moved outputclass to the body tag -->
        <!-- Keep ditaval based styling at this point (replace DITA-OT 1.6 and earlier call to gen-style) -->
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"/>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:function name="local:getIdForHtmlSection" as="xs:string">
    <!-- ID to use on HTML <section> elements generated from various DITA elements -->
    <xsl:param name="context"/>
    <xsl:variable name="result" as="xs:string">
    <xsl:choose>
      <xsl:when test="$html5AnchorStrategyBoolean">
       <xsl:sequence  select="concat(df:getIdForElement($context), '_section')" />
      </xsl:when>
      <xsl:otherwise>
         <xsl:sequence select="df:getIdForElement($context)" />
      </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
    <xsl:sequence select="$result"/>
  </xsl:function>

</xsl:stylesheet>

