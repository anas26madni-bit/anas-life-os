# Anas Life OS application

This directory contains the Android-only Flutter application.

Sprint 1 establishes the production foundation only: bootstrap, architecture
boundaries, dependency composition, structured local logging, Material 3
themes, English/Urdu localization, RTL support, typed navigation, a
SQLCipher capability check, and inert plugin/security contracts. Product
features and persistent business tables begin in later approved sprints.

## Local quality gate

Run `../scripts/quality_gate.ps1` on Windows or
`../scripts/quality_gate.sh` on Linux/macOS.

The Android toolchain requires JDK 17 and Android SDK API 36. The minimum
supported Android version remains Android 11 (API 30).
