# Sprint 10 Product Owner decisions

Approved 2026-08-12: `OI-014` and `OI-015`.

- Threat protection covers local encrypted data and UI against lost/stolen
  devices, unauthorized local users, malicious intents/apps, disclosure
  surfaces and database/backup tampering; failures close access. Rooted or
  compromised Android is an explicit residual risk.
- App lock uses a minimum six-digit PIN with an Argon2id salted verifier,
  persistent progressive cooldown after five failures, no wipe, Android strong
  biometrics with PIN fallback, immediate default/configurable lifecycle lock,
  current-PIN security changes, hidden-content authorization, `FLAG_SECURE` and
  no recovery backdoor.
