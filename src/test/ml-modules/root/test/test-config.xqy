xquery version "1.0-ml";

module namespace tc = "http://marklogic.com/test-config";

(: configured at deploy time by ml-gradle :)
declare variable $tc:RESTPORT := "%%mlTestRestPort%%";

