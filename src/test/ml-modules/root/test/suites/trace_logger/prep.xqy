xquery version '1.0-ml';

import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

(: log:prep($category as xs:string?, $what as item()*, $params as item()*, $level as xs:string?) :)
let $category := "test"
let $what := ("test message")
let $params := (xs:QName("pid"), "12345")
let $level := "info"

let $prep := log:prep($category, $what, $params, $level)

return (
  test:assert-exists(map:get($prep,"elapsedTime")),
  test:assert-exists(map:get($prep,"request")),
  test:assert-exists(map:get($prep,"transaction")), (:
  test:assert-exists(map:get($prep,"userSession")), - fails for map:value xsi:nil="true" :)
  test:assert-equal("test", map:get($prep,"category")),
  test:assert-equal("info", map:get($prep,"level")),
  test:assert-equal("12345", map:get($prep,"pid")), (:
  test:assert-equal("/v1/resources/facets", map:get($prep,"url")), :)
  test:assert-equal("admin", map:get($prep,"user")),
  test:assert-equal("test message", map:get($prep,"what"))
)
;
