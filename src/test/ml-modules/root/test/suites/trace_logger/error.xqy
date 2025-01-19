xquery version '1.0-ml';

(: 1 Param :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $error := (: example error captured by throw/catch :)
<error:error xsi:schemaLocation="http://marklogic.com/xdmp/error error.xsd" xmlns:error="http://marklogic.com/xdmp/error" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <error:code>XDMP-DIVBYZERO</error:code>
    <error:name>err:FOAR0001</error:name>
    <error:xquery-version>1.0-ml</error:xquery-version>
    <error:message>Division by zero</error:message>
    <error:format-string>XDMP-DIVBYZERO: (err:FOAR0001) 5 div 0 -- Division by zero</error:format-string>
    <error:retryable>false</error:retryable>
    <error:expr>5 div 0</error:expr>
    <error:data/>
    <error:stack>
        <error:frame>
            <error:uri>/test/suites/UnitTestTests/assert-throws-error.xqy</error:uri>
            <error:line>15</error:line>
            <error:column>4</error:column>
            <error:operation>xdmp:function(xs:QName("local:case3"))()</error:operation>
            <error:xquery-version>1.0-ml</error:xquery-version>
        </error:frame>
    </error:stack>
</error:error>

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:error($error)
        },
        <options xmlns="xdmp:eval">
            <isolation>different-transaction</isolation>
        </options>
    )
let $_sleep := xdmp:sleep(1000) (: Give MarkLogic a chance to write the log :)
let $end := fn:current-dateTime() + xs:dayTimeDuration('PT2S')

let $log-entries :=
    xdmp:logfile-scan(
        "/var/opt/MarkLogic/Logs/" || $tc:RESTPORT || "_ErrorLog.txt",
        "Error:", (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, 32)
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal(xdmp:quote($error), xs:string($json-response/error)),
        test:assert-equal("error", xs:string($json-response/level)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 2 Params :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $error := (: example error captured by throw/catch :)
<error:error xsi:schemaLocation="http://marklogic.com/xdmp/error error.xsd" xmlns:error="http://marklogic.com/xdmp/error" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <error:code>XDMP-DIVBYZERO</error:code>
    <error:name>err:FOAR0001</error:name>
    <error:xquery-version>1.0-ml</error:xquery-version>
    <error:message>Division by zero</error:message>
    <error:format-string>XDMP-DIVBYZERO: (err:FOAR0001) 5 div 0 -- Division by zero</error:format-string>
    <error:retryable>false</error:retryable>
    <error:expr>5 div 0</error:expr>
    <error:data/>
    <error:stack>
        <error:frame>
            <error:uri>/test/suites/UnitTestTests/assert-throws-error.xqy</error:uri>
            <error:line>15</error:line>
            <error:column>4</error:column>
            <error:operation>xdmp:function(xs:QName("local:case3"))()</error:operation>
            <error:xquery-version>1.0-ml</error:xquery-version>
        </error:frame>
    </error:stack>
</error:error>
let $params := (xs:QName("pid"), "999")

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:error($error, $params)
        },
        <options xmlns="xdmp:eval">
            <isolation>different-transaction</isolation>
        </options>
    )
let $_sleep := xdmp:sleep(1000) (: Give MarkLogic a chance to write the log :)
let $end := fn:current-dateTime() + xs:dayTimeDuration('PT2S')

let $log-entries :=
    xdmp:logfile-scan(
        "/var/opt/MarkLogic/Logs/" || $tc:RESTPORT || "_ErrorLog.txt",
        "Error:", (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, 32)
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal(xdmp:quote($error), xs:string($json-response/error)),
        test:assert-equal("999", xs:string($json-response/pid)),
        test:assert-equal("error", xs:string($json-response/level)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);
