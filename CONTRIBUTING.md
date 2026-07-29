# Contributing

Anas Life OS is governed by the approved Project Bible. Contributions are accepted only when they preserve its authority, sprint controls, offline-first boundary, security model, and quality gates.

## Before contributing

1. Read [PROJECT_BIBLE_FINAL.md](PROJECT_BIBLE_FINAL.md).
2. Check [ROADMAP.md](ROADMAP.md) and [Sprint status](docs/roadmap/SPRINT_STATUS.md).
3. Review [pending decisions](docs/decisions/PENDING_DECISIONS.md) and [open issues](docs/decisions/OPEN_ISSUES.md).
4. Confirm that the proposed work is inside the currently approved sprint.

## Project Bible protection

- Do not edit an approved Master without explicit approval and impact analysis.
- Do not reinterpret a summary as authority over a Master.
- Preserve requirement IDs and traceability.
- Do not add Version 1 behavior from Future Release scope.
- Requirement changes require explicit approval before implementation.

## Change workflow

Every change must state:

- Reason and approved requirement IDs
- Affected modules and architecture boundaries
- Database and migration impact
- Security, privacy, accessibility, performance, and offline impact
- Test plan and regression scope
- Rollback plan
- Approval status

Use a focused branch and pull request. Do not combine unrelated work.

## Quality requirements

Applicable static analysis, formatting, unit, widget, integration, database, performance, accessibility, security, and regression checks must pass. Business-logic line and branch coverage must each remain at or above 90%, excluding generated code.

No contribution may contain known analyzer warnings, dead code, duplicated logic, TODO/FIXME markers, hardcoded secrets, or unapproved dependencies.

## Dependencies

Every new dependency requires justification, alternatives, disadvantages, maintenance risk, security review, and an approved lifecycle plan.

## Documentation

Update architecture notes, database impact, permissions, dependencies, change log, migration notes, limitations, and traceability with implementation. Documentation-only changes must preserve authoritative artifacts byte-for-byte.
