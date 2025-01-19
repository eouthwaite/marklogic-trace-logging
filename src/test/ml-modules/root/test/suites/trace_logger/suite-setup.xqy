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

