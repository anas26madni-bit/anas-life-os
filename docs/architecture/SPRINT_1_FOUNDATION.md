# Sprint 1 foundation architecture

## Scope

Sprint 1 provides a working, feature-free Android Flutter shell. It contains no
business entities, persistent application tables, repositories, reminders,
dashboard, search, backup, security behavior, plugin runtime, or AI behavior.

## Dependency ownership

Riverpod owns application state and composition. `get_it` and `injectable` are
limited to infrastructure bootstrap and native-facing singleton adapters.
Presentation depends on stable contracts; future Data implementations will
implement Domain contracts. UI code cannot query SQLite.

## Startup

The application renders immediately, then performs a recoverable in-memory
SQLCipher capability probe. The probe:

1. Generates an ephemeral 256-bit key.
2. Verifies SQLCipher availability.
3. Enables and verifies SQLite foreign keys.
4. Runs `PRAGMA quick_check`.
5. Closes the in-memory database without persisting user data.

Persistent schema creation and user-data key management remain Sprint 2 and
Sprint 10 responsibilities respectively.

## Security boundaries

The release manifest has no Internet permission, disables Android backup and
device transfer, blocks cleartext traffic, and requests no runtime permission.
Debug/profile builds retain the Internet permission required by Flutter
development tooling. Logs remove recognized sensitive context keys.

Cryptography, Android Keystore key management, Argon2id backup-key derivation,
and secure storage are modular interfaces only in Sprint 1.

## Extensibility

Plugin and AI interfaces are inert and core-owned. They expose no database or
unrestricted file access, load no providers, and add no UI or navigation.

## Traceability

This foundation implements Part 5 architecture and design-foundation rules,
Part 3 offline/security/performance constraints applicable to Sprint 1, Part 6
execution controls, Part 7 quality gates, Part 8 design tokens, Part 9 inert
boundaries, Part 10 implementation governance, and Part 11 Sprint 1.
