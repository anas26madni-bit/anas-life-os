# Sprint 3 Task Engine Architecture

Status: Complete and quality-gate verified  
Scope owner: Part 11, Sprint 3

## Delivered boundary

Sprint 3 implements the Task Engine vertical slice: normalized task data, task and project repositories, typed validation, task state transitions, hierarchy, dependencies, categories, tags, checklists, attachment metadata, recurring-rule definitions, task composition operations, a localized task list, and automated tests.

Reminder scheduling, notification delivery, attachment preview/storage management, global search, statistics, backup, authentication, and security UI are outside this sprint.

## Layering

Presentation depends on task use cases and Riverpod controllers. Domain contracts contain no Flutter, Drift, Android, or storage dependencies. Drift repositories implement domain contracts and own transactions. The shared AppDatabase remains the only SQLite access boundary. UI code never executes SQL.

## Database-key custody sequencing exception

The approved exception moves only durable SQLCipher key custody into Sprint 3. Android creates a random 256-bit database key, wraps it using a non-exportable AES-256-GCM Android Keystore key, and stores ciphertext and IV in private application preferences. Flutter receives the unwrapped database key only through the database platform interface when opening the persistent SQLCipher database in the no-backup directory.

The cryptographic provider boundary is modular: the database opener depends on `DatabaseKeyProvider`, not Android Keystore or a concrete algorithm. A future provider or algorithm can replace the current implementation without changing task, repository, or database architecture.

No PIN, biometric, app lock, hidden-item, secure-media, authentication-flow, or security-UI behavior is implemented in Sprint 3.

## Data integrity

All business mutations are transactional, versioned, soft-delete aware, and history producing. Foreign keys are enabled. Hierarchy cycles, depth above eight, dependency cycles, invalid task ranges, invalid recurrence metadata, and completion with unfinished mandatory children are rejected with typed failures.

Cached counters are maintained in the same transaction as their source rows. Attachment checksum reuse prevents duplicate physical-content paths while retaining separate task associations.

## Verification record

GitHub Actions run `30984606293` passed formatting, source generation, analyzer,
unit/widget/database/architecture tests, coverage enforcement, Android debug APK
build, and Android 11 integration tests.
