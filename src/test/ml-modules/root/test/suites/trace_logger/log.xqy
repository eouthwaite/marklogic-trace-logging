xquery version '1.0-ml';

(: 2 Params:)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $category := "test"
let $what := ("test", "message")

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:log($category, $what)
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
        $log:PROJECT_NAME || "-INFO-TEST", (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, (fn:string-length($log:PROJECT_NAME)+53))
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal("test", xs:string($json-response/what[1])),
        test:assert-equal("message", xs:string($json-response/what[2])),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 3 Params :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $category := "test"
let $what := ("test message")
let $params := (xs:QName("pid"), "12345")

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:log($category, $what, $params)
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
        $log:PROJECT_NAME || "-INFO-TEST", (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, (fn:string-length($log:PROJECT_NAME)+53))
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal($what, xs:string($json-response/what)),
        test:assert-equal("12345", xs:string($json-response/pid)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 4 Params - log :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $category := "test"
let $what := ("test message")
let $params := (xs:QName("pid"), "67890")
let $level := "debug" (: Trace will be MYPROJECT-DEBUG-TEST this time, not MYPROJECT-INFO-TEST :)

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:log($category, $what, $params, $level)
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
        $log:PROJECT_NAME || "-DEBUG-TEST", (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, (fn:string-length($log:PROJECT_NAME)+54))
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal($what, xs:string($json-response/what)),
        test:assert-equal("67890", xs:string($json-response/pid)),
        test:assert-equal($level, xs:string($json-response/level)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 4 Params - error :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $category := "test"
let $what := ("test message")
let $params := (xs:QName("pid"), "999")
let $level := "error" (: no trace, should trigger error message :)

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:log($category, $what, $params, $level)
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
        test:assert-equal("<error>test message</error>", xs:string($json-response/error)),
        test:assert-equal("999", xs:string($json-response/pid)),
        test:assert-equal($level, xs:string($json-response/level)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

