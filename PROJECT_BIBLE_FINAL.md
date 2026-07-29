# Anas Life OS - Project Bible Final

**Purpose:** Single entry point for the approved Project Bible and current handover state.  
**Authority:** This Markdown manual summarizes but does not replace the unchanged approved DOCX Masters. Where detail differs, the authoritative Master and approved precedence control.  
**Date:** 29 July 2026.

## 1. Project vision

Anas Life OS is an Android-only, completely offline personal Life Operating System, not merely a task manager. It replaces fragmented task, calendar, notes, reminder, document, knowledge, project and personal organization tools with a unified private application. No cloud, account, login, subscription requirement, ads, analytics or tracking. The user owns all data and core behavior never requires Internet.

Primary users include individuals, professionals, business owners, students, teachers, researchers, power users and Islamic scholars. Goals: reduce stress and forgotten commitments, centralize information, find anything quickly, organize projects/knowledge/documents, track progress and protect privacy.

## 2. Engineering baseline

- Platform: Android only; minimum Android 11; target Android 14+.
- Framework/language: Flutter/Dart with Kotlin native layer.
- Application ID: `com.anaslifeos.app`.
- Signing: debug development signing; production key controlled only by the user.
- Maintainability: production-grade, ten-year horizon, no demo/tutorial quality.
- Architecture: Feature First Clean Architecture, MVVM, Repository Pattern, dependency injection, SOLID, DRY, KISS, YAGNI, modular, offline-first, plugin-ready and AI-ready.
- Quality: one logical task at a time, immediate gates, no accumulated defects, no TODO/FIXME/dead/duplicated/temporary code.

Part 1 controlled IDs: `P1-PROJ-001`-`002`, `P1-VIS-001`, `P1-PRIV-001`, `P1-DEV-001`, `P1-ARCH-001`-`002`, `P1-UI-001`, `P1-THEME-001`, `P1-DB-001`-`003`, `P1-SEC-001`-`002`, `P1-PERF-001`, `P1-CODE-001`, `P1-FILE-001`, `P1-COM-001`, `P1-ERR-001`, `P1-TEST-001`, `P1-REV-001`, `P1-STOP-001`, `P1-GATE-001`, `P1-MNT-001`.

## 3. Authority order

1. Part 1 Master - vision/baseline.
2. Part 1A - clarification register.
3. Part 1B - approved answer format/record.
4. Part 2 Master - functional scope.
5. Part 3 Master - non-functional scope.
6. Part 4 Master - database architecture.
7. Part 5 Master - application architecture/UI-UX.
8. Part 6 Master - development governance/execution.
9. Part 7 Master - test/QA.
10. Part 8 Master - design system, subordinate to Part 5 on conflict.
11. Part 9 Master - plugin/AI extensibility.
12. Part 10 Master - implementation conduct.
13. Part 11 Master - exclusive schedule authority.

The final validation records cross-Part resolutions. Global traceability uses `DocumentPart.ID`; local IDs remain unchanged.

## 4. Version 1 scope

Core modules: Dashboard; Tasks; Projects; Reminders; Calendar; Knowledge Vault; Universal Search; Statistics; Backup; Security; Settings; Plugin Manager foundation. Knowledge Vault is the parent of Notes, Journal, Wiki and Documents, including attachment/document management.

Key functional ID ranges:

- Dashboard `DASH-001`-`003`: summaries, activity, quick add/search and fully customizable widgets.
- Tasks `TASK-001`-`010`: create/edit/archive/soft-delete/restore/duplicate/clone/move/merge/split with rich fields, subtasks, checklists, dependencies and attachments.
- Projects `PROJ-001`-`004`: project entity, dashboard, timeline and statistics.
- Reminders `REM-001`-`010`: offline notification, voice/vibration/flash/full-screen, multiple/escalating reminders, snooze/sounds/missed report subject to platform policy.
- Calendar `CAL-001`-`007`: day/week/month/year/agenda/timeline/heat map.
- Knowledge `KV-001`-`008`: rich/Markdown notes, folders, tags, wiki/cross links, favorites, history.
- Documents `DOC-001`-`010`: attachments and offline metadata/preview across approved types.
- Search `SEARCH-001`-`009`: universal/instant/voice, attachment/date/project/tag/saved search; OCR search Future plugin.
- Statistics `STAT-001`-`008`: daily/weekly/monthly/yearly, completion, delay, productivity and charts.
- Security `SEC-001`-`006`: PIN, biometric, hidden items, encrypted storage, auto-lock, secure backup.
- Backup `BACK-001`-`006`: manual/automatic/versioned backup, restore, export/import.
- Settings `SET-001`-`008`: theme, language, reminder/backup/security/plugin settings, about, diagnostics.
- Plugin records `PLUGIN-001`-`008` describe Future Release feature plugins; Version 1 behavior remains inert/manager-only.
- `HEALTH-001` is Future Release.

Unlimited attachments means until device storage exhaustion with graceful low-storage handling. "Everything recoverable" means only when valid encrypted backups and required keys exist. User records are soft-deleted/restorable; no Version 1 Delete Forever.

## 5. Future Release scope

Expense Manager, Password Vault, Health Tracker, Inventory, OCR, functional AI Assistant, automation, cloud sync, Wear OS, desktop companion, foldable-specific features, runtime third-party extensions and future voice/wake-word capabilities. Future functionality receives no Version 1 sprint. Only isolated, inert, replaceable boundaries explicitly assigned to Sprint 1 may exist.

## 6. Approved decisions

- Document-qualified ID namespace; bare collisions preserved locally.
- Presentation - Domain; Data implements Domain; Domain independent.
- Riverpod owns app/feature state/composition; `get_it`/`injectable` limited to infrastructure/platform singleton bootstrap.
- Part 11 exclusively schedules work.
- Sprint 1 secure-storage interfaces only; security behavior Sprint 10.
- Business-logic line and branch coverage >=90%; generated code excluded.
- User/task record is approval evidence.
- Device baseline: API 30 small/low-memory, API 34 reference, latest target; physical biometrics/alarms/battery evidence.
- No permanent deletion or failed-PIN wipe in Version 1.
- Future capabilities absent/inert.
- Vendor-neutral Sprint 1 CI preparation.
- Twelve-sprint roadmap provisional; re-estimate in Sprint 1.
- SQLCipher-compatible SQLite, AES-256-GCM, Keystore-wrapped master key, Argon2id backups, replaceable crypto providers.
- Business/entity full lifecycle columns; special-purpose tables use appropriate profiles.
- `#3F51B5` default seed only; Dynamic Color and complete customization supported.

See `APPROVED_DECISIONS.md` for the full categorized register.

## 7. Non-functional requirements

Part 3 preserves 60 requirements:

- `NFR-PERF-001`-`010`: cold start <2 seconds, screen/task/search latency, indexed queries, pagination/lazy images, no application UI blocking/ANR.
- `NFR-BAT-001`-`005`: bounded background work, no leaked wake locks, reminder-only wakes, location on demand, appropriate WorkManager use.
- `NFR-MEM-001`-`005`: no reproducible leaks; dispose controllers, animations, streams; manage image cache.
- `NFR-DB-001`-`006`: SQLite only, migrations, soft delete, foreign keys, searchable indexes, critical transactions.
- `NFR-SEC-001`-`006`: encryption, no plaintext secrets, encrypted backups, PIN, biometrics and auto-lock.
- `NFR-OFF-001`-`005`: application, reminders, search, backup and restore work offline with no mandatory online dependency.
- `NFR-UI-001`-`008`: Material 3, light/dark, dynamic fonts, responsive, RTL/LTR and accessibility.
- `NFR-ERR-001`-`004`: no reproducible unhandled crash, meaningful errors, recovery and local redacted logging.
- `NFR-CODE-001`-`006`: SOLID, Clean Architecture, single responsibility, no duplication/TODO/dead code.
- `NFR-FUTURE-001`-`005`: plugin/AI-ready boundaries; cloud/desktop/Wear Future Release.

Every requirement carries Priority, Complexity, Verification, Target Sprint and Traceability.

## 8. Database architecture

Database name `anas_life_os.db`, UTF-8, SQLite through Drift, SQLCipher-compatible encrypted storage. Database-first, normalized, explicit relationships, migration-ready, indexed, nonblocking, repository-only.

Major groups:

- Core: categories, subcategories, projects, tasks, checklists/items, subtasks, tags/maps, task/state history, dependencies, recurrence, reminders/history, locations, voice notes, custom fields, comments/activity.
- Knowledge/documents: spaces, folders, notes, tags/maps, links/backlinks, versions, graph projections, documents/folders/versions/metadata, attachment folders/files/versions/previews/labels/maps.
- Calendar/search/statistics: events/participants/reminders, search history/saved search/FTS projections, daily/weekly/monthly/yearly stats.
- Settings/security/backup: settings/themes/languages/notifications, lock/PIN/biometrics/audit, backup profiles/history/restore.
- System/extensions: diagnostics/logs/errors/maintenance/migration/app versions/events/notification queue and inert plugin/AI registries.

Part 4 namespaces: `P4-GEN-001`-`018`, `P4-TBL-001`-`086`, `STATE-001`-`009`, `P4-RULE-001`-`018`, `P4-ACC-001`-`012`, `P4-OI-001`-`024`.

Task states: Draft, Scheduled, Pending, In Progress, Waiting, Blocked, Completed, Archived, Deleted/recycle. Every transition/history/reminder event follows approved integrity rules. Files remain outside SQLite; SHA-256 metadata, lazy preview and protected-content policies apply.

## 9. Application architecture

Part 5 namespaces: `P5-ARCH-001`-`032`, `P5-DS-001`-`036`, `P5-SCR-001`, `SCREEN-001`-`140` (defined set), `P5-ACC-001`-`016`, `P5-OI-001`-`024`.

Proposed source structure:

```text
lib/
  core/{config,constants,theme,router,database,services,security,logging,errors,utils,widgets,extensions,plugins,shared}/
  features/{dashboard,tasks,projects,calendar,reminders,knowledge,documents,attachments,statistics,search,backup,settings,security,plugins,ai}/
```

Each needed feature separates `data/`, `domain/` and `presentation/` responsibilities. Do not create empty architecture ceremony. Files should remain cohesive; widgets prefer <250 lines, services <400, all >400 require review. Permissions are requested only after user intent.

## 10. UI/UX and design system

One Material 3 language: professional, modern, minimal, calm, fast, readable and accessible. Token systems cover semantic colors, Material typography, 4dp atomic/8dp primary rhythm (pending exact semantics), radii, elevation, icons, animation, opacity and states. Use Material Symbols, no emoji UI icons. Motion uses 100/200/300/500ms and supports Reduce Motion.

Navigation baseline: bottom navigation Dashboard, Tasks, Calendar, Knowledge, More; universal search everywhere; side drawer/quick actions/context FAB as defined by approved hierarchy. Dashboard widgets can show/hide/reorder/resize. Every screen requires purpose, states, inputs/outputs, accessibility, performance notes and measurable acceptance.

## 11. Development governance

Part 6 combines the 27-step feature cycle, twenty architecture/quality laws and roadmap crosswalk. Read requirements/architecture/database/dependencies/edge cases before implementation; then implement, format/analyze, unit/widget/integration test, review performance/accessibility/security/offline/memory/battery/responsiveness/database/error/logging/documentation, report, and wait for approval.

No feature is complete while any applicable build, analyzer, test, performance, memory, accessibility, offline, security or documentation gate fails. Architectural changes require impact analysis, backward compatibility, migration implications, regression tests and approval.

## 12. Testing strategy

Part 7 controlled areas: governance/principles; 15 test levels; unit/widget/integration/database/reminder/search/performance/battery/security/accessibility/UAT; bug records; self-review and final evidence. Business rules require unit tests. Every screen covers loading/empty/data/large data/small screen/themes/RTL/landscape/accessibility as applicable. Full workflows verify persistence, scheduling, notification, completion and statistics. Bugs require reproducibility, root cause, fix and regression risk.

Quality gate: formatter/analyzer pass, all applicable tests pass, business logic line/branch coverage >=90%, performance/security/accessibility pass and documentation updated.

## 13. Plugin and AI boundaries

Core is authoritative and fully functional without AI/plugins. Plugin states: installed, enabled, disabled, updated, removed, failed, incompatible. Permissions default to none. Contracts define name/version/purpose/permissions/inputs/outputs/errors/timeouts/security/compatibility. No direct database, unrestricted file/memory or Core control. Plugin data is separately restorable and Core backup survives missing plugins.

AI providers may later be local, cloud, private server or user-defined; no vendor dependency. Future Anas AI may provide voice/task/reminder/knowledge/planning/suggestions/automation only after separate approval. Network AI requires consent/data-flow/threat decisions.

## 14. Implementation constitution

Requirements-first, database-first, architecture-first, security-first, offline-first, quality-first and maintainability-first. Implement vertical slices only within the approved sprint. Schema change requires migration/backward compatibility/rollback/integrity. Every change records reason, affected modules, risk, migration/test impact, rollback and approval. Release requires no critical bugs/high security issues and passing migration, backup/restore, performance, accessibility, regression and documentation.

## 15. Sprint roadmap

1. Foundation: setup/configuration, structure, DI, logging, theme, localization/RTL, database initialization boundary, CI, standards/docs/gates; no feature development.
2. Database: encrypted SQLite/Drift foundation, entities, repositories, indexes, migrations, soft delete, audit, backup metadata/tests.
3. Tasks/projects.
4. Reminders/notifications.
5. Knowledge Vault/documents.
6. Dashboard/calendar.
7. Search.
8. Statistics.
9. Backup/restore.
10. Security behavior.
11. Optimization/accessibility/large data/regression.
12. Release candidate.

Every sprint includes objectives, features, database impact, logic, UI, tests, docs, performance, security and approval as applicable. Never skip a sprint or merge incomplete work.

## 16. Open issues and pending decisions

The consolidated registers preserve 112 Master open issues. Final/later approvals resolved 27; 85 remain pending or partially resolved for their owning feature/gate. They do not alter approved architecture and are not implementation authority. See `OPEN_ISSUES.md` and `PENDING_DECISIONS.md`. No unresolved product decision blocks the start of Sprint 1; the current blocker is environmental.

## 17. Traceability overview

Part 1/1A/1B - Part 2 scope - Part 3 quality - Part 4 data - Part 5 application/UI - Part 6 execution - Part 7 QA - Part 8 design - Part 9 extensions - Part 10 conduct - Part 11 schedule. See `TRACEABILITY_INDEX.md` for clarification groups, module ranges and sprint map.

## 18. Current sprint and implementation status

Project Bible: approved for Sprint 1. Sprint 1: authorized but not started. Blocker: Flutter, Dart, Android SDK/ADB, Gradle and JDK compiler absent. Files created: none. Database/Kotlin changes: none. Analyzer/tests/build: not runnable. Sprint 2: not authorized and not started.

PROJECT BIBLE APPROVED FOR SPRINT 1 IMPLEMENTATION

## 19. Required environment

Flutter stable SDK, compatible JDK, Android SDK command-line tools/platform-tools/build-tools, API 30 and approved current target/compile platform, licenses, Git, emulators/physical devices, `PATH`, `JAVA_HOME`, `ANDROID_SDK_ROOT`. Entry evidence: usable `flutter doctor -v` and a debug foundation that formats, analyzes, tests and builds.

## 20. Handover folder structure

```text
ANAS_LIFE_OS_HANDOVER/
  PROJECT_BIBLE_FINAL.md
  PROJECT_CONTINUATION_PROMPT.md
  PROJECT_HANDOVER.md
  PROJECT_INDEX.md
  PROJECT_STATUS.md
  PROJECT_TIMELINE.md
  MASTER_DOCUMENT_INDEX.md
  APPROVED_DECISIONS.md
  PENDING_DECISIONS.md
  OPEN_ISSUES.md
  TRACEABILITY_INDEX.md
  IMPLEMENTATION_READINESS.md
  SPRINT_STATUS.md
  masters/          # unchanged Part 1-11 Masters
  clarifications/   # unchanged Parts 1A/1B
  validation/       # unchanged final validation
  superseded/       # historical Part 2A; non-authoritative
```

## 21. Master document index

See `MASTER_DOCUMENT_INDEX.md` for filename, purpose, authority, dependencies and status. See `PROJECT_INDEX.md` for every source document and SHA-256.

## 22. Next recommended action

Transfer this complete package. In the new account, paste `PROJECT_CONTINUATION_PROMPT.md`, attach the package, validate the toolchain, and resume Sprint 1 at **Project Setup**. Run the full task-level gate after each logical task. Stop after Sprint 1 and request approval. Do not start Sprint 2.
