# Sprint 11 Product Owner decisions

Approved 2026-08-12: `P7-OI-004` / `OI-020`.

- Warm start median <=750 ms and p95 <=1,000 ms across 10 launches.
- PSS <=200 MB and retained growth <=10% after 30-minute endurance; no leak.
- CPU idle <=1%, critical-flow average <=40%, no unexplained >70% for 5 s.
- Battery <=1% for 8-hour idle and <=2% incremental for 24-hour representative
  reminders/backups; no leaked wake lock or polling.
- At least 95% of frames within 16.67 ms, jank <=5%, no frozen frame/ANR.
- Physical API 30 low-memory/60 Hz and API 34+ reference evidence is mandatory;
  emulator-only evidence cannot complete Sprint 11.
