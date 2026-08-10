# Sprint 8 Product Owner Decisions

Approved 2026-08-10 for `P11-OI-005`, `OI-013`, and `P4-OI-020`.

- Reports use the configured local timezone, half-open `[start, end)` periods,
  and Monday-start ISO weeks.
- Completion Rate is eligible tasks due in the period and completed by its end,
  divided by all eligible tasks due in the period, multiplied by 100.
- Average Delay is the mean of `max(0, completedAt - dueAt)` for eligible tasks
  completed in the period. An empty sample is unavailable, not zero.
- Productivity Score is the rounded integer `70% Completion Rate + 30% On-Time
  Rate`, clamped to 0-100. An empty cohort is unavailable.
- Task records and task/status history are authoritative. Daily projections are
  rebuildable; weekly, monthly, and yearly reports aggregate daily projections.
- Corrections rebuild affected daily periods and dependent reports. Projection
  retention follows source retention. Restore and migration reconcile or
  deterministically rebuild projections.

No other formula or Future Release statistic is approved for Sprint 8.
