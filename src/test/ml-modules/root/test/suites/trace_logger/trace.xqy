xquery version '1.0-ml';

(: 4 Params - no active trace :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $trace := $log:PROJECT_NAME || "-DOESNOTEXIST-TEST"
let $category := "test"
let $what := ("this should not appear in the logs")
let $params := (xs:QName("pid"), "00000")

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:trace($trace, $category, $what, $params)
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
        $log:PROJECT_NAME || "-DOESNOTEXIST-TEST", (), $start, $end, 10
    )
return (
    test:assert-equal(0, fn:count($log-entries))
);

(: 4 Params - active trace :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $trace := $log:PROJECT_NAME || "-DEBUG-TEST"
let $category := "test"
let $what := ("this should appear in the logs")
let $params := (xs:QName("pid"), "11111")

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:trace($trace, $category, $what, $params)
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
        $trace, (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, (fn:string-length($trace)+43))
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal($what, xs:string($json-response/what)),
        test:assert-equal("11111", xs:string($json-response/pid)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 5 Params - no active trace :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $trace := $log:PROJECT_NAME || "-DOESNOTEXIST-TEST"
let $category := "test"
let $what := ("this should not appear in the logs")
let $params := (xs:QName("pid"), "22222")
let $level := "debug"

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:trace($trace, $category, $what, $params, $level)
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
        $trace, (), $start, $end, 10
    )
return (
    test:assert-equal(0, fn:count($log-entries))
);

(: 5 Params - active trace :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $trace := $log:PROJECT_NAME || "-DEBUG-TEST"
let $category := "test"
let $what := ("this should appear in the logs")
let $params := (xs:QName("pid"), "33333")
let $level := "debug"

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
    xdmp:invoke-function(
        function(){
            log:trace($trace, $category, $what, $params, $level)
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
        $trace, (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, (fn:string-length($trace)+43))
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal($what, xs:string($json-response/what)),
        test:assert-equal("33333", xs:string($json-response/pid)),
        test:assert-equal($level, xs:string($json-response/level)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

