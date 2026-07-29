# Scripts

- `quality_gate.ps1`: authoritative Windows quality gate.
- `quality_gate.sh`: equivalent POSIX quality gate for CI and contributors.
- `bootstrap_gradle_wrapper.*`: downloads the official Gradle 8.13 wrapper JAR
  and rejects it unless its SHA-256 matches Gradle's published checksum.

Both gates generate approved source, verify formatting and analysis, run tests
with line and branch coverage, enforce coverage, and assemble a debug APK.
