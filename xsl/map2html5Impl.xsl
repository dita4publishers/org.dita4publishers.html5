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
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:mapdriven="http://dita4publishers.org/mapdriven"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  exclude-result-prefixes="xs xd df relpath mapdriven index-terms java xsl mapdriven htmlutil"
  xmlns:java="org.dita.dost.util.ImgUtils"
  version="2.0">

  <xsl:import href="plugin:org.dita-community.common.xslt:xsl/relpath_util.xsl"/>

  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/reportParametersBase.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.html:xsl/char127To160Map.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.html:xsl/html-generation-utils.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.mapdriven:xsl/dataCollection.xsl"/>

  <!-- Import the base HTML output generation transform. -->
  <xsl:import href="plugin:org.dita.xhtml:xsl/dita2xhtml.xsl"/>

  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/graphicMap2AntCopyScript.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/map2graphicMap.xsl"/>
  <xsl:import href="plugin:org.dita4publishers.common.xslt:xsl/topicHrefFixup.xsl"/>

  <!-- json library -->
  <xsl:import href="plugin:org.dita4publishers.json:xsl/xml2json/xml-to-json.xsl"/>
  <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>

  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlOverrides.xsl"/>
  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlEnumeration.xsl"/>
  <xsl:include href="plugin:org.dita4publishers.common.html:xsl/commonHtmlBookmapEnumeration.xsl"/>

  <xsl:include href="map2html5Nav.xsl"/>
  <xsl:include href="map2html5Search.xsl"/>
  <xsl:include href="map2html5Content.xsl"/>
  <xsl:include href="map2html5RootContent.xsl"/>
  <xsl:include href="map2html5ChunkContent.xsl" />
  <xsl:include href="map2html5Collection.xsl"/>
  <xsl:include href="map2html5Template.xsl"/>
  <xsl:include href="nav-point-title.xsl"/>
  <xsl:include href="commonHtmlExtensionSupport.xsl"/>
  <xsl:include href="metadata.xsl"/>
  <xsl:include href="jsAndCss.xsl"/>
  <xsl:include href="i18n.xsl"/>
  <xsl:include href="audience.xsl"/>
  <xsl:include href="map2html5Index.xsl"/>
  <xsl:include href="reltable.xsl"/>
  <xsl:include href="cleanup.xsl"/>

  <xsl:variable name="include.roles" select="concat(' ', normalize-space($include.rellinks), ' ')"/>

  <!-- specify json format for org.dita4publishers.json -->
  <xsl:param name="use-rabbitfish" as="xs:boolean" select="false()"/>
  <xsl:param name="skip-root" as="xs:boolean" select="true()"/>

  <xsl:param name="inputFileNameParam"/>

  <!-- Directory into which the generated output is put adding  as="xs:string"
       cause plugin to crash on Unbuntu + Mac OS X.8 on some installation
       Must find why in order to set the param properly
  -->
  <xsl:param name="outdir" select="./html5" />
  <!-- The directory containing the original input root map (not the
       the temporary directory containing the map we're already processing.

       NOTE: As of OT 2.0, there is no Ant parameter that provides the input directory,
             so we use the @xtrf attribute to get the directory containing the input
             map.
    -->
  <xsl:param name="inputdir" select="relpath:getParent(relpath:getParent(/*/@xtrf))" as="xs:string"/>

 <!--
    NOTE: Case of OUTEXT parameter matches case used in base HTML
    transformation type.
  -->
  <xsl:param name="OUTEXT" select="'.html'" as="xs:string"/>
  <xsl:param name="jsOutExt" select="$OUTEXT"/>
  <xsl:param name="tempdir" select="./temp" as="xs:string"/>

 <!--
    The path of the directory, relative the $outdir parameter,
    to hold the graphics in the result HTML package. Should not have
    a leading "/".
  -->
  <xsl:param name="imagesOutputDir" select="'images'" as="xs:string"/>
    <!-- The path of the directory, relative the $outdir parameter,
         to hold the topics in the HTML package. Should not have
         a leading "/".
  -->
  <xsl:param name="topicsOutputDir" select="'topics'" as="xs:string"/>

  <!-- The path of the directory, relative the $outdir parameter,
    to hold the CSS files in the HTML package. Should not have
    a leading "/".
  -->
  <xsl:param name="cssOutputDir" select="'css'" as="xs:string"/>

  <xsl:param name="html5CSSPath" select="'css'" as="xs:string"/>

  <xsl:param name="debug" select="'false'" as="xs:string"/>

  <xsl:param name="rawPlatformString" select="'unknown'" as="xs:string"/><!-- As provided by Ant -->

  <xsl:param name="titleOnlyTopicClassSpec" select="'- topic/topic '" as="xs:string"/>

  <xsl:param name="titleOnlyTopicTitleClassSpec" select="'- topic/title '" as="xs:string"/>

  <!-- The strategy to use when constructing output files. Default is "as-authored", meaning
       reflect the directory structure of the topics as authored relative to the root map,
       possibly as reworked by earlier Toolkit steps.
    -->
  <xsl:param name="fileOrganizationStrategy" as="xs:string" select="'as-authored'"/>


  <!-- Maxminum depth of the generated ToC -->
  <xsl:param name="maxTocDepth" as="xs:string" select="'5'"/>

  <!-- Include back-of-the-book-index if any index entries in source

       For now default to no since index generation is still under development.
  -->
  <xsl:param name="generateIndex" as="xs:string" select="'no'"/>
  <xsl:variable name="generateIndexBoolean"
    select="matches($generateIndex, 'yes|true|on|1', 'i')"
  />

  <!-- Generate the glossary dynamically using all glossary entry
       topics included in the map.
    -->
  <xsl:param name="generateGlossary" as="xs:string" select="'no'"/>
  <xsl:variable name="generateGlossaryBoolean"
    select="matches($generateGlossary, 'yes|true|on|1', 'i')"
  />

  <xsl:param name="showTocEntry" as="xs:string" select="'yes'"/>
  <xsl:variable name="showTocEntryBoolean"
    select="matches($showTocEntry, 'yes|true|on|1', 'i')"
  />


  <!-- value for @class on <body> of the generated static TOC HTML document -->
  <xsl:param name="staticTocBodyOutputclass" select="''" as="xs:string"/>

  <xsl:param name="contenttarget" select="'contentwin'"/>

  <xsl:param name="generateDynamicToc" select="'true'"/>
  <xsl:param name="generateDynamicTocBoolean" select="matches($generateDynamicToc, 'yes|true|on|1', 'i')"/>

  <xsl:param name="generateFrameset" select="'true'"/>
  <xsl:param name="generateFramesetBoolean" select="matches($generateFrameset, 'yes|true|on|1', 'i')"/>

  <xsl:param name="generateStaticToc" select="'false'"/>
  <xsl:param name="generateStaticTocBoolean" select="matches($generateStaticToc, 'yes|true|on|1', 'i')"/>

  <xsl:param name="generateSearchEngine" select="'true'"/>
  <xsl:param name="generateSearchEngineBoolean" select="matches($generateSearchEngine, 'yes|true|on|1', 'i')"/>
  <xsl:param name="searchEngineMinLength" as="xs:integer" select="2"/>

  <xsl:param name="navigationLeft" select="'true'"/>
  <xsl:param name="navigationLeftBoolean" select="matches($navigationLeft, 'yes|true|on|1', 'i')"/>

  <xsl:param name="indexIsFirstTopic" select="'false'"/>
  <xsl:param name="indexIsFirstTopicBoolean" select="matches($indexIsFirstTopic, 'yes|true|on|1', 'i')"/>

  <xsl:param name="dita-css" select="'css/topic-html5.css'" as="xs:string"/>
  <xsl:param name="TRANSTYPE" select="'html5'" />
  <xsl:param name="siteTheme" select="'theme-01'" />
  <xsl:param name="BODYCLASS" select="''" />
  <xsl:param name="CLASSNAVIGATION" select="'left'" />
  <xsl:param name="jsoptions" select="''" />
  <xsl:param name="JS" select="''" />
  <xsl:param name="CSSTHEME" select="''" />
  <xsl:param name="NAVIGATIONMARKUP" select="'default'" />
  <xsl:param name="JSONVARFILE" select="''" />
  <xsl:param name="HTML5D4PINIT" select="''" />

  <xsl:param name="HTML5THEMEDIR" select="'themes'" />
  <xsl:param name="HTML5THEMECONFIG" select="''" />
  <xsl:param name="HTML5THEMECONFIGDIR" select="''" />

  <xsl:param name="DRAFT" select="''" />
  <xsl:param name="ISDRAFT" as="xs:boolean" select="if($DRAFT = 'yes') then true() else false()" />
  <!-- CSS classes and IDs -->
  <xsl:param name="IDMAINCONTAINER" select="'d4h5-main-container'" />
  <xsl:param name="CLASSMAINCONTAINER" select="''" />
  <xsl:param name="IDMAINCONTENT" select="'d4h5-main-content'" />
  <xsl:param name="CLASSMAINCONTENT" select="''" />
  <xsl:param name="CLASSROOTMAINCONTENT" select="''" />
  <xsl:param name="CLASSHOMEPAGE" select="''" />
  <xsl:param name="CLASSICONPARENT" select="''" />
  <xsl:param name="CLASSICONLEFT" select="''" />
  <xsl:param name="CLASSICONRIGHT" select="''" />
  <xsl:param name="IDSECTIONCONTAINER" select="'d4h5-section-container'" />
  <xsl:param name="CLASSSECTIONCONTAINER" select="''" />
  <xsl:param name="IDLOCALNAV" select="'home'" />
  <xsl:param name="GRIDPREFIX" select="'grid_'" />
  <xsl:param name="CLASSSCREENREADER" select="'screen-reader'" />
  <xsl:param name="uplevels" select="''" />
  <xsl:param name="html5absolulteuri" select="''" />
  <xsl:param name="OUTPUTDEFAULTNAVIGATION" select="true()" />
  <xsl:param name="html5IndexFilename" select="'index'" />

  <xsl:param name="html5outputsizestrategy" select="'yes'"/>
  <xsl:param name="html5outputsizestrategyBoolean" select="matches($html5outputsizestrategy, 'yes|true|on|1', 'i')"/>

  <xsl:param name="html5AnchorStrategy" select="'yes'"/>
  <xsl:param name="html5AnchorStrategyBoolean" select="matches($html5AnchorStrategy, 'yes|true|on|1', 'i')"/>


  <xsl:param name="outputKeyref" select="'yes'"/>
  <xsl:param name="outputKeyrefBoolean" select="matches($html5outputsizestrategy, 'yes|true|on|1', 'i')"/>

  <xsl:variable name="maxTocDepthInt" select="xs:integer($maxTocDepth)" as="xs:integer"/>
  <xsl:variable name="version" select="if(/map/topicmeta/prodinfo/vrmlist/vrm/@version) then /map/topicmeta/prodinfo/vrmlist/vrm/@version else ''" as="xs:string"/>

  <xsl:variable name="xsloutput">
    <xsl:choose>
      <xsl:when test="$html5outputsizestrategyBoolean and not($ISDRAFT)">
        <xsl:value-of select="'html5-no-indent'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'html5'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="newline">
   <xsl:choose>
      <xsl:when test="$html5outputsizestrategyBoolean and not($ISDRAFT)">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <xsl:variable name="platform" as="xs:string"
    select="
    if (starts-with($rawPlatformString, 'Win') or
        starts-with($rawPlatformString, 'Win'))
       then 'windows'
       else 'nx'
    "
  />

  <xsl:variable name="debugBinary" select="$debug = 'true'" as="xs:boolean"/>

  <xsl:variable name="topicsOutputPath">
    <xsl:choose>
      <xsl:when test="$topicsOutputDir != ''">
        <xsl:sequence select="concat($outdir, $topicsOutputDir)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$outdir"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <xsl:variable name="imagesOutputPath">
    <xsl:choose>
      <xsl:when test="$imagesOutputDir != ''">
        <xsl:sequence select="concat($outdir,
            if (ends-with($outdir, '/')) then '' else '/',
            $imagesOutputDir)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$outdir"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <xsl:variable name="indexUri" as="xs:string" select="concat($html5IndexFilename, $OUTEXT)"/>
  <xsl:variable name="HTML5THEMECONFIGDOC" select="document($HTML5THEMECONFIG)" />

  <xsl:variable name="TEMPLATELANG">
   <xsl:apply-templates select="/map" mode="mapAttributes" />
  </xsl:variable>

<!--  <xsl:variable name="DEFAULTLANG" select="$TEMPLATELANG"/>-->

  <xsl:template match="*" mode="mapAttributes" >
    <xsl:call-template name="getLowerCaseLang"/>
  </xsl:template>

  <xsl:template name="report-parameters" match="*" mode="report-parameters">
    <xsl:param name="effectiveCoverGraphicUri" select="''" as="xs:string" tunnel="yes"/>
    <xsl:message>
      ==========================================
      Plugin version: ^version^ - build ^buildnumber^ at ^timestamp^

      HTML5 Parameters:

      + CLASSMAINCONTAINER = "<xsl:sequence select="$CLASSMAINCONTAINER"/>"
      + CLASSNAVIGATION    = "<xsl:sequence select="$CLASSNAVIGATION"/>"
      + CLASSSECTIONCONTAINER= "<xsl:sequence select="$CLASSSECTIONCONTAINER"/>"
      + CSSTHEME           = "<xsl:sequence select="$CSSTHEME"/>"
      + IDMAINCONTAINER    = "<xsl:sequence select="$IDMAINCONTAINER"/>"
      + IDSECTIONCONTAINER = "<xsl:sequence select="$IDSECTIONCONTAINER"/>"
      + inputdir           = "<xsl:sequence select="$inputdir"/>"
      + jsoptions          = "<xsl:sequence select="$jsoptions"/>"
      + JS                 = "<xsl:sequence select="$JS"/>"
      + JSONVARFILE        = "<xsl:sequence select="$JSONVARFILE"/>"
      + cssOutputDir       = "<xsl:sequence select="$cssOutputDir"/>"
      + fileOrganizationStrategy = "<xsl:sequence select="$fileOrganizationStrategy"/>"
      + generateGlossary   = "<xsl:sequence select="$generateGlossary"/>"
      + generateFrameset   = "<xsl:sequence select="$generateFrameset"/>"
      + generateIndex      = "<xsl:sequence select="$generateIndex"/>
      + generateStaticToc  = "<xsl:sequence select="$generateStaticToc"/>"
      + imagesOutputDir    = "<xsl:sequence select="$imagesOutputDir"/>"
      + inputFileNameParam = "<xsl:sequence select="$inputFileNameParam"/>"
      + mathJaxUseCDNLink  = "<xsl:sequence select="$mathJaxUseCDNLink"/>"
      + mathJaxUseLocalLink= "<xsl:sequence select="$mathJaxUseLocalLink"/>"
      + mathJaxLocalJavascriptUri= "<xsl:sequence select="$mathJaxLocalJavascriptUri"/>"
      + mathJaxConfigParam = "<xsl:sequence select="$mathJaxConfigParam"/>"
      + NAVIGATIONMARKUP   = "<xsl:sequence select="$NAVIGATIONMARKUP"/>"
      + outdir             = "<xsl:sequence select="$outdir"/>"
      + OUTEXT             = "<xsl:sequence select="$OUTEXT"/>"
      + tempdir            = "<xsl:sequence select="$tempdir"/>"
      + titleOnlyTopicClassSpec = "<xsl:sequence select="$titleOnlyTopicClassSpec"/>"
      + titleOnlyTopicTitleClassSpec = "<xsl:sequence select="$titleOnlyTopicTitleClassSpec"/>"
      + topicsOutputDir    = "<xsl:sequence select="$topicsOutputDir"/>"

      DITA2HTML parameters:

      + CSS             = "<xsl:sequence select="$CSS"/>"
      + CSSPATH         = "<xsl:sequence select="$CSSPATH"/>"
      + FILEDIR         = "<xsl:sequence select="$FILEDIR"/>"
      + FILTERFILE      = "<xsl:sequence select="$FILTERFILE"/>"
      + KEYREF-FILE     = "<xsl:sequence select="$KEYREF-FILE"/>"
      + OUTPUTDIR       = "<xsl:sequence select="$OUTPUTDIR"/>"
      + PATH2PROJ       = "<xsl:sequence select="$PATH2PROJ"/>"
      + WORKDIR         = "<xsl:sequence select="$WORKDIR"/>"

      + debug           = "<xsl:sequence select="$debug"/>"

      Global Variables:

      + topicsOutputPath = "<xsl:sequence select="$topicsOutputPath"/>"
      + imagesOutputPath = "<xsl:sequence select="$imagesOutputPath"/>"
      + platform         = "<xsl:sequence select="$platform"/>"
      + debugBoolean     = "<xsl:sequence select="$debugBoolean"/>"
    </xsl:message>
    <xsl:next-match/>
    <xsl:apply-imports/>
    <xsl:message>
      ==========================================
    </xsl:message>
  </xsl:template>




  <xsl:template match="/">
    <xsl:message> + [INFO] Using DITA for Publishers HTML5 transformation type
  </xsl:message>

    <xsl:apply-templates>
      <xsl:with-param name="rootMapDocUrl" select="document-uri(.)" as="xs:string" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="/*[df:class(., 'map/map')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>

    <xsl:apply-templates select="." mode="report-parameters"/>

    <!-- If entire map is one big chunk we need to operate a little differently -->
    <xsl:variable name="isChunkedMap" as="xs:boolean" select="df:mapIsChunkToContent(.)" />

    <xsl:apply-templates select="." mode="html5-impl" />

    <xsl:choose>
      <xsl:when test="$isChunkedMap">
        <xsl:apply-templates select="." mode="chunked-map-processing">
          <xsl:with-param name="isChunkedMap" as="xs:boolean" select="$isChunkedMap" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="standard-map-processing">
          <xsl:with-param name="isChunkedMap" as="xs:boolean" select="$isChunkedMap" tunnel="yes"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/*[df:class(., 'map/map')]" mode="chunked-map-processing">
     <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
     <xsl:param name="isChunkedMap" as="xs:boolean" tunnel="yes" />
    <!-- this is intended to allow developper to add custom hook -->
    <xsl:message>  + [INFO] Processing Chunked Map</xsl:message>

     <xsl:variable name="chunkTopicrefs" as="element()*" select="df:getUniqueTopicrefsFromChunkedMap(.)"/>

    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] chunkRootTopicref=
        <xsl:sequence select="$chunkTopicrefs"/>
      </xsl:message>
    </xsl:if>

    <xsl:message> + [INFO] Collecting data for index generation, enumeration, etc....</xsl:message>

    <!-- collected data -->
    <xsl:variable name="collected-data" as="element()">
      <xsl:call-template name="mapdriven:collect-data"/>
    </xsl:variable>

    <!-- map data elements -->
    <xsl:variable name="map-metadata" as="element()*">
      <xsl:sequence select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, 'topic/data')]" />
    </xsl:variable>

    <xsl:if test="false() or $debugBoolean">
      <xsl:message> + [DEBUG] Writing file <xsl:sequence select="relpath:newFile($outdir, 'collected-data.xml')"/>...</xsl:message>
      <xsl:result-document href="{relpath:newFile($outdir, 'collected-data.xml')}"
        format="indented-xml"
        >
        <xsl:sequence select="$collected-data"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:variable name="documentation-title" as="xs:string">
        <xsl:apply-templates select="." mode="generate-root-page-header" />
    </xsl:variable>

     <!-- NOTE: By default, this mode puts its output in the main output file
         produced by the transform.
    -->
    <xsl:variable name="navigation" as="element()*">
      <xsl:apply-templates select="." mode="choose-html5-nav-markup" >
        <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
        <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$chunkTopicrefs" tunnel="yes"/>
        <xsl:with-param name="has-index" as="xs:boolean" select="false()" tunnel="yes" />
        <xsl:with-param name="documentation-title" select="$documentation-title" tunnel="yes"/>
        <xsl:with-param name="isChunkedMap" as="xs:boolean" select="$isChunkedMap" tunnel="yes"/>
        <xsl:with-param name="indexUri" as="xs:string" select="$indexUri" tunnel = "yes" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:apply-templates select="." mode="generate-chunked-map-content">
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$chunkTopicrefs" tunnel="yes"/>
      <xsl:with-param name="navigation" as="element()*" select="$navigation" tunnel="yes"/>
      <xsl:with-param name="baseUri" as="xs:string" select="@xtrf" tunnel="yes"/>
      <xsl:with-param name="documentation-title" select="$documentation-title" tunnel="yes"/>
      <xsl:with-param name="has-index" as="xs:boolean" select="false()" tunnel="yes" />
      <xsl:with-param name="is-root" as="xs:boolean" select="false()" tunnel="yes"/>
      <xsl:with-param name="map-metadata" select="$map-metadata" tunnel="yes"/>
      <xsl:with-param name="indexUri" as="xs:string" select="$indexUri" tunnel = "yes" />
      <xsl:with-param name="isChunkedMap" as="xs:boolean" select="$isChunkedMap" tunnel="yes"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template match="/*[df:class(., 'map/map')]" mode="standard-map-processing">
    <xsl:param name="isChunkedMap" as="xs:boolean" tunnel="yes" />
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    <!-- this is intended to allow developper to add custom hook -->
    <xsl:message>  + [INFO] Processing Standard Map</xsl:message>

    <xsl:variable name="uniqueTopicRefs" as="element()*" select="df:getUniqueTopicrefs(.)"/>

    <!-- graphic map -->
    <xsl:message> + [INFO] Generating graphicMap...</xsl:message>
    <!-- collected data -->
    <xsl:variable name="graphicMap" as="element()">
      <xsl:apply-templates select="." mode="generate-graphic-map">
        <xsl:with-param name="uplevels" select="$uplevels" as="xs:string" tunnel="yes" />
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="false() or $debugBoolean">
      <xsl:message> + [DEBUG] Writing file <xsl:sequence select="relpath:newFile($outdir, 'graphicMap.xml')"/>...</xsl:message>
      <xsl:result-document href="{relpath:newFile($outdir, 'graphicMap.xml')}" format="graphic-map">
      <xsl:sequence select="$graphicMap"/>
    </xsl:result-document>
    </xsl:if>


    <xsl:message> + [INFO] Collecting data for index generation, enumeration, etc....</xsl:message>
    <!-- collected data -->
    <xsl:variable name="collected-data" as="element()">
      <xsl:call-template name="mapdriven:collect-data"/>
    </xsl:variable>

    <!-- map data elements -->
    <xsl:variable name="map-metadata" as="element()*">
      <xsl:sequence select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, 'topic/data')]" />
    </xsl:variable>

    <xsl:if test="$debugBoolean">
      <xsl:message> + [DEBUG] Writing file <xsl:sequence select="relpath:newFile($outdir, 'collected-data.xml')"/>...</xsl:message>
      <xsl:result-document href="{relpath:newFile($outdir, 'collected-data.xml')}"
        format="indented-xml"
        >
        <xsl:sequence select="$collected-data"/>
      </xsl:result-document>
    </xsl:if>

    <xsl:variable name="documentation-title" as="xs:string">
        <xsl:apply-templates select="." mode="generate-root-page-header" />
    </xsl:variable>

    <xsl:message> + [INFO] Generating audience selector...</xsl:message>
    <xsl:variable name="audienceSelect">
      <xsl:apply-templates select="." mode="generate-audience-select">
        <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
        <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$uniqueTopicRefs" tunnel="yes"/>
        <xsl:with-param name="documentation-title" as="xs:string" select="$documentation-title" tunnel="yes"/>
        <xsl:with-param name="is-root" as="xs:boolean" select="true()" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="$generateSearchEngineBoolean">
      <xsl:message> + [INFO] Generating search engine index...</xsl:message>
      <xsl:apply-templates select="." mode="generate-search-index">
        <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
        <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$uniqueTopicRefs" tunnel="yes"/>
        <xsl:with-param name="baseUri" as="xs:string" select="@xtrf" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:if>

    <xsl:message> + [INFO] Generating back-of-the-book index...</xsl:message>
    <xsl:variable name="index-content">
      <xsl:apply-templates select="." mode="generate-index" >
       <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="has-index">
      <xsl:choose>
        <xsl:when test = "$index-content = ''">
          <xsl:value-of select="false()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="true()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- NOTE: By default, this mode puts its output in the main output file
         produced by the transform.
    -->
    <xsl:message> + [INFO] Generating navigation...</xsl:message>
    <xsl:variable name="navigation" as="element()*">
      <xsl:apply-templates select="." mode="choose-html5-nav-markup" >
        <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
        <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$uniqueTopicRefs" tunnel="yes"/>
        <xsl:with-param name="has-index" as="xs:boolean" select="$has-index" tunnel="yes" />
        <xsl:with-param name="documentation-title" select="$documentation-title" tunnel="yes"/>
        <xsl:with-param name="audienceSelect"  select="$audienceSelect" tunnel="yes"/>
        <xsl:with-param name="showTocEntry" as="xs:boolean" tunnel="yes" select="$showTocEntryBoolean" />
      </xsl:apply-templates>
    </xsl:variable>

<!--    <xsl:message> + [DEBUG] standard-map-processing: navigation:
<xsl:sequence select="$navigation"/>
    </xsl:message>
-->

    <xsl:message> + [INFO] Generating root pages...</xsl:message>
    <xsl:apply-templates select="." mode="generate-root-pages">
        <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
        <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$uniqueTopicRefs" tunnel="yes"/>
        <xsl:with-param name="navigation" as="element()*" select="$navigation" tunnel="yes"/>
        <xsl:with-param name="baseUri" as="xs:string" select="@xtrf" tunnel="yes"/>
        <xsl:with-param name="documentation-title" select="$documentation-title" tunnel="yes"/>
        <xsl:with-param name="audienceSelect"  select="$audienceSelect" tunnel="yes"/>
        <xsl:with-param name="indexUri" as="xs:string" select="$indexUri" tunnel = "yes" />
    </xsl:apply-templates>

    <xsl:message> + [INFO] Generating content pages...</xsl:message>
     <xsl:apply-templates select="." mode="generate-content">
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
      <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$uniqueTopicRefs" tunnel="yes"/>
      <xsl:with-param name="navigation" as="element()*" select="$navigation" tunnel="yes"/>
      <xsl:with-param name="baseUri" as="xs:string" select="@xtrf" tunnel="yes"/>
      <xsl:with-param name="documentation-title" select="$documentation-title" tunnel="yes"/>
      <xsl:with-param name="has-index" as="xs:boolean" select="$has-index" tunnel="yes" />
      <xsl:with-param name="is-root" as="xs:boolean" select="false()" tunnel="yes"/>
      <xsl:with-param name="audienceSelect"  select="$audienceSelect" tunnel="yes"/>
      <xsl:with-param name="map-metadata" select="$map-metadata" tunnel="yes"/>
    </xsl:apply-templates>

    <!-- add index support -->

      <xsl:if test="$has-index">
        <xsl:message> + [INFO] Generating back-of-the-book index page...</xsl:message>
        <xsl:apply-templates select="." mode="generate-index-page">
          <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
          <xsl:with-param name="uniqueTopicRefs" as="element()*" select="$uniqueTopicRefs" tunnel="yes"/>
          <xsl:with-param name="navigation" as="element()*" select="$navigation" tunnel="yes"/>
          <xsl:with-param name="baseUri" as="xs:string" select="@xtrf" tunnel="yes"/>
          <xsl:with-param name="documentation-title" select="$documentation-title" tunnel="yes"/>
          <xsl:with-param name="index-content" select="$index-content" tunnel="yes" />
          <xsl:with-param name="is-root" as="xs:boolean" select="false()" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:if>

    <!--xsl:apply-templates select="." mode="generate-glossary">
      <xsl:with-param name="collected-data" as="element()" select="$collected-data" tunnel="yes"/>
    </xsl:apply-templates-->

    <xsl:message> + [INFO] Generating graphic copy Ant script...</xsl:message>
    <xsl:apply-templates select="." mode="generate-graphic-copy-ant-script">
      <xsl:with-param name="graphicMap" as="element()" tunnel="yes" select="$graphicMap"/>
    </xsl:apply-templates>

  </xsl:template>

  <xsl:template mode="generate-root-page-header" match="*[df:class(., 'map/map')]">
    <!-- hook for a user-XSL title prefix -->
    <xsl:call-template name="gen-user-panel-title-pfx"/>
    <xsl:apply-templates select="." mode="generate-map-title-tree" />
  </xsl:template>

  <xsl:template name="map-title" match="*" mode="generate-map-title-tree">
    <xsl:choose>
        <xsl:when test="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')]">
          <xsl:apply-templates select="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')]" mode="generate-map-title" />
        </xsl:when>
        <xsl:when test="/*[contains(@class,' map/map ')]/@title">
          <xsl:value-of select="/*[contains(@class,' map/map ')]/@title" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''" />
        </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[contains(@class,' topic/title ')]" mode="generate-map-title">
    <xsl:sequence select="." />
  </xsl:template>

  <xsl:template mode="html5-impl" match="*" />

  <xsl:template match="*[df:isTopicGroup(.)]" mode="nav-point-title">
    <!-- Per the 1.2 spec, topic group navtitles are always ignored -->
  </xsl:template>

  <xsl:template mode="nav-point-title" match="*[df:class(., 'topic/fn')]" priority="10">
    <!-- Suppress footnotes in titles -->
  </xsl:template>

  <!-- Enumeration mode manages generating numbers from topicrefs -->
  <xsl:template match="* | text()" mode="enumeration">
    <xsl:if test="false() and $debugBoolean">
      <xsl:message> + [DEBUG] enumeration: catch-all template. Element="<xsl:sequence select="name(.)"/></xsl:message>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
