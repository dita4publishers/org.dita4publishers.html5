<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on
     Sourceforge.net. See the accompanying license.txt file for
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. -->

<xsl:stylesheet version="1.0"
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

  <xsl:template name="inline-breadcrumbs">

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

      <xsl:for-each select="*[@href][@role='parent']">
        <xsl:variable name="href">
          <xsl:call-template name="href" />
        </xsl:variable>

        <xsl:call-template name="breadcrumbs-format-links">
          <xsl:with-param name="title" as="xs:string" select="linktext"/>
          <xsl:with-param name="href" as="xs:string" select="$href"/>
        </xsl:call-template>
 
      <xsl:value-of select="$newline"/>
    </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

   <xsl:template name="breadcrumbs-format-links">
    <xsl:param name="title" as="xs:string" />
    <xsl:param name="href" as="xs:string" />
     <a class="breadcrumb" href="{$href}" title="{$title}">
         <xsl:value-of select="$title" />
     </a>
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
             then ($topicref/child::*[df:isTopicRef(.)][1] | $topicref/following::*[df:isTopicRef(.)][1])[1] 
             else ()" as="element()?"
  />    

  <xsl:if test="$siblingTopicRef">

    <xsl:variable name="topic" as="element()*" select="df:resolveTopicRef($siblingTopicRef)" />
    <xsl:variable name="resultUri" as="xs:string">
    <!-- NOTE: This logic is different from the logic for the previous 
                     link. I'm not sure that's right. There may be a more
                     general way to hanlde this logic based on general properties
                     of the topicrefs involved, e.g., @toc="no" or chunking or
                     something.
    -->

      <xsl:value-of select="concat($relativePath, relpath:getRelativePath($outdir, htmlutil:getTopicResultUrl($outdir, root($topic), $rootMapDocUrl)))" />
    </xsl:variable>

    <xsl:variable name="title">
      <xsl:apply-templates select="$siblingTopicRef" mode="nav-point-title"/>
    </xsl:variable>

    <xsl:call-template name="formatSiblingTopicLinks">
      <xsl:with-param name="href" as="xs:string" select="$resultUri"/>
      <xsl:with-param name="role" as="xs:string" select="'next'"/>
      <xsl:with-param name="title" as="xs:string" select="$title"/>
    </xsl:call-template>
  </xsl:if>
  </xsl:template>


<xsl:template name="getNextTopicHref">
  <xsl:param name="topicref" as="element()*" tunnel="yes"/>
  <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

  <xsl:variable name="siblingTopicRef" select="if ($topicref) 
             then ($topicref/child::*[df:isTopicRef(.)][1] | $topicref/following::*[df:isTopicRef(.)][1])[1] 
             else ()" as="element()?"
  />    

  <xsl:if test="$siblingTopicRef">

    <xsl:variable name="topic" as="element()*" select="df:resolveTopicRef($siblingTopicRef)" />
    <xsl:variable name="resultUri" as="xs:string">
    <!-- NOTE: This logic is different from the logic for the previous 
                     link. I'm not sure that's right. There may be a more
                     general way to hanlde this logic based on general properties
                     of the topicrefs involved, e.g., @toc="no" or chunking or
                     something.
    -->

      <xsl:value-of select="htmlutil:getTopicResultUrl($outdir, root($topic), $rootMapDocUrl)" />
    </xsl:variable>

    <xsl:value-of select="relpath:getRelativePath($outdir, $resultUri)" />

  </xsl:if>
  </xsl:template>

  <xsl:template name="getPrevTopicReference">
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>
    <xsl:param name="relativePath" as="xs:string" select="''" tunnel="yes"/>
    <xsl:variable name="siblingTopicRef" select="
          if ($topicref) 
             then ($topicref/preceding::*[df:isTopicRef(.)][1] | $topicref/ancestor::*[df:isTopicRef(.)][1])[last()]  
             else ()" as="element()?"
    />    

  <xsl:if test="$siblingTopicRef">

    <xsl:variable name="topic" as="element()*" select="df:resolveTopicRef($siblingTopicRef)" />
    <xsl:variable name="resultUri" as="xs:string">
    <!-- NOTE: This logic is different from the logic for the previous 
                     link. I'm not sure that's right. There may be a more
                     general way to hanlde this logic based on general properties
                     of the topicrefs involved, e.g., @toc="no" or chunking or
                     something.
    -->

      <xsl:value-of select="concat($relativePath, relpath:getRelativePath($outdir, htmlutil:getTopicResultUrl($outdir, root($topic), $rootMapDocUrl)))" />
    </xsl:variable>

    <xsl:variable name="title">
      <xsl:apply-templates select="$siblingTopicRef" mode="nav-point-title"/>
    </xsl:variable>

    <xsl:call-template name="formatSiblingTopicLinks">
      <xsl:with-param name="href" as="xs:string" select="$resultUri"/>
      <xsl:with-param name="role" as="xs:string" select="'previous'"/>
      <xsl:with-param name="title" as="xs:string" select="$title"/>
    </xsl:call-template>
  </xsl:if>
  </xsl:template>

  <xsl:template name="getPrevTopicHref">
    <xsl:param name="topicref" as="element()*" tunnel="yes"/>
    <xsl:param name="rootMapDocUrl" as="xs:string" tunnel="yes"/>

    <xsl:variable name="siblingTopicRef" select="
          if ($topicref) 
             then ($topicref/preceding::*[df:isTopicRef(.)][1] | $topicref/ancestor::*[df:isTopicRef(.)][1])[last()]  
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

        <xsl:value-of select="relpath:getRelativePath($outdir, htmlutil:getTopicResultUrl($outdir, root($topic), $rootMapDocUrl))" />
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

 </xsl:stylesheet>
