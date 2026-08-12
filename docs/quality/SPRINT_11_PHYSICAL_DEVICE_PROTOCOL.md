# Sprint 11 physical-device protocol

Sprint 11 remains incomplete until this matrix passes on a physical API 30
low-memory/60 Hz device and a physical API 34+ reference device using the
profile APK from CI.

## Approved limits

- Warm start: 10 launches, median <=750 ms and p95 <=1,000 ms.
- Memory: steady PSS <=200 MB, retained growth <=10% after 30 minutes, no leak.
- CPU: idle average <=1%, critical flows <=40%, no unexplained >70% for 5 s.
- Battery: <=1% over 8-hour idle; <=2% incremental over 24-hour representative
  reminders/backups; no leaked wake lock or polling.
- Frames: >=95% within 16.67 ms, <=5% jank, zero frozen frames/ANRs.

## Execution and retained evidence

Record serial/build identifiers, conditions, timestamps and APK SHA-256. Run
`scripts/collect_sprint11_physical_evidence.ps1` at baseline and after the
30-minute endurance, 8-hour idle and 24-hour representative scenarios. Capture
Perfetto/Flutter traces for Dashboard, navigation, task detail, Search and large
lists; Simpleperf CPU traces for idle/Search/scroll/reminder/backup. Exercise
reboot, timezone/DST, Doze, WorkManager, exact alarms and strong-biometric
success/cancel/temporary-lockout/PIN fallback. Retain raw files plus a signed
pass/fail matrix. Emulator evidence cannot replace this record.
