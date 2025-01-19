xquery version "1.0-ml";

module namespace log = "https://pubs.cas.org/modules/lib/logger";

declare namespace xdmp = "http://marklogic.com/xdmp";
declare namespace map = "http://marklogic.com/xdmp/map";

declare variable $log:PROJECT_NAME := "%%traceProject%%";

declare function log:normalize-username($username as xs:string) as xs:string {
    fn:lower-case($username)
};

declare function log:get-normalized-username() as xs:string {
    log:get-normalized-username(())
};

declare function log:get-normalized-username($user as xs:string?) as xs:string {
    let $username := if($user) then $user else xdmp:get-current-user()
    return
    log:normalize-username($username)
};


declare function log:log($category as xs:string, $what as item()*) as empty-sequence() {
    log:log($category, $what, (), "info")
};

declare function log:log($category as xs:string, $what as item()*, $params as item()*) as empty-sequence() {
    log:log($category, $what, $params, "info")
};

declare function log:log($category as xs:string, $what as item()*, $params as item()*, $level as xs:string) as empty-sequence() {
    let $trace := $log:PROJECT_NAME || "-" || fn:upper-case($level) || '-' ||fn:upper-case($category)
    return
        if($level = 'error')
        then log:error(<error>{$what}</error>, $params)
        else log:trace($trace, $category, $what, $params, $level)
};

declare function log:error($error as item()*) {
    log:error($error, ())
};

declare function log:error($error as item()*, $params as item()*) {
  let $message := log:prep((), (), (xs:QName("error"), xdmp:quote($error), $params), "error")
  return xdmp:log($message, "error")
};

declare function log:trace($trace as xs:string, $category as xs:string?, $what as item()*, $params as item()*) {
    log:trace($trace, $category, $what, $params, ())
};

declare function log:trace($trace as xs:string, $category as xs:string?, $what as item()*, $params as item()*, $level as xs:string?) {
    if (xdmp:trace-enabled($trace))
    then
       xdmp:trace($trace, log:prep($category, $what, $params, $level))
    else ()
};
                                                  (:function :)
declare function log:prep($category as xs:string?, $what as item()*, $params as item()*, $level as xs:string?) {
    let $message := map:new((
            map:entry("request", xdmp:request()),
            map:entry("transaction", xdmp:transaction()),
            map:entry("userSession", xdmp:get-request-header("jSessionId")),
            map:entry("url", xdmp:get-original-url()),
            map:entry("user", log:get-normalized-username()),
            map:entry("elapsedTime", xdmp:elapsed-time())
    ))

    let $_ := if(fn:exists($category)) then map:put($message, "category", $category) else ()
    let $_ := if(fn:exists($what))     then map:put($message, "what", $what) else ()
    let $_ := if(fn:exists($level))    then map:put($message, "level", $level) else ()

    let $_ :=
        for $p at $i in $params
          let $t1 := xs:string(xdmp:type($p))
          let $t2 := if($i = fn:count($params)) then '' else xs:string(xdmp:type($params[$i + 1]))
          return if($t1 = 'QName' and fn:not($t2 = 'QName') )
                 then map:put($message, xs:string($p), xs:string($params[$i + 1]))
                 else if($t1 = 'QName' and $t2 = 'QName')
                 then map:put($message, xs:string($p), '')
                 else ()
    return $message
};

declare variable $info := xs:dayTimeDuration('PT1S');
declare variable $notice := xs:dayTimeDuration('PT10S');
declare variable $warning := xs:dayTimeDuration('PT1M');
declare variable $error := xs:dayTimeDuration('PT2M');
declare variable $critical := xs:dayTimeDuration('PT3M');
declare function log:performance($start as xs:dayTimeDuration, $end as xs:dayTimeDuration) as empty-sequence()
{
    let $took := $end - $start

    let $level :=
      if($took le $info) then 'info'
      else if($took gt $info and $took le $notice ) then 'notice'
      else if($took gt $notice and $took le $warning) then 'warning'
      else if($took gt $warning and $took le $error) then 'error'
      else if($took gt $error) then 'critical'
      else 'alert'

    return
        if($level = ("error", "critical", "alert"))
        then log:error(<error>Request took way too long</error>, (xs:QName("duration"), $took))
        else log:log("performance", (), (xs:QName("duration"), $took), $level)
};
