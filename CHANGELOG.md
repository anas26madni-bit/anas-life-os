# Changelog

All notable project changes are recorded here.

## [Unreleased]

No unreleased implementation changes.

## [0.4.0-sprint4] - 2026-08-07

### Added

- Complete offline Reminder Engine with normalized reminder and append-only
  history persistence, exact-alarm fallback, recurrence, snooze, missed-event
  detection, and reboot/time-change restoration
- Privacy-safe Android notification delivery with actions, vibration, optional
  voice, flash, full-screen presentation, and contextual permission handling
- Feature-first domain, repository, scheduler, use-case, Riverpod, typed route,
  and accessible English/Urdu UI layers
- Sprint 4 unit, widget, database, architecture, and Android 11 integration
  coverage

### Validation

- Formatter, source generation, analyzer, 51 automated tests, 94.69% business
  line coverage, 100% branch coverage, Android debug APK, and Android 11
  integration tests passed in GitHub Actions run `31151493154`.

## [0.3.0-sprint3] - 2026-08-05

### Added

- Complete Sprint 3 Task Engine with validated entities, CRUD, lifecycle,
  hierarchy, dependencies, categories, subcategories, tags, checklists,
  attachment metadata, recurrence definitions, history, and project ownership
- Atomic duplicate, clone, move, merge, and split operations
- Feature-first Clean Architecture layers with typed repositories, use cases,
  Riverpod controller, localized task UI, and typed task route
- Schema version 2 with normalized task-engine tables, foreign keys, indexes,
  soft-delete rules, versioning, counters, and migration coverage
- Approved minimal Android Keystore-wrapped SQLCipher database-key custody using
  a modular provider boundary
- Sprint 3 architecture, Product Owner decision, quality, and traceability
  documentation

### Validation

- Formatter, source generation, analyzer, unit/widget/database/architecture
  tests, coverage enforcement, Android debug APK, and Android 11 integration
  tests passed in GitHub Actions run `30984606293`.

## [0.2.0-sprint2] - 2026-07-30

### Added

- Sprint 2 encrypted Drift database foundation with the approved
  `anas_life_os.db` identity and schema versioning
- Purpose-specific lifecycle column profiles for business, history, and schema
  records
- Migration history and inert plugin registry tables with constrained fields
  and justified indexes
- Typed migration, plugin registry, and backup-metadata repository contracts
  with Drift implementations
- Transactional migration coordination with safe rollback and durable outcomes
- Replaceable database-key provider boundary and background encrypted file
  opener
- Sprint 2 schema, repository, migration, rollback, metadata, encryption, and
  architecture tests

### Validation

- Formatter, analyzer, source generation, unit/widget/database/architecture
  tests, coverage enforcement, Android debug build, and Android 11 integration
  tests are enforced by the Sprint 2 hosted quality workflow.

## [0.1.0-sprint1] - 2026-07-30

### Added

- Android-only Flutter project foundation for API 30 through API 36
- Clean Architecture foundation with Riverpod state composition and constrained
  `get_it`/`injectable` infrastructure bootstrap
- Structured privacy-safe local logging and typed failure/result primitives
- Material 3 light, dark, system, dynamic-color, custom-seed, and high-contrast
  foundations
- English and Urdu localization with RTL/LTR support
- Typed GoRouter foundation route and recoverable startup status
- SQLCipher in-memory capability, foreign-key, and integrity verification
- Modular cryptography, secure-storage, event, plugin, and AI contracts
- Unit, widget, integration, architecture-boundary, and coverage gates
- Local and GitHub quality-gate automation
- Sprint 1 architecture, dependency, test, and manual-validation documentation

### Validation

- Formatter, analyzer, source generation, unit/widget/database/architecture
  tests, 100% line and branch coverage enforcement, Android debug build, and
  Android 11 integration smoke test passed in the hosted quality pipeline.

## [0.0.0-documentation-baseline] - 2026-07-29

### Added

- Approved Project Bible Parts 1-11
- Complete project handover and continuation package
- Decision, open-issue, and traceability registers
- Development roadmap and sprint status
- Repository governance, security, conduct, and contribution policies
- Reserved workflow-governance baseline for Sprint 1 CI preparation

### Implementation status

- Documentation baseline only; superseded by the Sprint 1 foundation entries
  above.
