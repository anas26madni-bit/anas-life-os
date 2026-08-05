# Sprint 3 Product Owner Decisions

Status: Approved engineering resolution  
Date: 2026-07-30  
Owner: Product Owner authorization; Lead Architect resolution

This document resolves only the nine Sprint 3 open issues explicitly delegated by the Product Owner. It records implementation semantics without modifying the approved Project Bible.

## OI-005 — Task invariants

Tasks use validated typed values. Titles are trimmed and contain 1–300 Unicode characters; progress is 0–100; durations are non-negative; due cannot precede start. Completion sets progress to 100 and records completion time; leaving Completed clears it. Mutations are atomic, versioned, and recorded in state history. Duplicate creates a new standalone task without history; clone copies the selected child graph. Merge and split are transactional and never reuse identities.

Rationale: central invariants prevent invalid combinations at every entry point while preserving approved operations.

Traceability: `OI-005`; TASK-001–010; Part 4 task/state rules; Part 11 Sprint 3.

## OI-006 — Project semantics

A task belongs to zero or one project. Projects are single-user containers, not collaboration identities. Project title is required; progress is derived from active tasks; budget is a non-negative minor-unit amount with optional ISO 4217 currency. Projects with active tasks cannot be deleted but may be archived. Moving tasks is atomic and preserves identity/history.

Rationale: optional ownership supports inbox tasks and preserves referential integrity without duplicated progress truth.

Traceability: `OI-006`; PROJ-001–004; TASK-008; Part 4 project relationships.

## P4-OI-005 — Subtask representation

Subtasks use canonical `tasks.parent_task_id`; no `sub_tasks` table is created. Children have `sort_order` and `is_mandatory`. Validation prevents self-parenting, cycles, and depth beyond eight. Deleting a parent soft-deletes active descendants transactionally. Restore is ancestor-first and fails safely if an ancestor cannot be restored.

Rationale: one task representation supports uniform history, attachments, recurrence, and nesting without duplicate tables.

Traceability: `P4-OI-005`; TASK-001; Part 4 no-duplicate-table rule.

## P4-OI-008 — State, archive, and delete authority

`tasks.status` is authoritative: Draft, Scheduled, Pending, InProgress, Waiting, Blocked, Completed, Archived, Deleted. `is_deleted` and `deleted_at` are lifecycle enforcement columns updated atomically with Deleted. Archived has no independent flag. Restore uses the recorded pre-delete state, defaulting to Pending only when history is unavailable.

Rationale: one state authority prevents divergence while lifecycle columns provide efficient recycle filtering.

Traceability: `P4-OI-008`; TASK-003–005; STATE-001–009; NFR-DB-003.

## P4-OI-011 — Mandatory subtasks

`is_mandatory` is meaningful only for child tasks. A parent cannot become Completed while any active mandatory child is not Completed. Version 1 has no silent override; the user must complete, make optional, or soft-delete the blocker through a recorded mutation.

Rationale: deterministic enforcement satisfies the approved completion rule and preserves intent.

Traceability: `P4-OI-011`; TASK-001; Part 4B mandatory-subtask rule.

## P4-OI-012 — Dependency graph

Use one `task_dependencies` table with unique directed pairs and typed FinishToStart, StartToStart, FinishToFinish, or StartToFinish relations. Reject self-edges, duplicates, and cycles transactionally. Cross-project edges are allowed. Edges involving deleted tasks are inactive but retained for recovery. Invalid transitions return typed failures.

Rationale: a DAG supports approved relationship types without making projects hidden execution boundaries.

Traceability: `P4-OI-012`; TASK-001; Part 4B dependency types.

## P4-OI-015 — Recurrence semantics

`repeat_rules` stores typed frequency, positive interval, weekday bit mask, optional day/month, timezone identifier, end condition/date, and occurrence limit. Validation is independent of scheduling. Invalid dates are skipped. Occurrences retain series UUID and immutable instant. Series edits version the rule and affect future non-completed occurrences. DST preserves wall time; nonexistent times advance to the first valid instant and ambiguous times choose the earlier instant.

Rationale: deterministic offline behavior keeps Sprint 3 data rules separate from Sprint 4 scheduling.

Traceability: `P4-OI-015`; TASK-001; REM-006; Part 11 Sprints 3–4.

## P4-OI-021 — Custom fields

Definitions are scoped to Task or Project with typed text, integer, decimal, boolean, date, datetime, singleSelect, or multiSelect values. Definitions include label, required flag, order, validation metadata, and normalized choices. Values are unique per definition/entity and validated before persistence. Soft-deleted definitions preserve history. Search indexing is opt-in and deferred to Sprint 7.

Rationale: normalized definitions avoid sparse schema changes and unvalidated JSON while preserving search control.

Traceability: `P4-OI-021`; TASK-001; PROJ-001; Part 4 custom-field tables.

## P4-OI-022 — Derived counters

Attachment, subtask, checklist, comment, voice-note, and custom-field counters are rebuildable caches, not authoritative facts. Repository transactions update them with source rows; rollback restores both. Restore, merge, split, and import recalculate affected counts. Domain APIs never accept arbitrary counters.

Rationale: cached counts support list performance without changing business truth.

Traceability: `P4-OI-022`; TASK-006–010; NFR-PERF; Part 4 counter columns.

## Quality constraints

- Repository mutations are transactional and never block the UI isolate.
- Domain validation is shared by every entry point.
- Foreign keys and indexes are verified by schema tests.
- Soft delete, state history, rollback, hierarchy, and dependency cycles require automated tests.
- These decisions authorize no Sprint 4 scheduling or Future Release capability.
## Approved sequencing exception — database-key custody

The Product Owner approved moving only persistent SQLCipher database-key generation, Android Keystore wrapping, secure retrieval, and production encrypted database opening from Sprint 10 into Sprint 3. The native provider creates a non-exportable AES-256-GCM wrapping key in Android Keystore, wraps a randomly generated 256-bit SQLCipher key, stores only ciphertext and IV in private application preferences, and fails closed if an existing wrapped key cannot be decrypted. The database file is stored in the app no-backup directory. PIN, biometric authentication, app lock, hidden items, secure notes/media, security UI, authentication flows, and all other security policy remain Sprint 10.

Rationale: Sprint 3 requires durable encrypted CRUD; delaying key custody would make task data unrecoverable or force insecure key storage. Moving the smallest provider boundary preserves the approved architecture and Sprint 10 ownership. The database opener depends on a replaceable key-provider contract, so future cryptographic providers or algorithms can be substituted without redesigning application architecture.

Traceability: Product Owner approval 2026-07-30; NFR-SEC-001; Part 4 encrypted SQLite decision; Part 11 Sprint 3 Task Engine and Sprint 10 Security.