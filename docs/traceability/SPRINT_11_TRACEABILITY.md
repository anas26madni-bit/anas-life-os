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

Automated evidence: GitHub Actions run `31578948794` for
`34b331b9b9bc0ccb8dc21554c7535b7d3b06d59b`; validation and API 30 integration
passed. API 34 found that the unattended search test could start an installed
voice recognizer and wait indefinitely for microphone input. The test now
probes availability without starting capture; exact-head matrix retry is
required before this automated evidence is complete.
