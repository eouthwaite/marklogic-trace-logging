# MarkLogic Trace Logging

Standardises method for generating entries in the error log if traces are set in the diagnostics tab

Log entries are in JSON format, so can be extracted and analysed programatically

## To Include
To include in your project:
* add the logger.xqy module
* add the traceProject entry to your gradle.properties file

## Trace Naming

Trace names are minus delimited:
* Project name
* Logging level
* Source

It's easiest to work with the source as being the module that calls the logging function, but it could also be a logical area - eg if the project also uses the [workflow](https://github.com/marklogic-community/marklogicworkflow) library, a reasonable trace name would be MYPROJECT-DEBUG-WORKFLOW

## Activation

Trace levels may be set in the UI under the diagnostics tab, or programmatically - eg:

```
xquery version "1.0-ml";

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
import module namespace log = "https://pubs.cas.org/modules/lib/logger" at "/lib/logger.xqy";

let $config := admin:get-configuration()

return
  admin:save-configuration-without-restart(
      admin:group-add-trace-event($config,
          admin:group-get-id($config, "Default"),
          (
              admin:group-trace-event($log:PROJECT_NAME || "-INFO-PERFORMANCE"),
              admin:group-trace-event($log:PROJECT_NAME || "-NOTICE-PERFORMANCE"),
              admin:group-trace-event($log:PROJECT_NAME || "-WARNING-PERFORMANCE"),
              admin:group-trace-event($log:PROJECT_NAME || "-INFO-TEST"),
              admin:group-trace-event($log:PROJECT_NAME || "-DEBUG-TEST")
          )
      )
  )


```
 
## Main Functions

There are two main functions and several support functions.  To understand them, check the tests

### log:log
```
log:log(
    $category as xs:string,
    $what as item()*, 
    [$params as item()*], 
    [$level as xs:string]
) as empty-sequence()
```

#### Summary
Generates an entry in the error log if the trace is active or the level is "error"

#### Examples
```
log:log("workflow", "Set document lock transaction 11157462242832077241", xs:QName("pid"), "proc1234"))
=>
2024-12-06 18:02:21.341 Info: [Event:id=MYPROJECT-INFO-WORKFLOW] {"request":"11494934776271909278", "pid":"proc1234", "elapsedTime":"PT0.000508S", "category":"workflow", "what":"Set document lock transaction 11157462242832077241", "user":"admin", "userSession":null, "url":"/qconsole/endpoints/evaler.xqy?qid=14499612894913289317&dbid=2325279775051523897&sid=5935150064079605261&crid=3890970726&querytype=xquery&action=eval&elapsed-time=&lock-count=&read-size=&optimize=1&trace=&cache=1733508141056", "transaction":"11157462242832077241"}

...JSON:
{
    "request":"11494934776271909278", 
    "pid":"proc1234", 
    "elapsedTime":"PT0.000508S", 
    "category":"workflow", 
    "what":"Set document lock transaction 11157462242832077241", 
    "user":"admin", 
    "userSession":null, 
    "url":"/qconsole/endpoints/evaler.xqy?qid=14499612894913289317&dbid=2325279775051523897&sid=5935150064079605261&crid=3890970726&querytype=xquery&action=eval&elapsed-time=&lock-count=&read-size=&optimize=1&trace=&cache=1733508141056", 
    "transaction":"11157462242832077241"
}
```

Error example
```
log:log("workflow", "ERR1234: this is an error message", (), "error")
=>
2024-12-06 18:20:45.990 Error: {"error":"ERR1234: this is an error message", "request":"5164605295909972425", "elapsedTime":"PT0.000039S", "user":"admin", "userSession":null, "level":"error", "url":"/qconsole/endpoints/evaler.xqy?qid=14499612894913289317&dbid=2325279775051523897&sid=5935150064079605261&crid=2905121503&querytype=xquery&action=eval&elapsed-time=&lock-count=&read-size=&optimize=1&trace=&cache=1733509245981", "transaction":"6789313970401883230"}

...JSON:

{
    "error":"ERR1234: this is an error message",
    "request":"5164605295909972425", 
    "elapsedTime":"PT0.000039S", 
    "user":"admin", 
    "userSession":null, 
    "level":"error", 
    "url":"/qconsole/endpoints/evaler.xqy?qid=14499612894913289317&dbid=2325279775051523897&sid=5935150064079605261&crid=2905121503&querytype=xquery&action=eval&elapsed-time=&lock-count=&read-size=&optimize=1&trace=&cache=1733509245981", 
    "transaction":"6789313970401883230"
}
```

### log:performance
```
log:performance(
    $start as xs:dayTimeDuration, 
    $end as xs:dayTimeDuration
) as empty-sequence()
```
#### Summary
Generates an entry in the error log if the trace is active or if the task duration was over 1 minute

Logging level depends on time threshold, so performance may only be logged if thresholds are breached:

| log level | duration                  |
|-----------|---------------------------|
| info      | 1 second or less          | 
| notice    | &gt; 1s and &le; 10s      | 
| warning   | &gt; 10s and &le; 1 minute | 
| error     | &gt; 1 minute             | 


#### Examples
```
log:performance(xs:dayTimeDuration("PT1S"),xs:dayTimeDuration("PT2S"))
=>
2025-01-14 21:24:32.053 Info: [Event:id=MYPROJECT-INFO-PERFORMANCE] {"request":"14833756270583002978", "duration":"PT1S", "elapsedTime":"PT0.000076S", "category":"performance", "user":"admin", "userSession":null, "url":"/test/default.xqy?func=run&suite=lib_logger&tests=performance.xqy&runsuiteteardown=true&runteardown=true&calculatecoverage=false&_=1736889871035", "transaction":"3335754709740991478"}
```
