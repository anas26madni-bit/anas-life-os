# Pending Decisions

These are the remaining controlled decisions after applying the Final Validation resolutions. They do not authorize implementation and must be resolved before their owning feature/gate. None supersedes the current environment blocker.

## Part 2

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `OI-003` | Local user model: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | Part1A.UXF-001; Part4.P4-OI-018 |
| `OI-004` | Navigation hierarchy: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | Part 5 navigation model and P5-OI-010/022 |
| `OI-005` | Task invariants: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | TASK-001-010; Part 4 task invariants |
| `OI-006` | Project semantics: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | PROJ-001-004; Part 4 project/task relationships |
| `OI-007` | Reminder platform policy: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | REM-001-010; Android alarm/permission policy |
| `OI-008` | Calendar domain: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | CAL-001-007; Part4.P4-OI-019 |
| `OI-009` | Knowledge content model: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | KV-001-008; Part 4 knowledge schema |
| `OI-010` | Document ownership and preview: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | DOC-001-010; Part4.P4-OI-013; Part5.P5-OI-019 |
| `OI-011` | Offline voice services: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | REM-002; SEARCH-003; Part5/6 voice issues |
| `OI-012` | Search definition: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | SEARCH-001-009; Part 4 FTS/projection rules |
| `OI-013` | Statistics formulas: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | STAT-001-008; Part4.P4-OI-020 |
| `OI-014` | Security threat model: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | Part1A.SEC-001-003; Parts 3/4/10 security |
| `OI-015` | App-lock policy: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | Part1A.LCK-001-002; SEC-001-006; Sprint 10 |
| `OI-016` | Backup and restore policy: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | BACK-001-006; Part 4 backup/restore; Sprint 9 |
| `OI-017` | Plugin lifecycle: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | PLUGIN-001-008; Part 9 lifecycle/security |
| `OI-018` | Android platform policy: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | Part1A.AND/NAT; Parts 5/10 Android policy |
| `OI-019` | Localization and accessibility: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | Part1A.UIA/QAT; Parts 5/7/8 |
| `OI-020` | Performance budgets: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | NFR-PERF/BAT/MEM; Parts 3/7/11 |
| `OI-021` | Testing and evidence: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | Part1A.QAT-001-003; Parts 6/7/11 |
| `OI-023` | Database semantics: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | Part1A.DBR-003-005; Part 4 semantics |
| `OI-024` | Secure erasure: Decision scope retained by the owning Master. | Partially resolved | Product Owner + Lead Architect | NFR-DB-003; Part4.P4-OI-002; Part5.P5-OI-018 |
| `OI-025` | Diagnostics and maintenance: Decision scope retained by the owning Master. | Pending Decision | Product Owner + Lead Architect | SET-008; Part 4 diagnostics; Part5.P5-OI-023 |

## Part 4

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `P4-OI-002` | Soft delete versus purge: Classify user records, append-only history, caches, queues, previews, logs, temporaries, recycle expiry, and secure erasure. | Partially resolved | Database Architect + Security Architect | NFR-DB-003;OI-024 |
| `P4-OI-004` | Duplicate and alias tables: Resolve Dependencies/task_dependencies, RecurringRules/repeat_rules, SecuritySettings/security_settings, Plugins/plugin_registry, Logs/Errors, Settings, and MigrationHistory aliases. | Pending Decision | Database Architect + Security Architect | Part 4 inventory;no-duplicates rule |
| `P4-OI-005` | Subtask representation: Choose tasks.parent_task_id or sub_tasks and define depth, order, mandatory flag, progress, delete, and restore. | Pending Decision | Database Architect + Security Architect | TASK-001;OI-005 |
| `P4-OI-006` | Reminder ownership: Align reminders, event_reminders, notification_queue, and scheduler identity for task/event ownership. | Pending Decision | Database Architect + Security Architect | REM;CAL;OI-007-008 |
| `P4-OI-007` | Knowledge projections: Classify backlinks, favorites, graph, counts, and FTS as authoritative or rebuildable. | Pending Decision | Database Architect + Security Architect | KV;OI-009 |
| `P4-OI-008` | Task state/archive/delete: Prevent divergence among status, STATE-008/009, is_archived, is_deleted, and deleted_at. | Pending Decision | Database Architect + Security Architect | TASK-003-005;STATE-001-009 |
| `P4-OI-009` | Workflow scope: Workflow templates are absent from approved Version 1 scope; confirm Future Release or approve a Part 2 change. | Pending Decision | Database Architect + Security Architect | 4B;Part 2 Master |
| `P4-OI-010` | Event bus semantics: Define outbox atomicity, order, idempotency, retry, poison events, versioning, privacy, retention, and recovery. | Pending Decision | Database Architect + Security Architect | 4F;OI-025 |
| `P4-OI-011` | Mandatory subtasks: Completion rule requires a mandatory marker and exception policy not defined in schema. | Pending Decision | Database Architect + Security Architect | TASK-001;4B |
| `P4-OI-012` | Dependency graph: Define cycles, deleted/archived dependencies, cross-project edges, status, and dependency-type semantics. | Pending Decision | Database Architect + Security Architect | TASK-001;4B |
| `P4-OI-013` | Attachment ownership and deduplication: Approve owner cardinality and physical-file sharing/content-addressed strategy; current columns permit multiple owners. | Pending Decision | Database Architect + Security Architect | DOC;OI-010 |
| `P4-OI-014` | Folder cycles and depth: Define cycle prevention, moves, name uniqueness, delete/restore, and practical depth. | Pending Decision | Database Architect + Security Architect | KV-003;DOC folders |
| `P4-OI-015` | Recurrence model: Define timezone/DST, custom encoding, invalid dates, series edits, and occurrence identity. | Pending Decision | Database Architect + Security Architect | TASK-001;REM-006 |
| `P4-OI-016` | FTS encryption: Approve searchable protected content without plaintext leakage to FTS, snippets, WAL, backups, or temporaries. | Pending Decision | Database Architect + Security Architect | SEARCH;SEC-004 |
| `P4-OI-018` | Single-user audit identity: Define created_by, updated_by, performed_by, owner_name, device_id, and ip_address in a no-account offline product. | Pending Decision | Database Architect + Security Architect | Local user model;OI-003 |
| `P4-OI-019` | Calendar schema: Events, participants, and reminders lack dictionaries, recurrence, timezone, and ownership constraints. | Pending Decision | Database Architect + Security Architect | CAL;OI-008 |
| `P4-OI-020` | Statistics projections: Define formulas, timezone boundaries, rebuild source, corrections, retention, and materialization. | Pending Decision | Database Architect + Security Architect | STAT;OI-013 |
| `P4-OI-021` | Custom fields: Define types, validation, owners, uniqueness, order, indexing, deletion, and historical preservation. | Pending Decision | Database Architect + Security Architect | TASK-001;OI-005 |
| `P4-OI-022` | Counters: Define authority and transaction behavior for task/note counters under rollback, restore, merge, split, and import. | Pending Decision | Database Architect + Security Architect | TASK-006-010;KV |
| `P4-OI-023` | Retention and growth: Define budgets for histories, versions, audit, errors, events, queues, previews, search history, recycle bin, and backups. | Pending Decision | Database Architect + Security Architect | PER;OI-020/025 |

## Part 5

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `P5-OI-003` | Controller/provider/viewmodel overlap: Define non-overlapping presentation roles and when each folder is required; otherwise the prescribed feature template duplicates responsibility. | Pending Decision | Application Architect + UX Lead | Part 5 feature structure;NFR-CODE |
| `P5-OI-004` | Dynamic Flutter plugins: Flutter Android AOT cannot load arbitrary new Dart code at runtime. Approve whether plugins are build-time packaged modules with runtime enablement or a separately engineered future mechanism. | Pending Decision | Application Architect + UX Lead | PLUGIN-001-008;Part 5 plugin system |
| `P5-OI-005` | Plugin migrations and lifecycle: Define namespace, signing, compatibility, rollback, permission, enable/disable, uninstall, migration ordering, failure isolation, and backup/restore behavior. | Pending Decision | Application Architect + UX Lead | Part 2 OI-017;Part 4 plugin records |
| `P5-OI-007` | Offline voice scope: Separate Version 1 voice notes, reminders, and voice search from future assistant commands; approve offline engine, models, permissions, languages, and fallback. | Pending Decision | Application Architect + UX Lead | SEARCH-003;OI-011;voice-ready clauses |
| `P5-OI-008` | WorkManager versus exact alarms: Approve the scheduling matrix for exact reminders, repeating reminders, missed detection, backups, indexing, previews, diagnostics, and maintenance across Android 11-14+. | Pending Decision | Application Architect + UX Lead | REM;NFR-BAT;Part 11 Sprint 4 |
| `P5-OI-009` | Package governance: Approve supported versions and replacement policy for Riverpod, GoRouter, Drift, get_it, injectable, Freezed, serializers, Workmanager, and local notifications. | Pending Decision | Application Architect + UX Lead | MNT-002;P5-ARCH-029 |
| `P5-OI-010` | Navigation hierarchy: Define distinct responsibilities for bottom navigation, side drawer, More, universal search, quick actions, FAB, phone/tablet/foldable adaptation, and plugin destinations. | Pending Decision | Application Architect + UX Lead | Part 2 OI-004;P5-DS-032 |
| `P5-OI-011` | Grid and spacing semantics: The source says 8dp base grid but permits 4dp increments including 12 and 20. Approve whether 4dp is the atomic unit and 8dp the primary rhythm. | Pending Decision | Application Architect + UX Lead | Part 5B-5C |
| `P5-OI-012` | Hover state on Android: Determine whether hover is required only for pointer-equipped tablets/foldables and future desktop, not as a Version 1 phone acceptance requirement. | Pending Decision | Application Architect + UX Lead | Part 5C component states |
| `P5-OI-013` | Material Symbols exceptions: Define permitted branded, file-type, plugin, user-provided, and accessibility icon exceptions while retaining consistent tokens and no emoji UI icons. | Pending Decision | Application Architect + UX Lead | Part 5B-5C |
| `P5-OI-014` | Illustrations in every empty state: Confirm where illustrations are appropriate, asset-size limits, dark/RTL treatment, alt semantics, and whether a text/action empty state is acceptable. | Pending Decision | Application Architect + UX Lead | Part 5B-5C |
| `P5-OI-015` | Shimmer and motion accessibility: Approve reduced-motion behavior, shimmer alternatives, animation cancellation, screen-reader announcements, and reminder animation safety. | Pending Decision | Application Architect + UX Lead | P5-DS-008/009/016 |
| `P5-OI-016` | Three-action rule: Define the Version 1 common-action list, start/end points, safety exceptions, accessibility paths, and measurement method. | Pending Decision | Application Architect + UX Lead | Part 5B UI rules |
| `P5-OI-017` | Incomplete source screen contracts: The source declares every screen must define layout, navigation, permissions, states, accessibility, AI point, and acceptance, but most screens provide only component lists. | Pending Decision | Application Architect + UX Lead | Part 5D quality gate |
| `P5-OI-019` | Offline Office preview: Define which DOC/DOCX/XLS/XLSX/PPT/PPTX formats can be safely rendered offline, fidelity expectations, malformed-file handling, and fallback behavior. | Pending Decision | Application Architect + UX Lead | SCREEN-061;DOC-004-005/009;OI-010 |
| `P5-OI-020` | Deep-link privacy: Define accepted offline URI schemes, locked-state routing, malformed inputs, path traversal protection, and whether external app links exist without network support. | Pending Decision | Application Architect + UX Lead | P5-ARCH-005;SEC threat model |
| `P5-OI-021` | Missing functional screens: Part 2 functions lack explicit create/edit screens for projects/events, reminder center/history, saved searches, merge/split workflows, and several settings/details flows. Approve whether they are screens, dialogs, sheets, or embedded flows. | Pending Decision | Application Architect + UX Lead | Part 2 Master;Part 5D |
| `P5-OI-022` | Adaptive navigation: Approve phone, tablet, foldable, landscape, split-screen, and large-font navigation breakpoints while preserving approved navigation components. | Pending Decision | Application Architect + UX Lead | NFR-UI-005;P5-DS-029/032 |
| `P5-OI-023` | Diagnostics privacy: Define which local logs, errors, storage values, database metadata, export actions, and maintenance controls are safe to expose through SCREEN-140. | Pending Decision | Application Architect + UX Lead | SCREEN-140;P4-RULE-017 |

## Part 6

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `P6-OI-002` | Performance and resource thresholds: Approve device profiles and quantitative performance, memory and battery thresholds. | Partially resolved | Engineering Governance Lead | NFR-PERF/BAT/MEM;OI-020/026 |
| `P6-OI-003` | Per-feature test applicability: Define when widget, integration, golden, performance and battery tests may be Not Applicable. | Pending Decision | Engineering Governance Lead | QAT;STEP 9-20;OI-021 |
| `P6-OI-004` | Documentation locations: Approve locations and formats for architecture records, interface docs, change log and migration notes. | Pending Decision | Engineering Governance Lead | LAW 9;P6A-DOC-001 |
| `P6-OI-006` | Settings completion ownership: Confirm Settings screen assembly and final acceptance ownership across distributed sprints. | Pending Decision | Engineering Governance Lead | PHASE 10;SET-001-008 |
| `P6-OI-007` | Offline voice scope: Approve offline voice engine, languages, permissions and fallback for reminders and search. | Pending Decision | Engineering Governance Lead | REM-002;SEARCH-003;OI-011 |
| `P6-OI-008` | Technical-debt exception process: Define whether emergency exceptions are prohibited or require time-bounded approval. | Pending Decision | Engineering Governance Lead | LAW 3;Part 11 |
| `P6-OI-009` | Architecture decision records: Approve threshold and template for an architectural change requiring ADR and master update. | Pending Decision | Engineering Governance Lead | LAW 9-10 |

## Part 7

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `P7-OI-004` | Performance thresholds: Approve quantitative warm-start, memory, CPU, battery and frame-jank limits. | Partially resolved | QA Lead | P6-OI-002;OI-020 |
| `P7-OI-005` | Test applicability waivers: Define who approves Not Applicable and required evidence. | Pending Decision | QA Lead | P6-OI-003 |

## Part 8

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `P8-OI-001` | Caption token mapping: Approve the Material 3 token used for Caption. | Pending Decision | Design System Lead | P8-TYPE-001 |
| `P8-OI-002` | Breadcrumb applicability: Define which Version 1 phone flows, if any, require breadcrumbs. | Pending Decision | Design System Lead | P8-NAV-001;OI-004 |
| `P8-OI-003` | Visual token values: Approve exact brand colors, radii, elevations, opacity and motion values not already fixed by Part 5. | Partially resolved | Design System Lead | P8-LANG/COLOR/TOKEN |
| `P8-OI-004` | Reduce Motion policy: Approve detection, setting override and animation substitutions. | Pending Decision | Design System Lead | P8-MOTION-001 |

## Part 9

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `P9-OI-001` | Runtime and isolation model: Select Android/Flutter-compatible packaging, loading, process and sandbox strategy. | Pending Decision | Plugin/AI Architect + Security Lead | P5-OI plugin feasibility;P9-SEC-001 |
| `P9-OI-002` | Plugin trust and distribution: Define signing, provenance, installation source, update and revocation policy. | Pending Decision | Plugin/AI Architect + Security Lead | P9-LIFE/SEC |
| `P9-OI-003` | Permission enforcement: Define granular grant storage, prompting, revocation and interface enforcement. | Pending Decision | Plugin/AI Architect + Security Lead | P9-PERM-001 |
| `P9-OI-004` | Plugin data lifecycle: Define ownership, uninstall preservation, backup, migration and orphaned-data recovery. | Pending Decision | Plugin/AI Architect + Security Lead | P9-BACK-001;recoverability |
| `P9-OI-005` | Local analytics boundary: Confirm future Analytics means private on-device analysis and never telemetry by default. | Pending Decision | Plugin/AI Architect + Security Lead | Part 2 no tracking;P9-TYPE-001 |
| `P9-OI-006` | Future AI consent and data flow: Define provider consent, disclosure, redaction, retention and network boundary before any AI release. | Pending Decision | Plugin/AI Architect + Security Lead | P9-AI/ANAS;LAW 4/17 |

## Part 10

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `P10-OI-004` | Dependency lifecycle policy: Approve lockfile, update cadence, vulnerability response, abandonment and replacement rules. | Pending Decision | CTO + Release/Security Lead | LAW 11;P5-OI-002 |

## Part 11

| ID | Decision | Status | Owner | Dependency / traceability |
|---|---|---|---|---|
| `P11-OI-003` | Reminder platform policy: Approve exact-alarm, full-screen, permission, OEM battery and offline voice behavior before Sprint 4. | Pending Decision | Program Manager + Scrum Master | OI-007/018;P7-REM |
| `P11-OI-004` | Calendar domain: Approve event/task semantics and acceptance before Sprint 6. | Pending Decision | Program Manager + Scrum Master | OI-008;CAL-001-007 |
| `P11-OI-005` | Statistics formulas: Approve formulas and historical recomputation rules before Sprint 8. | Pending Decision | Program Manager + Scrum Master | OI-013;STAT-001-008 |
| `P11-OI-007` | Settings assembly ownership: Confirm SCREEN-110 assembly and final acceptance across distributed sprints. | Pending Decision | Program Manager + Scrum Master | P6-OI-006;SET-001-008 |

## Clarification register treatment

The 38 Part 1A questions are preserved in `clarifications/`. Their approved/remaining substance is carried into the Master open issues above; they are not duplicated as a second authority.
