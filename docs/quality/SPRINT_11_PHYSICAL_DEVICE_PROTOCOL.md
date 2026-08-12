# Sprint 11 deferred physical-device protocol

This protocol was prepared but not executed. On 2026-08-12 the Product Owner
declined physical-device/ADB setup and explicitly accepted the available
automated and emulator evidence to close Sprint 11. No physical-device result is
claimed as passed. The protocol is retained as deferred evidence guidance and
does not block the accepted Sprint 11 closure.

## Approved limits

- Warm start: 10 launches, median <=750 ms and p95 <=1,000 ms.
- Memory: steady PSS <=200 MB, retained growth <=10% after 30 minutes, no leak.
- CPU: idle average <=1%, critical flows <=40%, no unexplained >70% for 5 s.
- Battery: <=1% over 8-hour idle; <=2% incremental over 24-hour representative
  reminders/backups; no leaked wake lock or polling.
- Frames: >=95% within 16.67 ms, <=5% jank, zero frozen frames/ANRs.

## Deferred execution and retained evidence

Record serial/build identifiers, conditions, timestamps and APK SHA-256. Run
`scripts/collect_sprint11_physical_evidence.ps1` at baseline and after the
30-minute endurance, 8-hour idle and 24-hour representative scenarios. Capture
Perfetto/Flutter traces for Dashboard, navigation, task detail, Search and large
lists; Simpleperf CPU traces for idle/Search/scroll/reminder/backup. Exercise
reboot, timezone/DST, Doze, WorkManager, exact alarms and strong-biometric
success/cancel/temporary-lockout/PIN fallback. Retain raw files plus a signed
pass/fail matrix. Emulator evidence cannot replace this record.

Residual risk remains for device-specific performance, memory, CPU, battery,
frame pacing, biometric, alarm, Doze, wake-lock and lifecycle behavior. The
approved limits above remain unchanged but were not verified on physical hardware.
