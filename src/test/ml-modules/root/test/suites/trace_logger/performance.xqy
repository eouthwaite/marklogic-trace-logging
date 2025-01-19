xquery version '1.0-ml';

(: 1 second :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
  xdmp:invoke-function(
    function(){
      log:performance(xs:dayTimeDuration('PT1S'), xs:dayTimeDuration('PT2S'))
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
        $log:PROJECT_NAME || "-INFO-PERFORMANCE", (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, (fn:string-length($log:PROJECT_NAME)+60))
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal("PT1S", xs:string($json-response/duration)),
        test:assert-equal("performance", xs:string($json-response/category)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 9 seconds :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
  xdmp:invoke-function(
    function(){
      log:performance(xs:dayTimeDuration('PT1S'), xs:dayTimeDuration('PT10S'))
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
        $log:PROJECT_NAME || "-NOTICE-PERFORMANCE", (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, (fn:string-length($log:PROJECT_NAME)+62))
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal("PT9S", xs:string($json-response/duration)),
        test:assert-equal("performance", xs:string($json-response/category)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 19 seconds :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
  xdmp:invoke-function(
    function(){
      log:performance(xs:dayTimeDuration('PT1S'), xs:dayTimeDuration('PT20S'))
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
        $log:PROJECT_NAME || "-WARNING-PERFORMANCE", (), $start, $end, 10
    )
return (
    test:assert-equal(1, fn:count($log-entries)),

    let $payload := fn:substring($log-entries, (fn:string-length($log:PROJECT_NAME)+63))
    let $json-response := xdmp:to-json(xdmp:unquote($payload))
    return (
        test:assert-equal("PT19S", xs:string($json-response/duration)),
        test:assert-equal("performance", xs:string($json-response/category)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 1 minute 1 second :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
  xdmp:invoke-function(
    function(){
      log:performance(xs:dayTimeDuration('PT1S'), xs:dayTimeDuration('PT1M2S'))
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
        test:assert-equal("<error>Request took way too long</error>", xs:string($json-response/error)),
        test:assert-equal("PT1M1S", xs:string($json-response/duration)),
        test:assert-equal("error", xs:string($json-response/level)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

(: 2 minutes 1 second :)
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";
import module namespace tc ="http://marklogic.com/test-config" at "/test/test-config.xqy";
import module namespace test = 'http://marklogic.com/test' at '/test/test-helper.xqy';

let $start := fn:current-dateTime() - xs:dayTimeDuration('PT1S')
let $_log-it :=
  xdmp:invoke-function(
    function(){
      log:performance(xs:dayTimeDuration('PT1S'), xs:dayTimeDuration('PT2M2S'))
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
        test:assert-equal("<error>Request took way too long</error>", xs:string($json-response/error)),
        test:assert-equal("PT2M1S", xs:string($json-response/duration)),
        test:assert-equal("error", xs:string($json-response/level)),
        test:assert-equal("admin", xs:string($json-response/user))
    )
);

