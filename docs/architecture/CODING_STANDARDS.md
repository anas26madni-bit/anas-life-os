# Coding standards

- Follow feature-first Clean Architecture and the approved dependency direction.
- Riverpod owns state and composition; `get_it`/`injectable` remain
  infrastructure-only.
- UI never imports Drift, SQLite, data sources, or native adapters.
- Use immutable state, typed failures/results, and exhaustive sealed types.
- Keep functions focused and files below the approved review thresholds.
- Use semantic theme, spacing, radius, and motion tokens; never hardcode UI
  colors or user-facing strings.
- Log locally with structured severity and no secrets or personal content.
- No TODO, FIXME, dead code, commented-out code, warnings, or analyzer issues.
- Every change includes applicable tests, documentation, and traceability.
- Database changes require migration, rollback, integrity, and recovery plans.
- Runtime packages require documented need, risks, maintenance review, and
  approval within the owning sprint.
