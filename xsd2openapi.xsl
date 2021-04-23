<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:siri="http://www.siri.org.uk/siri"
  xmlns:ojp="http://www.vdv.de/ojp"
  xmlns:rest="http://www.vdv.de/ojp/restsupport"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="xs siri ojp">

  <xsl:variable name="hints" select="document('ojp-openapi-hints.xml')/ojp-openapi-hints"/>

  <xsl:template match="xs:schema">
    <map>
      <xsl:apply-templates/>
    </map>
  </xsl:template>
  
  <xsl:template match="xs:complexType[@name]">
    <xsl:variable name="path">
      <xsl:call-template name="path"/>
    </xsl:variable>
    <xsl:call-template name="output-context"/>
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="string-length(substring-before(@name, 'Structure')) &gt; 0">
          <xsl:value-of select="substring-before(@name, 'Structure')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="($hints/complexType[@path=$path]/@name|@name)[1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <map key="{$name}">
      <string key="type">object</string>
      <xsl:apply-templates select="xs:annotation"/>
      <array key="required">
        <xsl:apply-templates select="*[not(self::xs:annotation)]" mode="required"/>
      </array>
      <map key="properties">
        <xsl:apply-templates select="*[not(self::xs:annotation)]"/>
      </map>
    </map>
  </xsl:template>
  
  <xsl:template match="xs:sequence">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="xs:choice">
    <xsl:variable name="path">
      <xsl:call-template name="path"/>
    </xsl:variable>
    <xsl:variable name="name" select="$hints/choice[@path=$path]/@name"/>
    <map key="{$name}">
      <string key="type">array</string>
      <xsl:apply-templates select="xs:annotation"/>
      <map key="items">
        <array key="oneOf">
          <xsl:apply-templates select="*[not(self::xs:annotation)]"/>
        </array>
      </map>
    </map>
  </xsl:template>

  <xsl:template match="xs:choice/xs:element" priority="10">
    <map>
      <string key="@ref">
        <xsl:text>#/components/schemas/</xsl:text>
        <xsl:choose>
          <xsl:when test="@name">
            <xsl:value-of select="@name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>TODO: Element Ref resolution: <xsl:call-template name="output-context"/></xsl:message>
            <xsl:comment>TODO: Element Ref resolution: <xsl:call-template name="output-context"/></xsl:comment>
          </xsl:otherwise>
        </xsl:choose>
      </string>
    </map>
  </xsl:template>

<!--
  <xsl:template match="xs:choice[foo='bar']">
    <xsl:message>xs:choice with no rest:choice-key hint!</xsl:message>
    <map key="choice">
      <xsl:call-template name="choice"/>
    </map>
  </xsl:template>
  
  <xsl:template name="choice">
  </xsl:template>
  -->
    
  <xsl:template match="xs:element[@name and @type]">
    <map key="{@name}">
      <xsl:apply-templates select="*[not(self::xs:annotation)]"/>
      <string key="@ref">
        <xsl:text>#/components/schemas/</xsl:text>
        <xsl:value-of select="@type"/>
      </string>
    </map>
  </xsl:template>

  <xsl:template match="xs:element[@name and not(@type)]">
    <map key="{@name}">
      <xsl:apply-templates select="*[not(self::xs:annotation)]"/>
    </map>
  </xsl:template>
  
  <xsl:template match="xs:element[@type = 'xs:anyType']">
    <map key="{@name}">
      <xsl:apply-templates select="*[not(self::xs:annotation)]"/>
      <string key="type">object</string>
      <boolean key="additionalProperties">true</boolean>
    </map>
  </xsl:template>

  <!-- ==================================================================================== required -->
  
  <xsl:template match="xs:sequence" mode="required">
    <xsl:apply-templates mode="required"/>
  </xsl:template>
  
  <xsl:template match="xs:element" mode="required">
    <xsl:if test="not(@minOccurs) or number(@minOccurs) &gt;= 1">
      <string><xsl:value-of select="@name"/></string>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="xs:choice" mode="required">
    <xsl:if test="not(@minOccurs) or number(@minOccurs) &gt;= 1">
      <xsl:variable name="path">
        <xsl:call-template name="path"/>
      </xsl:variable>
      <xsl:variable name="name" select="$hints/choice[@path=$path]/@name"/>
      <string><xsl:value-of select="$name"/></string>
    </xsl:if>
  </xsl:template>
  
  <!-- ==================================================================================== Simple Types -->
  
  <xsl:template match="xs:simpleType">
    <map key="{@name}">
      <xsl:apply-templates select="xs:annotation"/>
      <xsl:choose>
        <xsl:when test="xs:restriction/@base = 'xs:string'">
          <string key="type">string</string>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>xs:simpleType <xsl:value-of select="@name"/> with unimplemented base type!</xsl:message>
          <xsl:comment>xs:simpleType <xsl:value-of select="@name"/> with unimplemented base type!</xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
      <array key="enum">
        <xsl:for-each select="xs:restriction/xs:enumeration">
          <string><xsl:value-of select="@value"/></string>
        </xsl:for-each>
      </array>
    </map>
  </xsl:template>

  <!-- ==================================================================================== Documentation -->
  
  <xsl:template match="xs:schema/xs:annotation">
    <!-- ignore schema-level annotations -->
  </xsl:template>

  <xsl:template match="xs:annotation">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="xs:documentation">
    <string key="description">
      <xsl:value-of select="."/>
    </string>
  </xsl:template>
  
  <!-- ==================================================================================== Warnings -->
  
  <xsl:template match="*">
    <xsl:message>Element <xsl:value-of select="name()"/> not implemented.</xsl:message>
   </xsl:template>

  <!-- ==================================================================================== Helpers -->
  
  <xsl:template name="path">
    <xsl:for-each select="ancestor-or-self::*[@name]">/<xsl:value-of select="@name"/></xsl:for-each>
  </xsl:template>
  
  <xsl:template name="output-context">
    <xsl:message><xsl:call-template name="path"/></xsl:message>
  </xsl:template>

</xsl:stylesheet>
