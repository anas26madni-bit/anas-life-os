# Development Roadmap

This roadmap is derived from the approved Part 11 Master. Part 11 remains the sole schedule authority. Sprint duration is two weeks, and the twelve-sprint plan is provisional for a single AI developer with human review and approval.

| Sprint | Phase | Approved deliverables | Status |
|---:|---|---|---|
| 1 | Project Foundation | Setup, Flutter/Android configuration, folder structure, DI, logging, theme, localization, RTL, database initialization, CI preparation, standards, documentation, gates; no feature development | Complete |
| 2 | Database Foundation | SQLite, entities, repositories, indexes, migrations, soft delete, audit fields, encryption preparation, backup metadata, database tests | Complete |
| 3 | Task Engine | Tasks, CRUD, categories, priorities, status, subtasks, attachments, recurrence, validation, repository, tests | Complete |
| 4 | Reminder Engine | Scheduling, notifications, exact-alarm handling, recurrence, snooze, missed detection, history, tests | Complete |
| 5 | Knowledge Vault | Notes, Journal, Wiki, Documents, tags, cross-references, knowledge search, attachments | Not started |
| 6 | Dashboard | Dashboard, customizable widgets, calendar, quick actions, statistics cards, today's and pending tasks | Not started |
| 7 | Search Engine | Global search, filters, sorting, tag/knowledge/attachment search, Urdu/English search, optimization | Not started |
| 8 | Statistics | Reports, charts, productivity score, completion rate, delay analysis, historical trends | Not started |
| 9 | Backup | Backup, restore, integrity validation, encrypted export, import, recovery tests | Not started |
| 10 | Security | PIN, biometric authentication, encryption, hidden items, secure storage, permission validation | Not started |
| 11 | Optimization | Memory, battery, performance, accessibility, large-database and regression testing | Not started |
| 12 | Release Candidate | Final fixes, regression, documentation, performance/security/accessibility validation, release notes, Version 1 candidate | Not started |

## Sprint controls

Every sprint must include objectives, features, database changes, business logic, UI, tests, documentation, performance validation, security review, and approval as applicable.

A sprint is complete only when approved work is complete; tests and documentation pass; no critical bug remains; performance, security, and accessibility pass; and explicit approval is recorded.

Completed-sprint changes require impact analysis, approval, a migration plan when applicable, and regression tests. Sprint 5 must not begin before Sprint 4 passes all gates and its completion is recorded.

## Future Release

Password Vault, Expense Manager, Health Tracker, OCR, AI capabilities, automation, optional cloud synchronization, Wear OS, and desktop companion capabilities are outside Version 1 sprint assignments.
