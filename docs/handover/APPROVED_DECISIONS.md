# Approved Decisions

This register summarizes approved architectural and governance decisions. Requirement detail remains in the Masters.

## Authority and governance

- The Project Bible is the only source of truth; Parts 1-10 follow approved precedence and Part 11 is sole schedule authority.
- Global references use document-qualified IDs (`DocumentPart.ID`); local approved IDs are preserved.
- Only approved requirements may be implemented. Genuine ambiguity triggers stop/document/request approval.
- User approval plus the durable Codex task record is valid approval evidence (VR-007).
- No sprint may start before the previous sprint passes gates and receives approval.
- Twelve two-week sprints remain provisional; Sprint 1 records bottom-up re-estimation and changes require Part 11 controls (VR-012).
- Sprint 1 CI preparation is vendor-neutral local checks/required-check definitions; a hosted CI vendor is not required to start (VR-011).

## Product and scope

- Android-only, minimum Android 11, target Android 14+, Flutter with Kotlin native layer.
- Application ID `com.anaslifeos.app`; debug development signing; production key held only by the user.
- Single-individual, no-account, no-login, offline-first and privacy-first product.
- Knowledge Vault is the parent domain of Notes, Journal, Wiki and Documents.
- Dashboard is fully customizable: show, hide, reorder and resize widgets.
- Attachments are unlimited until device storage exhaustion; low-storage failure must be graceful.
- Recoverability requires valid encrypted backups and required keys.
- Password Vault, Expense Manager and Health Tracker are Future Release, not Version 1.

## Architecture

- Feature First Clean Architecture, MVVM, Repository Pattern, DI, SOLID, DRY, KISS, YAGNI and modular boundaries.
- Presentation depends on Domain; Data implements Domain interfaces; Domain depends on neither (VR-002).
- Riverpod owns application/feature state and composition. `get_it`/`injectable` are limited to infrastructure bootstrap and platform/native singleton adapters (VR-003).
- UI never accesses SQLite directly; required flow is Presentation - Domain/use case - Repository contract - Data source - Drift/SQLite.
- Business logic never lives in Widgets; `setState` is only temporary local UI state.
- GoRouter typed routes, Freezed immutable models, `json_serializable`, typed Result/failures and structured redacted local logging are approved.
- Kotlin owns approved Android-only biometric, Keystore, alarms/notifications, WorkManager, storage/permission and lifecycle responsibilities.
- Core features cannot depend on AI/plugins/network services.

## Database

- Database-first approach is intentional; review/implement the approved design rather than replace it without a critical evidenced conflict and approval.
- SQLite/Drift with SQLCipher-compatible encryption; repository-only asynchronous access.
- Business/entity tables receive the complete lifecycle profile. Join, audit, FTS, cache, history and schema tables receive purpose-appropriate columns.
- Foreign keys enabled, critical operations atomic, rollback on failure, migrations preserve data and indexes require query-plan evidence.
- User records use soft delete/restore; Delete Forever does not ship in Version 1 (VR-009).
- Files stay outside SQLite BLOBs; database stores metadata/checksums/ownership.

## Security, encryption and backup

- SQLCipher-compatible encrypted SQLite, AES-256-GCM protected payloads, Android Keystore-wrapped random master key and Argon2id backup-key derivation.
- Cryptographic providers/algorithms are modular and replaceable without redesign.
- PIN/password never plaintext; Android biometric APIs only; protected content excluded from normal search/previews/logs.
- No failed-PIN wipe in Version 1.
- Backups are local, encrypted, versioned, integrity-validated and never silently overwrite prior backups.
- Production signing key is never stored in source control, workspace, CI or application packages.

## UI and design

- Material 3, single design language, reusable token-driven components, no hardcoded colors.
- Light, dark, system, Dynamic Color, complete user customization and high-contrast/reduced-motion support.
- `#3F51B5` is only the default seed color.
- English/Urdu, LTR/RTL, dynamic font scaling, TalkBack, 48dp touch targets and responsive phone layouts.
- Common destructive actions offer Undo; no Version 1 Delete Forever.

## Testing and quality

- Business-logic line and branch coverage each target at least 90%; generated code excluded and other exclusions need evidence (VR-006).
- Baseline devices: API 30 small/low-memory emulator, API 34 reference emulator, latest target emulator, plus physical evidence for biometrics, alarms and battery (VR-008).
- Static analysis, lint, unit, widget, integration, database, reminder, notification, performance, memory, battery, accessibility, security, regression and UAT are mandatory when applicable.
- No warnings, dead code, TODO/FIXME, plaintext secrets or incomplete gates at completion.

## Plugin and AI boundaries

- Plugins and AI are optional, isolated, replaceable and Future Release in functional scope.
- Version 1 may contain inert contracts/manager foundations only; no functional AI route/UI or runtime third-party plugin behavior (VR-010).
- Plugins have no permissions by default, no direct database/file access, and failure cannot crash/control Core.
- Cloud/network access is optional Future Release and requires explicit consent/permission architecture.
