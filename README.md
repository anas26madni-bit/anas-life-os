# Anas Life OS

Anas Life OS is a privacy-first, offline personal life management system for Android. It is designed as a unified Life Operating System for tasks, projects, reminders, calendars, knowledge, documents, search, statistics, backup, and security without accounts, advertising, analytics, tracking, or mandatory internet access.

> **Current state:** Sprint 1 foundation source and validation automation are
> implemented. Executable analyzer, test, and Android build evidence remains
> blocked until the required Flutter/Android toolchain is available.

## Project vision

The product gives one person a trusted, searchable, connected, and recoverable place for personal information. All Version 1 core functionality must remain available offline, and user data must stay on the device unless a future, explicitly enabled plugin changes that boundary.

## Version 1 feature domains

- Customizable dashboard and quick actions
- Tasks, subtasks, checklists, categories, tags, dependencies, and projects
- Offline reminders and calendar views
- Knowledge Vault containing Notes, Journal, Wiki, and Documents
- Attachment management with graceful low-storage handling
- Universal offline search in English and Urdu
- Statistics and productivity reporting
- Encrypted local backup and restore
- PIN, biometric app lock, hidden items, and encrypted sensitive storage
- Themes, localization, RTL/LTR, accessibility, diagnostics, and settings

Password Vault, Expense Manager, Health Tracker, AI capabilities, OCR, cloud synchronization, Wear OS, and desktop companion capabilities are Future Release scope.

## Architecture

The approved architecture is database-first and offline-first, using feature-first Clean Architecture with MVVM, repositories, dependency injection, and isolated plugin/AI boundaries. Presentation depends on Domain, Data implements Domain contracts, and Domain stays framework-independent. Version 1 user records use soft deletion. Cryptographic providers remain modular.

The complete authority hierarchy and constraints are defined in [PROJECT_BIBLE_FINAL.md](PROJECT_BIBLE_FINAL.md).

## Technology stack

| Area | Approved technology |
|---|---|
| Application | Flutter and Dart |
| Native Android | Kotlin |
| Platform | Android 11 minimum; Android 14+ target |
| State management | Riverpod |
| Navigation | GoRouter with typed routes |
| Database | Drift over SQLCipher-compatible SQLite |
| Dependency injection | Riverpod plus constrained `get_it`/`injectable` infrastructure bootstrap |
| Models | Freezed and `json_serializable` |
| Cryptography | AES-256-GCM, Android Keystore-wrapped master key, Argon2id backup-key derivation |
| Background work | Android WorkManager where appropriate |
| Notifications | Local Android notifications |

Package versions will be selected during Sprint 1 dependency validation.

## Documentation

- [Project Bible](docs/project-bible/)
- [Final consolidated Project Bible](PROJECT_BIBLE_FINAL.md)
- [Decisions](docs/decisions/)
- [Traceability](docs/traceability/)
- [Roadmap](ROADMAP.md)
- [Complete handover](docs/handover/)

The authoritative DOCX Masters are copied without modification. Repository summaries never override them.

## Current status and sprint progress

| Area | Status |
|---|---|
| Project Bible Parts 1-11 | Approved |
| Documentation baseline | Imported |
| Sprint 1 | Foundation source complete; executable gates blocked by local toolchain |
| Sprints 2-12 | Not started and not authorized |

The local execution environment does not currently expose Flutter, Dart, the
Android SDK, ADB, Gradle, or a JDK compiler. The repository-owned quality gate
must pass in a compliant environment before Sprint 1 can be approved complete.

No feature may be developed outside its sprint, and no sprint may begin until the preceding sprint passes every quality gate and receives approval.

## Future roadmap

Version 1 uses twelve two-week sprints: foundation, database, task engine, reminder engine, Knowledge Vault, dashboard/calendar, search, statistics, backup, security, optimization, and release candidate. See [ROADMAP.md](ROADMAP.md).

## Contributing and security

Read [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md), and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before proposing a change.

## License

Copyright © 2026 Anas Life OS. All rights reserved. See [LICENSE](LICENSE).
