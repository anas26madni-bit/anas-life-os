# Sprint 11 traceability

| Scope | Authority | Automated evidence | Completion evidence |
|---|---|---|---|
| API/device regression | P7-INT-001; VR-008 | CI API 30 and API 34 emulator matrix | physical API 30/API 34+ |
| Search/large data | NFR-PERF-004; P7-SEARCH-001 | existing 100,000-record p95 benchmark | physical trace |
| Accessibility/responsive | NFR-UI-001-008; P7-A11Y-001 | EN/UR, RTL/LTR, 200% text, small/landscape tests | TalkBack/focus matrix |
| Memory/CPU/frames | NFR-PERF/MEM; P7-PERF-001 | profile APK and regression tests | Perfetto/Simpleperf/meminfo/gfxinfo |
| Battery/background | NFR-BAT-001-005; P7-BAT-001 | wake-lock/location/constraint audit | 8-hour/24-hour physical runs |

Status: implemented and awaiting mandatory physical-device evidence. Sprint 11
must not be marked complete or merged before the physical matrix passes.

Automated evidence: exact-head GitHub Actions run `31586516491` for
`c03a935f4e0f2042879d3325f0c610c185cb1520`; validation plus API 30 and API 34
integration passed. The integration test covers encrypted search; voice service
unit tests remain automated and real recognizer behavior remains mandatory in
the physical-device matrix.
