# Sprint 1 dependency decisions

Dependencies are pinned by compatible constraints in `app/pubspec.yaml`.

| Dependency | Purpose | Boundary and risk control |
|---|---|---|
| Flutter / Dart | Android application runtime | Stable channel; Android only |
| Riverpod | State and composition owner | No business logic in widgets |
| GoRouter | Typed navigation foundation | One foundation route in Sprint 1 |
| Drift | Approved SQLite abstraction | Schema begins in Sprint 2 |
| sqlite3 SQLCipher hook | Encrypted engine capability | In-memory verification only |
| get_it / injectable | Infrastructure bootstrap | Not used for feature state |
| dynamic_color | Android 12+ color integration | Falls back to approved seed |
| intl / Flutter localizations | English/Urdu and RTL | No online dependency |

Build-time generators are development dependencies and do not add runtime
network access. Package upgrades require impact analysis, generated-source
review, analyzer/tests, and an Android build.
