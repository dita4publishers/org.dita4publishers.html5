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
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="#all"
  version="2.0">


  <!-- Default output should be HTML5 -->
  <xsl:output method="html" indent="yes" encoding="utf-8"
    use-character-maps="chars-127to160"
    doctype-system="about:legacy-compat" omit-xml-declaration="yes"/>
  <xsl:output name="html5" method="html" indent="yes" encoding="utf-8"
    use-character-maps="chars-127to160"
    doctype-system="about:legacy-compat" omit-xml-declaration="yes"/>
  <xsl:output name="html5-no-indent" method="html" indent="no" encoding="utf-8"
    use-character-maps="chars-127to160"
    doctype-system="about:legacy-compat" omit-xml-declaration="yes"/>
  <xsl:output name="indented-xml" method="xml" indent="yes" omit-xml-declaration="yes"
    use-character-maps="chars-127to160"
  />

  <xsl:template mode="toc-title" match="*[df:isTopicRef(.)] | *[df:isTopicHead(.)]">
    <xsl:variable name="titleValue" select="df:getNavtitleForTopicref(.)"/>
    <xsl:sequence select="$titleValue"/>
  </xsl:template>

  <!-- FIXME: Replace this with a separate mode that will handle markup within titles -->
  <xsl:template mode="gen-head-title" match="*">
    <xsl:param name="documentation-title" as="xs:string" select="''" tunnel="yes" />
    <xsl:param name="topic-title" as="xs:string" select="''" tunnel="yes" />

    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="*[df:class(., 'topic/title')][1]">
          <xsl:value-of select="*[df:class(., 'topic/title')][1]" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$documentation-title" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <title><xsl:value-of select="normalize-space($title)" /></title>
  </xsl:template>


  <xsl:template match="*" mode="generate-html5-page">
    <html>
      <xsl:attribute name = "lang" select="$TEMPLATELANG" />
      <xsl:apply-templates select="." mode="generate-head"/>
      <xsl:apply-templates select="." mode="generate-body"/>
    </html>
  </xsl:template>

  <!-- page links are intented to be used for screen reader -->
  <xsl:template name="gen-page-links">
    <xsl:if test="$html5ForceAccessibilityBoolean">
      <ul id="page-links" class="hidden">
        <li><a id="skip-to-content" href="#{$IDMAINCONTENT}">
              <xsl:call-template name="getString">
                <xsl:with-param name="stringName" select="'SkipToContent'"/>
              </xsl:call-template>
            </a>
        </li>
        <li><a id="skip-to-localnav" href="#local-navigation">
              <xsl:call-template name="getString">
                <xsl:with-param name="stringName" select="'SkipToLocalNav'"/>
              </xsl:call-template>
            </a>
        </li>
        <li><a id="skip-to-footer" href="#footer">
              <xsl:call-template name="getString">
                <xsl:with-param name="stringName" select="'SkipToFooter'"/>
              </xsl:call-template>
            </a>
        </li>
      </ul>
    </xsl:if>
  </xsl:template>

  <!-- define class attribute -->
  <xsl:template match="*" mode="set-body-class-attr">
    <xsl:param name="is-root" as="xs:boolean" tunnel="yes" select="false()" />
    <xsl:attribute name = "class">
      <xsl:call-template name="getLowerCaseLang"/>
        <xsl:sequence select="' '"/>
        <xsl:value-of select="$siteTheme" />
        <xsl:sequence select="' '"/>
        <xsl:value-of select="$BODYCLASS" />
        <xsl:apply-templates select="." mode="gen-user-body-class"/>
        <xsl:if test="$is-root">
          <xsl:sequence select="' '"/>
          <xsl:value-of select="$CLASSHOMEPAGE"/>
        </xsl:if>
    </xsl:attribute>
  </xsl:template>

  <!-- used to defined initial content if javascript is off -->
  <xsl:template match="*" mode="set-initial-content">
    <noscript>
      <p>
        <xsl:call-template name="getString">
          <xsl:with-param name="stringName" select="'turnJavascriptOn'"/>
        </xsl:call-template>
      </p>
    </noscript>
  </xsl:template>

  <!-- used to output the html5 header -->
  <xsl:template match="*" mode="generate-header">
    <xsl:param name="documentation-title" as="xs:string" select="''" tunnel="yes" />
    <header role="banner" aria-labelledby="publication-title" class="hide-for-small">
      <div class="grid_8">
       <h1 id="publication-title">
        <xsl:value-of select="$documentation-title"/>
      </h1>
      </div>
      <section class="grid_4 search-box">
        <xsl:apply-templates select="." mode="gen-search-box" />
      </section>
      <secion class="clearfix" />
    </header>
  </xsl:template>

  <xsl:template match="*" mode="gen-search-box">
    <xsl:variable name="placeholder">
      <xsl:call-template name="getString">
        <xsl:with-param name="stringName" select="'SearchPlaceholder'"/>
      </xsl:call-template>
    </xsl:variable>
    <form id="search" role="search">
      <div class="form-group">
        <input id="search-text" type="text" autocomplete="off" class="form-control" placeholder="Search"/>
      </div>
    </form>
  </xsl:template>

  <!-- used to output the head -->
  <xsl:template match="*" mode="generate-head">
    <head>
      <xsl:apply-templates select="." mode="gen-head-title" />
      <xsl:apply-templates select="." mode="gen-user-top-head" />
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      <!-- Dublin core metadata, schema -->
      <link rel="schema.DC" href="http://purl.org/dc/terms/" />
      <xsl:call-template name="getMeta"/>
      <xsl:apply-templates mode="getTopicMeta"/>
      <xsl:call-template name="copyright"/>
      <xsl:apply-templates select="." mode="generate-css-js"/>
      <xsl:apply-templates select="." mode="gen-user-bottom-head" />
    </head>
  </xsl:template>



  <!-- generate body -->
  <xsl:template match="*" mode="generate-body">
    <xsl:param name="map-metadata" as="element()*" tunnel="yes" />
    <body>
      <xsl:apply-templates select="." mode="set-body-class-attr" />
      <xsl:apply-templates select="." mode="gen-user-body-top" />
      <xsl:apply-templates select="." mode="generate-main-container"/>
      <xsl:apply-templates select="." mode="gen-user-body-bottom" />
      <xsl:apply-templates select="$map-metadata" mode="flag" />
    </body>
  </xsl:template>

  <!-- main content -->
  <xsl:template match="*" mode="generate-main">
    <xsl:param name="is-root" as="xs:boolean"  tunnel="yes" select="false()" />
    <xsl:param name="navigation" as="element()*"  tunnel="yes" />

    <section id="page">
      <div>

       <xsl:call-template name="set_an_anchor" />

        <!-- Already put xml:lang on <html>; do not copy to body with commonattributes -->
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"/>
        <xsl:value-of select="$newline"/>

        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>

        <xsl:if test="$INDEXSHOW='yes'">
          <xsl:apply-templates select="/*/*[contains(@class,' topic/prolog ')]/*[contains(@class,' topic/metadata ')]/*[contains(@class,' topic/keywords ')]/*[contains(@class,' topic/indexterm ')] |
            /dita/*[1]/*[contains(@class,' topic/prolog ')]/*[contains(@class,' topic/metadata ')]/*[contains(@class,' topic/keywords ')]/*[contains(@class,' topic/indexterm ')]"/>
        </xsl:if>

        <!-- Include a user's XSL call here to generate a toc based on what's a child of topic -->
        <xsl:call-template name="gen-user-sidetoc"/>

        <xsl:choose>
          <xsl:when test="$is-root">
              <h1><xsl:call-template name="getString">
                <xsl:with-param name="stringName" select="'TOC'"/>
              </xsl:call-template></h1>
               <xsl:sequence select="$navigation"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="content">
              <xsl:apply-templates />
            </xsl:variable>
            <xsl:apply-templates select="$content"  mode="clean-linebreaks"/>
          </xsl:otherwise>
        </xsl:choose>

        <!-- this will include all things within topic; therefore, -->
        <!-- title content will appear here by fall-through -->
        <!-- followed by prolog (but no fall-through is permitted for it) -->
        <!-- followed by body content, again by fall-through in document order -->
        <!-- followed by related links -->
        <!-- followed by child topics by fall-through -->

        <xsl:call-template name="gen-endnotes"/>    <!-- include footnote-endnotes -->

        <xsl:apply-templates select="." mode="generate-previous-next-topic-links"/>

        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
      </div>
    </section>
    <xsl:value-of select="$newline"/>
  </xsl:template>

   <!-- generate html5 footer, import from XML file -->
  <xsl:template match="*" mode="generate-previous-next-topic-links">
     <xsl:param name="topicref" as="element()*" tunnel="yes"/>

     <footer id="topicsNPLinks">

       <div id="footer_previous">
            <xsl:call-template name="getPrevTopicReference"/>
       </div>

       <div id="footer_next">
          <xsl:call-template name="getNextTopicReference"/>
       </div>

     </footer>
  </xsl:template>

  <!-- generate main container -->
  <xsl:template match="*" mode="generate-main-container">
    <div id="{$IDMAINCONTAINER}" class="{$CLASSMAINCONTAINER}" role="application">
      <xsl:call-template name="gen-page-links" />
      <xsl:apply-templates select="." mode="generate-header"/>
      <xsl:apply-templates select="." mode="generate-section-container"/>
      <xsl:apply-templates select="." mode="generate-footer"/>
    </div>
  </xsl:template>

  <!-- generate section container -->
  <xsl:template match="*" mode="generate-section-container">
    <xsl:param name="navigation" as="element()*"  tunnel="yes" />
    <xsl:param name="is-root" as="xs:boolean"  tunnel="yes" select="false()" />
    <xsl:param name="resultUri" as="xs:string" tunnel="yes" select="''" />

    <div id="{$IDSECTIONCONTAINER}" class="{$CLASSSECTIONCONTAINER}">
      <xsl:call-template name="navigation">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debugBoolean"/>
      </xsl:call-template>
      <xsl:apply-templates select="." mode="generate-main-content"/>
      <div class="clearfix"></div>
    </div>

  </xsl:template>

   <!-- generate main content -->
  <xsl:template match="*" mode="generate-main-content">
    <xsl:param name="is-root" as="xs:boolean"  tunnel="yes" select="false()" />
    <xsl:param name="content" tunnel="yes" />
    <div id="{$IDMAINCONTENT}">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="$is-root">
            <xsl:value-of select="$CLASSROOTMAINCONTENT" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$CLASSMAINCONTENT" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
          <article>
            <xsl:apply-templates select="." mode="generate-breadcrumb"/>
            <xsl:choose>
              <xsl:when test="$content">
                <div id="topic-content">
                  <xsl:sequence select="$content" />
                </div>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="." mode="generate-main"/>
              </xsl:otherwise>
              </xsl:choose>
            </article>
      <div class="clear" /><xsl:sequence select="$newline"/>
    </div>
  </xsl:template>

 <!-- generate html5 footer -->
  <xsl:template match="*" mode="generate-breadcrumb">
    <xsl:param name="is-root" as="xs:boolean"  tunnel="yes" select="false()" />
    <xsl:choose>
      <xsl:when test="$is-root">
      </xsl:when>
      <xsl:otherwise>
        <nav id="content-toolbar" class="toolbar hide-for-small">
          <xsl:if test="contains($include.roles, ' next ') or contains($include.roles, ' previous ') or contains($include.roles, ' parent ')">
            <xsl:variable name="content">
              <xsl:call-template name="next-prev-parent-links"/><!--handle next and previous links-->
            </xsl:variable>
            <xsl:apply-templates select="$content"  mode="clean-linebreaks"/>
          </xsl:if>
        </nav>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

   <!-- generate html5 footer -->
  <xsl:template match="*" mode="generate-inline-breadcrumbs">
    <xsl:param name="is-root" as="xs:boolean"  tunnel="yes" select="false()" />
    <xsl:comment>generate-inline-breadcrumbs</xsl:comment>
    <xsl:choose>
      <xsl:when test="$is-root">
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="inline-breadcrumbs"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- generate html5 footer -->
  <xsl:template match="*" mode="generate-footer">
    <div class="clearfix"></div>
    <div id="footer-container" class="grid_12">
    <xsl:call-template name="gen-user-footer"/>
    <xsl:call-template name="processFTR"/>
    <xsl:sequence select="$newline"/>
  </div>
  </xsl:template>




  <!--
      flag
   -->
  <xsl:template match="*" mode="flag" />

  <xsl:template match="*[contains(@class, ' topic/data ')][@name='version']" mode="flag">
    <div id="flag-version">
      <xsl:value-of select="@value" />
    </div>
  </xsl:template>

  <!--
      template declared for extention point purpose
   -->
  <xsl:template match="*" mode="gen-user-top-head">
    <!-- to allow insertion into the head -->
  </xsl:template>

  <xsl:template match="*" mode="gen-user-bottom-head">
    <!-- to allow insertion into the head -->
  </xsl:template>

  <xsl:template match="*" mode="gen-user-body-class">
    <!-- to to append class class to the body element
         to override class use xsl:template match="*" mode="set-body-class-attr"
    -->
  </xsl:template>

  <xsl:template match="*" mode="gen-user-body-top">
    <!-- to to append class class to the body element
         to override class use xsl:template match="*" mode="set-body-class-attr"
    -->
  </xsl:template>

  <xsl:template match="*" mode="gen-user-body-bottom">
    <!-- to to append class class to the body element
         to override class use xsl:template match="*" mode="set-body-class-attr"
    -->
  </xsl:template>

</xsl:stylesheet>
