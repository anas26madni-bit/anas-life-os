# Sprint 12 release readiness

## Scope and decision record

- Candidate: Anas Life OS Version 1.0.0 (`versionCode` 12).
- Sprint 12 changes release configuration, validation and documentation only;
  completed Sprint 1-11 product behavior and schema are unchanged.
- Android candidate APK/AAB use the approved debug signing identity. Production
  signing material remains exclusively user-held and is not present in the
  repository or CI.
- Product Owner authorization in the Sprint 12 Codex task is the durable release
  approval under VR-007, conditional on all available gates passing.

## Release gate

| Criterion | Evidence | Status |
|---|---|---|
| Requirements and regression | 107 unit/widget/database/architecture tests | Pass |
| Generated source | Generate then tracked-diff check | Pass |
| Static quality | Formatter and analyzer with fatal warnings | Pass |
| Coverage | 90.83% business line; 100% branch | Pass |
| Android integration | API 30 and API 34 emulator matrix | Pass |
| Security | Release-config regression, minify/shrink, signature verification | Pass |
| Artifacts | Release APK, AAB and SHA-256 manifest | Pass |
| Critical bugs / High security findings | None known at candidate creation | Pass |
| Future Release boundary | Static absence regression | Pass |

Exact-head evidence: GitHub Actions run `31668658016` for commit
`8c2548cef69f8b85eae49516252021a24ab61e18`. All four jobs passed: validation,
release candidate, API 30 integration and API 34 integration.

Artifact paths and SHA-256:

- `app/build/app/outputs/flutter-apk/app-release.apk`:
  `cf746512737b733c5126fcbdf95e2f6134e0f6d3b68dafdc15e2490f83e1d017`
- `app/build/app/outputs/bundle/release/app-release.aab`:
  `854bc6c3c0b94f0fb2a4efc6960a5d3a2f39d21ee1a72467956c23528f9dd483`

## Version 1 acceptance matrix

| Capability | Expected result | Acceptance evidence |
|---|---|---|
| Foundation, navigation and settings | Offline startup, shared shell and persistent localized settings | Sprint 1/10 approval plus final regression |
| Tasks, projects and reminders | Authorized CRUD and offline reminder workflows remain intact | Sprint 3/4 approval plus final regression |
| Knowledge and documents | Offline hierarchy, editing, metadata and protected access remain intact | Sprint 5 approval plus final regression |
| Dashboard and calendar | Customized dashboard and approved calendar modes remain intact | Sprint 6 approval plus final regression |
| Search and statistics | Authorized search and approved deterministic reports remain correct | Sprint 7/8 approval plus final regression |
| Backup and security | Encrypted recovery and fail-closed app protection remain intact | Sprint 9/10 approval plus final regression |

Actual final result is recorded only after exact-head CI. Prior Product Owner
Sprint approvals are retained as feature UAT evidence under VR-007; Sprint 12
does not fabricate or substitute an unexecuted manual session.

## Completion package

- Test report: exact-head GitHub Actions run `31668658016`, all four jobs Pass.
- Coverage report: 90.83% business line and 100% branch coverage.
- Bug report: no open Critical bug or High security finding known; any CI defect
  must be recorded and fixed before completion.
- Known limitations: physical-device evidence and production signing below.
- Recommendation: user performs production signing and store submission from a
  controlled environment after accepting the candidate artifacts.

## Change record

- Reason: produce the authorized Version 1 release candidate and final evidence.
- Affected modules: version metadata, Android release build, CI and release docs.
- Risk: build/signing pipeline failure or inaccurate readiness evidence.
- Migration impact: Not Applicable; no application schema or user-data change.
- Testing impact: full suite, coverage, API 30/API 34 integration and artifact audit.
- Rollback: revert the isolated Sprint 12 branch/PR; Sprint 11 main remains valid.
- Approval: Product Owner Sprint 12 authorization in the durable Codex task.

## Explicitly accepted limitation and residual risk

Sprint 11 physical-device, ADB, 8-hour/24-hour battery, biometric, alarm and
Doze evidence was not executed. The Product Owner explicitly accepted this
limitation on 2026-08-12. No physical-device result is claimed as passed. The
approved quantitative thresholds remain unchanged; device-specific performance,
memory, CPU, battery, frame pacing and Android platform behavior remain residual
risk.

The candidate artifacts are not production-signed and therefore are not Play
Store production deliverables. Final production signing must be performed by the
user with the user-custodied key without committing or exposing that key.
