xquery version '1.0-ml';

(: 0 Params:)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $result := log:get-normalized-username(())
return test:assert-equal("admin", $result)
;

(: 1 Param :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $result := log:get-normalized-username("ThisIsATest")
return test:assert-equal("thisisatest", $result)
