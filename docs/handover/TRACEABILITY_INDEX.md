# Traceability Index

## Authority chain

| Source | Primary downstream consumers |
|---|---|
| Part 1 / 1A / 1B | Parts 2, 4, 5, 6 and 10 |
| Part 2 functional IDs | Parts 4, 5, 7, 8, 9 and 11 |
| Part 3 NFR IDs | Parts 4-8, 10 and 11 |
| Part 4 database IDs | Parts 5-7, 9-11 |
| Part 5 architecture/screens | Parts 6-11 |
| Part 6 execution laws | Parts 7, 10 and 11 |
| Part 7 quality gates | Parts 8-11 |
| Parts 8-10 | Part 11 sprint acceptance |
| Part 11 | All target-sprint assignments |

## Identifier rule

Canonical global identity is `DocumentPart.ID`. Bare collisions such as Part1A/Part1B/Part2 `SEC-001`-`SEC-003` are valid locally and resolved by qualification. The 38 Part 1A IDs intentionally mirror Part 1B.

## Part 1A clarification groups

- Product scope: `PRD-001`-`PRD-003` - Part 2 scope/Future Release and roadmap.
- Users/workflows: `UXF-001`-`UXF-002` - Part 2 UX/open issues; Parts 4-5.
- Android: `AND-001`-`AND-002` - Part 1 platform/signing; Parts 5/10/11.
- Native scheduling: `NAT-001`-`NAT-002` - Part 2 reminders; Parts 4-7.
- Extensions: `EXT-001`-`EXT-002` - Parts 5 and 9.
- Database: `DBR-001`-`DBR-006` - Part 4.
- Security: `SEC-001`-`SEC-003`, `LCK-001`-`LCK-002` - Parts 1/3/4/10.
- Data lifecycle: `DAT-001`-`DAT-003` - Parts 2/4/9/10.
- UI/accessibility: `UIA-001`-`UIA-003` - Parts 5/7/8.
- Performance/recovery: `PER-001`-`PER-002` - Parts 3/4/7.
- QA: `QAT-001`-`QAT-003` - Parts 4-7/10/11.
- Maintainability: `MNT-001`-`MNT-003` - Parts 5/6/10.
- Gate: `GAT-001`-`GAT-002` - approval history and Part 4 source.

## Functional-to-architecture map

| Functional domain | Part 2 IDs | Database / architecture | Sprint |
|---|---|---|---|
| Dashboard | `DASH-001`-`003` | Part 5 dashboard/design; Part 4 activity/stats | 6 |
| Tasks | `TASK-001`-`010` | Part 4 task/state/dependency tables; Part 5 task screens | 3 |
| Projects | `PROJ-001`-`004` | Part 4 projects; Part 5 project screens | 3/6 |
| Reminders | `REM-001`-`010` | Part 4 reminders/history; Kotlin/notifications | 4 |
| Calendar | `CAL-001`-`007` | Part 4 event domain; Part 5 calendar screen | 6 |
| Knowledge Vault | `KV-001`-`008`, `DOC-001`-`010` | Part 4 knowledge/documents/attachments; Part 5 screens | 5 |
| Search | `SEARCH-001`-`009` | Part 4 FTS/projections; Part 5 service/screen | 7 |
| Statistics | `STAT-001`-`008` | Part 4 projections; Part 5 dashboard | 8 |
| Backup | `BACK-001`-`006` | Part 4 backup/restore; crypto boundary | 9 |
| Security | `SEC-001`-`006` | Part 4 security/audit; Kotlin/Keystore | 10 |
| Settings | `SET-001`-`008` | Distributed owning sprints; final regression 12 | 1-12 |
| Plugin manager | `PLUGIN-001`-`008` | Inert boundaries only; Part 9 | Future Release behavior |
| Health | `HEALTH-001` | Excluded from Version 1 | Future Release |

## NFR traceability

Part 3 preserves 60 IDs: `NFR-PERF-*`, `BAT-*`, `MEM-*`, `DB-*`, `SEC-*`, `OFF-*`, `UI-*`, `ERR-*`, `CODE-*`, `FUTURE-*`. Each contains Priority, Complexity, Verification, Target Sprint and Traceability. Parts 4-11 consume these criteria.

## Roadmap traceability

Part 11 is the only sprint authority: Sprint 1 foundation; 2 database; 3 tasks/projects; 4 reminders; 5 Knowledge Vault/documents; 6 dashboard/calendar; 7 search; 8 statistics; 9 backup; 10 security; 11 optimization; 12 release candidate.

## Explicit Part 1A / Part 1B ID inventory

`PRD-001` `PRD-002` `PRD-003` `UXF-001` `UXF-002` `AND-001` `AND-002` `NAT-001` `NAT-002` `EXT-001` `EXT-002` `DBR-001` `DBR-002` `DBR-003` `DBR-004` `DBR-005` `DBR-006` `SEC-001` `SEC-002` `SEC-003` `LCK-001` `LCK-002` `DAT-001` `DAT-002` `DAT-003` `UIA-001` `UIA-002` `UIA-003` `PER-001` `PER-002` `QAT-001` `QAT-002` `QAT-003` `MNT-001` `MNT-002` `MNT-003` `GAT-001` `GAT-002`
