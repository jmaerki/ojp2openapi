<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions">
  
  <xsl:output method="text" json-node-output-method="text" indent="yes" media-type="text/json"/>
  
  <xsl:template match="/">
    <xsl:value-of select="fn:xml-to-json(.)"/>
  </xsl:template>

</xsl:stylesheet>
