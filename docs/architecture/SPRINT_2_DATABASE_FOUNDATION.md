# Sprint 2 database foundation

Sprint 2 implements only the database foundation assigned by Part 11. It does
not introduce task, project, reminder, Knowledge Vault, search, statistics,
backup execution, security UI, or other later-sprint functionality.

## Implemented boundaries

- `AppDatabase` owns the Drift schema and connection-level integrity checks.
- `DatabaseConnectionFactory` configures SQLCipher before Drift accesses the
  database and enables foreign keys, cipher memory protection, and a bounded
  busy timeout.
- `DatabaseKeyProvider` is replaceable. Android Keystore key custody remains
  isolated for its approved security sprint.
- Production file connections use Drift's background executor. Unit tests use
  encrypted in-memory connections.
- Domain repository contracts do not depend on Drift or Flutter.
- Drift repository implementations are the only consumers of generated tables.

## Schema version 1

`migration_history` implements P4-TBL-076. It records sequential migration
identity, version boundaries, timestamps, and sanitized outcomes.

`plugin_registry` implements the inert descriptor storage assigned to Sprint 2
by P4-TBL-078. It does not load plugins, grant permissions, execute plugin code,
or resolve the pending plugin lifecycle decisions.

Business/entity lifecycle columns are defined once for later owning tables.
History and schema records use only purpose-appropriate profiles.

## Migration safety

Migration work runs inside a transaction. Integrity and foreign-key checks run
before commit. An injected failure rolls back schema/data changes while the
history record is marked failed without storing sensitive exception content.
Unknown automatic schema upgrades fail closed until an approved migration is
registered.
