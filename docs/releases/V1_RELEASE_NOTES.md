# Anas Life OS Version 1.0.0 release candidate

Anas Life OS Version 1 is a privacy-first, offline Android application for tasks,
projects, reminders, Knowledge Vault, documents, calendar, universal search,
statistics, encrypted backup/restore, security and personal settings.

## Release properties

- Android 11+ (`minSdk` 30), target/compile SDK 36.
- English and Urdu with LTR/RTL, light/dark/dynamic color and reduced motion.
- Encrypted local database and encrypted, passphrase-derived backup containers.
- PIN and strong-biometric app lock with protected-content filtering.
- No account, cloud dependency, telemetry or mandatory network access.

## Candidate artifacts

CI produces an installable minified release-candidate APK, an AAB and a SHA-256
manifest. Both artifacts use the approved debug signing identity. Production
signing is intentionally excluded because the production key remains solely in
user custody.

## Known limitation

Physical-device performance, battery, biometric, alarm and Doze validation was
not executed and is not claimed as passed. The Product Owner explicitly accepted
this residual risk when closing Sprint 11; automated and API 30/API 34 emulator
evidence remains the available validation basis.
