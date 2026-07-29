# Project Continuation Prompt

You are taking over **Anas Life OS** with zero prior memory. Treat the files in this handover package as complete project context. Do not rely on previous chat history.

## Mandatory first actions

1. Read `PROJECT_BIBLE_FINAL.md` completely.
2. Read `PROJECT_HANDOVER.md`, `PROJECT_STATUS.md`, `IMPLEMENTATION_READINESS.md`, `SPRINT_STATUS.md`, `APPROVED_DECISIONS.md`, `PENDING_DECISIONS.md`, `OPEN_ISSUES.md` and `TRACEABILITY_INDEX.md`.
3. Verify the unchanged authoritative DOCX files under `masters/`, `clarifications/` and `validation/` using `PROJECT_INDEX.md` hashes.
4. Never treat `superseded/Part 2A – Requirements Revision.docx` as authority.

## Project vision

Build a production-grade Android-only, offline personal Life Operating System that centralizes tasks, projects, reminders, calendar, Knowledge Vault content, documents, attachments, search, statistics, local backup and settings. No cloud, login, account, ads, analytics, tracking or mandatory Internet. Data stays on the device. Minimum Android 11; target Android 14+; Flutter/Dart application with Kotlin native layer; application ID `com.anaslifeos.app`; ten-year maintainability objective.

## Authority

The Project Bible is the only source of truth. Precedence: Part 1 Master; Part 1A; Part 1B; Part 2 Master; Part 3 Master; Part 4 Master; Part 5 Master; Part 6 Master; Part 7 Master; Part 8 Master; Part 9 Master; Part 10 Master. Part 11 Master exclusively controls sprint sequence and assignment. Use document-qualified IDs globally. Do not modify a requirement, architecture, database decision or sprint without explicit user approval.

## Approved architecture

- Feature First Clean Architecture, MVVM, Repository Pattern, DI, SOLID, DRY, KISS, YAGNI and modular boundaries.
- Compile-time dependencies point inward: Presentation - Domain; Data implements Domain interfaces; Domain depends on neither Data nor Presentation.
- Riverpod owns application/feature state and composition. `get_it`/`injectable` are restricted to infrastructure bootstrap and platform/native singleton adapters.
- UI - ViewModel/use case - Domain repository contract - Data repository/data source - Drift database. UI never accesses SQLite.
- GoRouter typed routes; Freezed immutable models; `json_serializable`; typed Result/failures; structured redacted local logging.
- Kotlin owns approved Android biometrics, Keystore, exact alarms/notifications, WorkManager, permissions, platform storage and lifecycle integration.
- AI/plugin/network boundaries are isolated and cannot become core dependencies.

## Database-first and security

Sprint 1 defines initialization/interfaces only; Sprint 2 owns database implementation. Use Drift over SQLCipher-compatible SQLite. Business/entity tables use the full lifecycle profile; join/audit/FTS/cache/history/schema tables use purpose-appropriate profiles. Foreign keys, atomic transactions, rollback, migrations, query-plan-backed indexes, soft delete/restore and repository-only asynchronous access are mandatory.

Cryptography: SQLCipher-compatible database encryption; AES-256-GCM protected payloads; Android Keystore-wrapped random master key; Argon2id encrypted-backup keys; modular replaceable crypto providers; no plaintext PIN/password; no failed-PIN wipe; no Delete Forever in Version 1. Production signing key remains under user-only custody.

## Version 1 and Future Release

Version 1 follows Sprints 1-12: foundation, database, tasks/projects, reminders, Knowledge Vault/documents, dashboard/calendar, search, statistics, backup, security, optimization, release candidate. Knowledge Vault owns Notes, Journal, Wiki and Documents. Dashboard is show/hide/reorder/resize customizable. Attachments are unlimited until storage exhaustion with graceful handling. Recovery requires valid encrypted backups and keys.

Future Release: Expense Manager, Password Vault, Health Tracker, Inventory, OCR, functional AI, automation, cloud sync, Wear OS, desktop companion, foldable-specific features and functional runtime plugins. Only explicitly approved inert boundaries may exist in Version 1.

## UI/UX and quality

Material 3; default seed `#3F51B5` only; Dynamic Color and complete customization; light/dark/system/high contrast; English/Urdu; LTR/RTL; dynamic fonts; TalkBack; 48dp targets; responsive/adaptive phone layouts; Reduce Motion; token-driven reusable components; no hardcoded colors; no inaccessible gesture-only action.

Every logical task must run formatter, analyzer, applicable unit/widget/integration tests, Android build, architecture/dependency/database/security/offline/accessibility/performance review and documentation gate. Business-logic line and branch coverage each target >=90%, generated code excluded. No warnings, dead code, TODO, FIXME, temporary hacks or plaintext secrets.

## Roadmap

Part 11 is sole authority: Sprint 1 Foundation; 2 Database; 3 Tasks/Projects; 4 Reminders; 5 Knowledge Vault/Documents; 6 Dashboard/Calendar; 7 Search; 8 Statistics; 9 Backup; 10 Security; 11 Optimization; 12 Release Candidate. Never start a later sprint without the prior sprint's explicit approval.

## Current progress

Planning is complete and approved. Sprint 1 was explicitly authorized but **no implementation was created**. The attempt stopped at the first environment gate because Flutter, Dart, Android SDK/ADB, Gradle and a JDK compiler were not discoverable. No database or Kotlin change exists. Sprint 2 was not started.

## Exact continuation point

1. Install/configure Flutter stable, compatible JDK, Android SDK command-line/platform/build/platform-tools, Android API 30 and approved current target platform.
2. Configure `PATH`, `JAVA_HOME`, `ANDROID_SDK_ROOT`; accept licenses.
3. Require a usable `flutter doctor -v` result and verify debug project format/analyze/test/build.
4. Resume **Sprint 1, first logical task: Project Setup**.
5. Implement the complete Sprint 1 scope only: Flutter/Android configuration, folders, DI, logging, error boundary, theme, localization/Urdu/English/RTL, database initialization boundary, event bus, secure-storage interfaces only, CI preparation, coding standards, documentation and gates. No feature development and no Sprint 2 schema.
6. After every task, fix all issues before continuing.
7. At Sprint 1 completion provide one report with: Goal; Design Decisions; Files Created; Files Modified; Database Changes; Flutter Architecture Changes; Kotlin Changes; Tests; Analyzer; Build; Manual Verification; Risks; Remaining Sprint 1 Issues; Completion Status.
8. End with either `SPRINT 1 COMPLETED SUCCESSFULLY` or `SPRINT 1 BLOCKED` with exact evidence.
9. Do not begin Sprint 2. Await explicit approval.

## Stop rule

If the Project Bible cannot resolve a material choice, stop only for that exact blocker, show evidence, and request user approval. Never silently compromise architecture, security, quality or requirements.
