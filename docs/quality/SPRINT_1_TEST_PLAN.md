# Sprint 1 test plan

## Automated gates

- Generate injectable, route, and localization source.
- Verify formatting and fatal analyzer warnings/information.
- Run unit tests for SQLCipher initialization and themes.
- Run widget tests for ready/recovery states, localization, and RTL.
- Run architecture tests preventing UI database access and later-sprint source.
- Run integration smoke test for application startup.
- Enforce at least 90% line and branch coverage for business/domain source,
  excluding generated source. Sprint 1 contains no product business rules.
- Assemble the Android debug APK.

## Required device matrix

- API 30 low-memory Android emulator.
- API 34 reference emulator.
- API 36 target emulator.
- Physical Android device validation when available.

## Manual checks

- Cold start measurement from a force-stopped state.
- Light, dark, system, dynamic, custom seed, and high-contrast appearance.
- English/Urdu switching and correct RTL mirroring.
- TalkBack labels and focus order.
- Font scales through 200% without clipping.
- Landscape and small/large phone layouts.
- Airplane-mode startup with no core dependency on Internet.
- Recoverable SQLCipher initialization failure.
- No release-manifest Internet or unexpected runtime permissions.
- Memory/leak and idle-battery baselines recorded with Android tooling.

## Exit rule

Every automated and manual gate must have dated evidence and no Critical defect.
An unavailable tool or device is a blocked gate, not a pass.
