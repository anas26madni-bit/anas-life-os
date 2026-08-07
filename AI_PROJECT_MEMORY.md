# AI Project Memory

## Project Vision
Anas Life OS is an Android-only, privacy-first personal life management system. It works offline by default, requires no account, cloud, advertisements, analytics, or tracking, and keeps user data on-device. Version 1 targets Android 11+ and long-term maintainability.

## Architecture Summary
Use feature-first Clean Architecture with presentation, domain, and data boundaries. UI calls ViewModels/providers, use cases, repository contracts, data sources, and Drift only inward. Use Riverpod, typed GoRouter routes, get_it with Injectable, immutable models, typed failures/results, Material 3, and a Kotlin Android host. Core never depends on plugins, AI, network access, or future modules.

## Coding Standards
Apply SOLID, DRY, KISS, and YAGNI. Keep responsibilities narrow, names explicit, functions small, and files preferably below 400 lines. No dead or duplicated code, TODO, FIXME, commented-out code, generic exception handling, magic values, hardcoded user strings, secrets, or temporary workarounds. Comments explain why.

## Folder Rules
Shared foundations belong in app/lib/core. Feature code belongs in app/lib/features/<feature>/{data,domain,presentation}. Domain must not import Flutter, Drift, Android, or data-layer types. Database access occurs only through repository/data-source implementations. Tests mirror ownership under app/test and app/integration_test.

## Naming Conventions
Use PascalCase for types, camelCase for members, snake_case for Dart files/folders and database identifiers, plural snake_case table names, and *_id foreign keys. Preserve approved requirement IDs in traceability and tests.

## Dependency Rules
Use approved packages and locked versions. Before adding or upgrading a dependency, document purpose, alternatives, security/maintenance/platform risks, replacement strategy, and test impact. Dependencies point inward. Never add direct UI-to-database, plugin-to-database, feature cycles, or vendor-specific AI coupling.

## Git Workflow
Start from the latest verified released tag or approved baseline. Use a codex/ branch unless directed otherwise. Keep commits scoped. Never rewrite released history or commit secrets, signing material, or local configuration. Format, analyze, test, build, update documentation/traceability, commit, push, and verify Actions before closing a sprint. Production signing keys remain user-only.

## Sprint Rules
Part 11 owns scope and order. Implement the current authorized sprint one vertical slice at a time, including database, logic, UI where applicable, tests, documentation, performance, security, accessibility, and offline verification. Do not begin a later sprint before gates pass. Future Release capabilities never enter Version 1 without an approved requirements change.

## Common Mistakes to Avoid
Never bypass repositories, put business logic in widgets, block the UI isolate, query unindexed searchable data, hard-delete recoverable business records, log secrets, request permissions early, duplicate tables/components, mix future features into Version 1, guess ambiguous rules, or claim unexecuted tests passed.

## Important Decisions
Application ID: com.anaslifeos.app. Minimum SDK: 30. Database: anas_life_os.db through Drift with SQLCipher-compatible SQLite. Business/entity tables use complete lifecycle fields; join, audit, FTS, cache, history, and schema tables use purpose-appropriate fields. Use AES-256-GCM, Android Keystore-wrapped master key, Argon2id backup keys, and replaceable crypto providers. Version 1 has no failed-PIN wipe. Default theme seed is #3F51B5 with dynamic color and user customization. Knowledge Vault owns Notes, Journal, Wiki, and Documents.

Sprint 7 search uses local FTS5 inside SQLCipher and is available only through
a verified opened database session. It indexes authorized tasks, projects,
notes, documents, and attachment metadata; supports Urdu/English mixed text,
structured filters and saved queries, and deterministic title-weighted ranking.
No plaintext snippets are persisted. Voice search is explicit tap-to-use,
on-device Urdu/English only, with runtime microphone permission and typed
fallback; online voice, wake words, OCR, and command execution remain future.

## Things Never To Change
Never modify an approved Project Bible master without owner approval. Never weaken offline privacy, local data ownership, Clean Architecture, database-first sequencing, soft-delete policy, cryptographic modularity, accessibility, localization/RTL, traceability, or quality gates. Never require cloud, login, analytics, advertising, or tracking for core functionality.

## AI Instructions
The Project Bible is the requirements authority; this file is stable operational memory only. Read owning master sections before changes. Preserve released behavior and user work. Make evidence-based decisions within scope. Stop only for a genuine unresolved decision, external authority, or technical limitation. Never fabricate status, tests, commits, releases, or performance evidence.

## Resume Rules
Verify repository, branch, latest approved commit/tag, clean state, checkpoint, Project Bible, pending decisions, and sprint authorization before editing. Continue from the checkpoint without recreating work. Run applicable generation, format, analyzer, unit, widget, database, architecture, integration, coverage, build, performance, security, accessibility, offline, and regression gates. Record evidence and never cross scope.
