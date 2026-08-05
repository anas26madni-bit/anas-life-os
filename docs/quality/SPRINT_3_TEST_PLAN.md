# Sprint 3 Test Plan

Status: Complete

## Automated gates

1. Format all Dart sources and verify no formatter drift.
2. Generate Drift and typed-route sources.
3. Run Flutter analyzer with zero warnings or errors.
4. Run unit, widget, architecture, schema, migration, and integration tests.
5. Generate coverage and enforce the approved project threshold where applicable.
6. Build the Android debug APK.
7. Scan for forbidden TODO/FIXME markers, direct UI database access, hardcoded secrets, and accidental Sprint 10 authentication features.

## Required behavior evidence

- Task validation and normalization.
- CRUD, soft delete, restore, pagination, versioning, and history.
- Mandatory-subtask and dependency enforcement.
- Clone, move, merge, and split transaction behavior.
- Project deletion safety.
- Category, tag, checklist, attachment metadata, checksum reuse, and recurrence validation.
- Schema tables, indexes, foreign keys, migration integrity, and encrypted database opening boundary.
- Loading, error, empty, populated, English, Urdu/RTL, theme, and accessibility widget states.

## Manual Android checks

- First launch creates a persistent encrypted database without exposing key material.
- Relaunch opens the same database and retains tasks.
- A task can be created, completed, archived, deleted, and restored without a crash.
- English and Urdu layouts remain readable at increased font scale.
- Airplane mode does not affect Task Engine behavior.
- Process death and relaunch preserve data.

Manual device evidence is required before a release candidate; automated Android build and integration evidence are required before Sprint 3 completion.

## Automated results

- Formatting: passed.
- Source generation: passed.
- Analyzer: passed with zero warnings or errors.
- Unit, widget, database, and architecture tests: passed.
- Coverage enforcement: passed.
- Android debug APK: built successfully.
- Android 11 integration tests: passed.
- Evidence: GitHub Actions run `30984606293`.
