<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on
     Sourceforge.net. See the accompanying license.txt file for
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. -->

<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:index-terms="http://dita4publishers.org/index-terms"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:mapdriven="http://dita4publishers.org/mapdriven"
  xmlns:htmlutil="http://dita4publishers.org/functions/htmlutil"
  xmlns:java="org.dita.dost.util.ImgUtils"
  xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
  xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
  exclude-result-prefixes="xs xd df relpath mapdriven index-terms java xsl mapdriven related-links ditamsg">



  <xsl:template name="inline-breadcrumbs">
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>

    <xsl:variable name="ancestorsTopicRef" select="if ($topicref)
             then ($topicref/ancestor::*[df:isTopicRef(.)])
             else ()"
    />

    <xsl:if test="$ancestorsTopicRef">
      <xsl:for-each select="$ancestorsTopicRef[not(@scope = ('peer', 'external'))]">
        <xsl:variable name="topic" as="element()*" select="df:resolveTopicRef(.)" />
        <xsl:choose>
          <xsl:when test="$topic">
            <xsl:variable name="resultUri" as="xs:string" 
              select="concat($relativePath, 
                   relpath:getRelativePath($outdir, 
                       htmlutil:getTopicResultUrl2($outdir, root($topic), ., $rootMapDocUrl)))" />
            <xsl:variable name="title">
              <xsl:apply-templates select="." mode="nav-point-title"/>
            </xsl:variable>
    
            <xsl:call-template name="breadcrumbs-format-links">
              <xsl:with-param name="title" as="xs:string" select="$title"/>
              <xsl:with-param name="href" as="xs:string" select="$resultUri"/>
            </xsl:call-template>
    
            <xsl:value-of select="$newline"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message> - [WARN] inline-breadcrumbs: Unable to resolve topicref for topicref <xsl:value-of select="df:reportTopicref(.)"/></xsl:message>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:for-each>
    </xsl:if>
  </xsl:template>

   <xsl:template name="breadcrumbs-format-links">
    <xsl:param name="title" as="xs:string" />
    <xsl:param name="href" as="xs:string" />
     <a class="breadcrumb" href="{$href}" title="{$title}">
         <xsl:value-of select="$title" />
     </a>
  </xsl:template>




<xsl:template name="compas">

  <xsl:param name="direction" select="''" />

  <xsl:variable name="icon">
    <xsl:choose>
      <xsl:when test="$direction = 'parent'">
        <xsl:value-of select="$CLASSICONPARENT" />
      </xsl:when>
      <xsl:when test="$direction = 'next'">
        <xsl:value-of select="$CLASSICONRIGHT" />
      </xsl:when>
      <xsl:when test="$direction = 'previous'">
        <xsl:value-of select="$CLASSICONLEFT" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="href">
    <xsl:call-template name="href" />
  </xsl:variable>

  <div class="{concat($direction, 'link')}">
    <a href="{$href}" title="{linktext}">
        <span class="{$icon}"></span><span class="{$CLASSSCREENREADER}"><xsl:value-of select="linktext" /></span>
    </a>
  </div>
  <xsl:value-of select="$newline"/>
</xsl:template>


<xsl:template name="getNextTopicReference">
  <xsl:param name="topicref" as="element()*" tunnel="yes"/>
  <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
  <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>
  
  <xsl:variable name="siblingTopicRef" select="if ($topicref)
             then ($topicref/child::*[df:isNavigationTopicref(.)][1] |
                   $topicref/following::*[df:isNavigationTopicref(.)][1])[1]
             else ()" as="element()?"
  />

  <xsl:if test="$siblingTopicRef">

    <xsl:variable name="topic" as="element()*" select="df:resolveTopicRef($siblingTopicRef)" />
   <xsl:choose>
     <xsl:when test="not($topic)">
       <xsl:message> + [WARN] getNextTopicReference(): Failed to resolve topicref to a topic: <xsl:value-of select="df:reportTopicref($topicref)"/></xsl:message>
     </xsl:when>
     <xsl:otherwise>
        <xsl:variable name="resultUri" as="xs:string">
        <!-- NOTE: This logic is different from the logic for the previous
                         link. I'm not sure that's right. There may be a more
                         general way to hanlde this logic based on general properties
                         of the topicrefs involved, e.g., @toc="no" or chunking or
                         something.
        -->

          <xsl:value-of
            select="relpath:newFile($relativePath,
                           relpath:getRelativePath($outdir,
                             htmlutil:getTopicResultUrl2($outdir, root($topic), $siblingTopicRef, $rootMapDocUrl)))"
          />
        </xsl:variable>

        <xsl:variable name="title">
          <xsl:apply-templates select="$siblingTopicRef" mode="nav-point-title"/>
        </xsl:variable>

        <xsl:call-template name="formatSiblingTopicLinks">
          <xsl:with-param name="href" as="xs:string" select="$resultUri"/>
          <xsl:with-param name="role" as="xs:string" select="'next'"/>
          <xsl:with-param name="title" as="xs:string" select="$title"/>
        </xsl:call-template>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
  </xsl:template>


  <xsl:template name="getNextTopicHref">
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="firstTopicUri" as="xs:string?" tunnel="yes"/>

    <xsl:choose>
      <xsl:when test="$firstTopicUri != ''">
        <xsl:value-of select="$firstTopicUri"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="siblingTopicRef" select="if ($topicref)
            then ($topicref/child::*[df:isNavigationTopicref(.)][1] | 
                  $topicref/following::*[df:isNavigationTopicref(.)][1])[1]
            else ()" as="element()?"
        />

        <xsl:if test="$siblingTopicRef">

          <xsl:variable name="topic" as="element()*" select="df:resolveTopicRef($siblingTopicRef)" />

          <xsl:if test="$topic">
            <xsl:variable name="resultUri" as="xs:string">
            <!-- NOTE: This logic is different from the logic for the previous
                     link. I'm not sure that's right. There may be a more
                     general way to hanlde this logic based on general properties
                     of the topicrefs involved, e.g., @toc="no" or chunking or
                     something.
            -->

              <xsl:value-of 
                select="htmlutil:getTopicResultUrl2($outdir, root($topic), $siblingTopicRef, $rootMapDocUrl)" 
              />
            </xsl:variable>
            <xsl:value-of select="relpath:getRelativePath($outdir, $resultUri)" />
          </xsl:if>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template name="getPrevTopicReference">
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>
    <xsl:variable name="siblingTopicRef" select="
          if ($topicref)
             then ($topicref/preceding::*[df:isNavigationTopicref(.)][1] | 
                   $topicref/ancestor::*[df:isNavigationTopicref(.)][1])[last()]
             else ()" as="element()?"
    />

  <xsl:if test="$siblingTopicRef">

    <xsl:variable name="topic" as="element()*" select="df:resolveTopicRef($siblingTopicRef)" />

    <xsl:if test="$topic">
      <xsl:variable name="resultUri" as="xs:string?">
      <!-- NOTE: This logic is different from the logic for the previous
                       link. I'm not sure that's right. There may be a more
                       general way to hanlde this logic based on general properties
                       of the topicrefs involved, e.g., @toc="no" or chunking or
                       something.
      -->

        <xsl:value-of select="concat($relativePath, relpath:getRelativePath($outdir,
          htmlutil:getTopicResultUrl2($outdir, root($topic), $siblingTopicRef, $rootMapDocUrl)))" />
      </xsl:variable>

      <xsl:variable name="title">
        <xsl:apply-templates select="$siblingTopicRef" mode="nav-point-title"/>
      </xsl:variable>

      <xsl:if test="$resultUri != ''">
        <xsl:call-template name="formatSiblingTopicLinks">
          <xsl:with-param name="href" as="xs:string" select="$resultUri"/>
          <xsl:with-param name="role" as="xs:string" select="'previous'"/>
          <xsl:with-param name="title" as="xs:string" select="$title"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:if>
  </xsl:template>

  <xsl:template name="getPrevTopicHref">
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:variable name="siblingTopicRef" select="
          if ($topicref)
             then ($topicref/preceding::*[df:isNavigationTopicref(.)][1] |
                   $topicref/ancestor::*[df:isNavigationTopicref(.)][1])[last()]
             else ()" as="element()?"
    />

  <xsl:if test="$siblingTopicRef">

    <xsl:variable name="topic" as="element()*" select="df:resolveTopicRef($siblingTopicRef)" />

    <xsl:if test="$topic">
      <xsl:variable name="resultUri" as="xs:string">
      <!-- NOTE: This logic is different from the logic for the previous
                     link. I'm not sure that's right. There may be a more
                     general way to hanlde this logic based on general properties
                     of the topicrefs involved, e.g., @toc="no" or chunking or
                     something.
      -->

        <xsl:value-of 
          select="relpath:getRelativePath($outdir, 
          htmlutil:getTopicResultUrl2($outdir, root($topic), $siblingTopicRef, $rootMapDocUrl))" />
      </xsl:variable>

      <xsl:variable name="title">
        <xsl:apply-templates select="$siblingTopicRef" mode="nav-point-title"/>
      </xsl:variable>

     <xsl:value-of select="$resultUri"/>
   </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="formatSiblingTopicLinks">
    <xsl:param name="href" as="xs:string"/>
    <xsl:param name="role" as="xs:string"/>
    <xsl:param name="title" as="xs:string"/>
    <a href="{$href}" class="{$role}" rel="internal"><xsl:value-of select="$title"/></a>
  </xsl:template>
  
  <!-- Return true if the topicref is a normal-role reference to a chunk-root topic -->
  <xsl:function name="df:isNavigationTopicref" as="xs:boolean">
    <xsl:param name="context" as="element()"/>
    <xsl:variable name="result" as="xs:boolean"
      select="df:isTopicRef($context) and 
                     not($context/ancestor::*[contains(@chunk, 'to-content')]) and 
                     not($context/@processing-role = 'resource-only')"
    />
    <xsl:sequence select="$result"></xsl:sequence>
  </xsl:function>

 </xsl:stylesheet>
