# Sprint 11 Product Owner decisions

Approved 2026-08-12: `P7-OI-004` / `OI-020`.

- Warm start median <=750 ms and p95 <=1,000 ms across 10 launches.
- PSS <=200 MB and retained growth <=10% after 30-minute endurance; no leak.
- CPU idle <=1%, critical-flow average <=40%, no unexplained >70% for 5 s.
- Battery <=1% for 8-hour idle and <=2% incremental for 24-hour representative
  reminders/backups; no leaked wake lock or polling.
- At least 95% of frames within 16.67 ms, jank <=5%, no frozen frame/ANR.
- The quantitative limits remain approved and unchanged.

Superseding Product Owner decision, 2026-08-12:

- Sprint 11 accepts the completed automated and API 30/API 34 emulator evidence
  as the available validation evidence.
- Physical-device, ADB, connected-device, 8-hour/24-hour battery, biometric,
  alarm and Doze execution was not performed and is explicitly deferred because
  the environment is unavailable and setup is not authorized.
- No physical result may be inferred or reported as passed.
- Residual risk is accepted for device-specific performance, memory, battery,
  frame pacing, biometrics, alarms, Doze, wake locks and lifecycle behavior.
- This deferral administratively closes Sprint 11; it does not alter its limits.
