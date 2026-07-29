# Security Policy

## Security posture

Anas Life OS is privacy-first and offline-first. Version 1 must not require an account, cloud service, analytics, tracking, advertising, or internet access. Core user data remains on the Android device.

The approved security architecture includes SQLCipher-compatible encrypted SQLite, AES-256-GCM, an Android Keystore-wrapped master key, Argon2id for encrypted-backup keys, modular cryptographic providers, PIN lock, biometric authentication, hidden items, secure local backup, and no failed-PIN wipe in Version 1.

## Supported versions

No production version has been released. Security support begins with the first approved release candidate. Until then, reports should reference the affected Project Bible requirement or commit.

## Reporting a vulnerability

Do not disclose vulnerabilities, credentials, backup material, encryption keys, personal data, or exploit details in a public issue.

Use GitHub's private Security Advisory reporting for this repository. Include:

- Affected commit and component
- Reproduction conditions
- Security and privacy impact
- Required permissions or user interaction
- Proof of concept with sensitive data removed
- Suggested mitigation, if known

Maintainers should acknowledge a complete report within seven calendar days. Remediation timing depends on severity and verification. Public disclosure must wait until a fix and migration or recovery guidance are available.

## Security requirements for changes

- Never commit secrets, signing keys, production credentials, PINs, database keys, or user data.
- Production signing keys remain under user-only custody.
- Validate inputs and permissions at trust boundaries.
- Never log sensitive fields or cryptographic material.
- Preserve offline behavior and least privilege.
- Schema and cryptographic changes require migration, rollback, integrity, and recovery analysis.
- Future plugins and AI providers receive no implicit access to core data.

Repository summaries do not override the authoritative Project Bible.
