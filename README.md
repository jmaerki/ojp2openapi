# ojp2openapi - OJP XML Schema conversion to OpenAPI

This repository contains code that is designed to convert the [OJP XML Schemas](https://github.com/VDVde/OJP) to OpenAPI (JSON/YAML).

This is work in progress and by no way finished or even working with any OpenAPI-compatible code generator.

## Running the conversion

### Steps

* Run XSLT transformation (currently XSLT 1.0) of XML Schema file with `xsd2openapi.xsl`. This produces JSON XML (as defined by the XPath spec).
* Run XSLT transformation (XSLT 3.0) of JSON XML to JSON with `jsonxml2json.xsl`. This produces a JSON file (OpenAPI model).
* Convert the JSON to YAML.

#### TODO

* [ ] The second step can be combined with the first. This is currently so, because the first stylesheet is a XSLT 1.0 stylesheet that cannot directly output JSON like an XSLT 3 processor can and this was done so for the author's convenience.

### Requirements

* Java 8 or later
* An XSLT 3 processor like Saxon-HE
* Python for transforming JSON to YAML (of course, you can use something different for this)

### Run on Windows

Run the batch script `xsd2openapi.bat` with an XML Schema files (*.xsd) as a single parameter. This batch script creates a directory `output` under the current directory where it will put the resulting files.

For the batch script to work, the following environment variables have to be set:

* `JAVA_HOME`: Installation directory of the Java JDK/JRE
* `SAXON_HOME`: Installation directory of Saxon
* `PYTHON_HOME`: Installation directory of Python

Example:

    xsd2openapi.bat C:\Dev\projects\OJP\OJP\OJP_Trips.xsd