# Anas Life OS - Project Handover

**Export date:** 29 July 2026  
**State:** Project Bible approved; Sprint 1 authorized but execution blocked by missing Flutter/Android toolchain.  
**Single entry point:** [PROJECT_BIBLE_FINAL.md](<PROJECT_BIBLE_FINAL.md>)  
**Continuation prompt:** [PROJECT_CONTINUATION_PROMPT.md](<PROJECT_CONTINUATION_PROMPT.md>)

## Overview and vision

Anas Life OS is an Android-only, privacy-first, offline personal Life Operating System. It unifies tasks, projects, reminders, calendar, Knowledge Vault content, documents, attachments, search, statistics, backup, settings and security without accounts, cloud, ads, analytics or tracking. Version 1 targets Android 11 minimum and Android 14+, uses Flutter with a Kotlin native layer, and must remain maintainable for at least ten years.

## Engineering baseline

- Application ID `com.anaslifeos.app`; debug signing for development; production key under user-only custody.
- Feature First Clean Architecture, MVVM, Repository Pattern, Riverpod state/composition, limited `get_it`/`injectable` infrastructure bootstrap, GoRouter, Drift/SQLite, Freezed and typed results.
- Presentation depends on Domain; Data implements Domain contracts; Domain is independent of Data, Presentation, Flutter, Drift and Android APIs.
- Database-first: Sprint 1 initializes boundaries only; Sprint 2 owns schema/entities/repositories/indexes/migrations.
- Offline-first: no mandatory network, account, cloud, telemetry or remote runtime dependency.
- Material 3, English/Urdu, LTR/RTL, responsive phone layouts, light/dark/system, Dynamic Color, full theme customization and fallback seed `#3F51B5`.
- Every task must pass formatter, analyzer, build, applicable tests, architecture, dependency, database, security, accessibility, performance, offline, memory, battery and documentation gates before continuation.

## Authority order

Part 1, Part 1A, Part 1B, Part 2, Part 3, Part 4, Part 5, Part 6, Part 7, Part 8, Part 9 and Part 10 govern meaning/conduct in that order. Part 11 exclusively governs schedule. Use document-qualified IDs globally; never rename approved local IDs.

## Version 1 scope

Foundation; database infrastructure; tasks; projects; reminders; Knowledge Vault as parent of Notes, Journal, Wiki and Documents; attachments; calendar; customizable dashboard; offline search; statistics; encrypted local backup/restore; PIN/biometric/app lock; settings; diagnostics; inert Plugin Manager boundaries. Unlimited attachments means until storage exhaustion with graceful handling. Recoverability requires valid encrypted backups and keys. Soft delete/restore remains; Delete Forever and failed-PIN wipe do not ship.

## Future Release scope

Expense Manager, Password Vault, Health Tracker, Inventory, OCR, functional AI, automation, cloud sync, Wear OS, desktop companion, foldable-specific features and functional third-party plugins. Version 1 may contain only explicitly approved isolated/inert boundaries.

## Security, backup and encryption

SQLCipher-compatible encrypted SQLite; AES-256-GCM for approved payloads/files/fields; Android Keystore-wrapped random master key; Argon2id encrypted-backup key derivation; no plaintext PIN/password; local versioned encrypted backups with integrity checks; no failed-PIN wipe. Crypto providers/algorithms must be replaceable without architectural redesign.

## Database decisions

Business/entity tables use the full lifecycle profile. Join, audit, FTS, cache, history and schema tables use purpose-appropriate columns. Foreign keys, transactions, rollback, migrations, indexed queries, repository-only asynchronous access, soft deletion and file metadata outside SQLite BLOBs are mandatory.

## Plugin, AI and theme decisions

Core never depends on plugins or AI. Plugins are default-deny and cannot directly access SQLite/files. AI is optional, isolated, provider-neutral and functionally Future Release. `#3F51B5` is only the default seed; Dynamic Color and full customization remain.

## Current status and blocker

Planning validation passed and Sprint 1 was authorized. The execution attempt stopped before generation because Flutter, Dart, Android SDK/ADB, Gradle and a JDK compiler were unavailable. No implementation file or database change exists. Sprint 2 is neither started nor authorized.

## Continue safely

1. Read [PROJECT_CONTINUATION_PROMPT.md](<PROJECT_CONTINUATION_PROMPT.md>) and [PROJECT_BIBLE_FINAL.md](<PROJECT_BIBLE_FINAL.md>).
2. Verify inventory/hashes in [PROJECT_INDEX.md](<PROJECT_INDEX.md>).
3. Install Flutter, compatible JDK, Android SDK command-line/platform/build/platform-tools, API 30 and approved target platform; accept licenses and configure environment variables.
4. Require a usable `flutter doctor -v` result.
5. Resume Sprint 1 from project setup, run a full gate after every logical task, stop after Sprint 1 and request approval.
