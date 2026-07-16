Symptom: Tagged cmux DEV sf7191 reportedly disappeared or crashed.
User impact: Safari extension dogfood session ended unexpectedly.
Source: User report plus local crash reports, tagged app log, and unified logs.
Target surface: macOS.
Build/version/tag: cmux DEV sf7191, source head fdaa0db8ed8099bbfa6086165d0723bd16473ef1.
Repro workload: Open the browser extension menu in the tagged app and observe whether the process remains alive.
Expected bad behavior: Process terminates around 2026-07-15 15:49-15:50 America/Los_Angeles.
