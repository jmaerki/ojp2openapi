@ECHO OFF
ECHO Required Environment Variables:

REM Have Java 8 or later installed
ECHO JAVA_HOME=%JAVA_HOME%

REM Saxon-HE 10.5 needs to be installed and SAXON_HOME pointed to it
ECHO SAXON_HOME=%SAXON_HOME%

REM Have Python installed
ECHO PYTHON_HOME=%PYTHON_HOME%

ECHO Input File: %1

mkdir .\output

REM Convert the XML Schema to JSON XML (defined by the XPath spec)
%JAVA_HOME%\bin\java.exe -jar %SAXON_HOME%\saxon-he-10.5.jar -s:%1 -xsl:xsd2openapi.xsl -o:.\output\%~nx1.json.xml

REM Convert the JSON XML (defined by the XPath spec) to actual JSON (requires an XSLT 3 processor such as Saxon)
%JAVA_HOME%\bin\java.exe -jar %SAXON_HOME%\saxon-he-10.5.jar -s:.\output\%~nx1.json.xml -xsl:jsonxml2json.xsl -o:.\output\%~nx1.json

REM Make sure PyYaml is installed: "%PYTHON_HOME%\Scripts\pip3.exe" install PyYaml
"%PYTHON_HOME%\python.exe" -c "import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)" < .\output\%~nx1.json > .\output\%~nx1.yaml
