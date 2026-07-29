param([switch]$SkipBuild)

$ErrorActionPreference = "Stop"
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$applicationRoot = Join-Path $repositoryRoot "app"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw "Flutter is required. Install the approved stable Flutter SDK and add it to PATH."
}
if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
    throw "Dart is required and should be provided by the Flutter SDK."
}

& (Join-Path $PSScriptRoot "bootstrap_gradle_wrapper.ps1")

Push-Location $applicationRoot
try {
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    dart format --output=none --set-exit-if-changed .
    flutter analyze --fatal-infos --fatal-warnings
    flutter test --coverage --branch-coverage
    dart run ../tools/verify_coverage.dart coverage/lcov.info
    if (-not $SkipBuild) {
        flutter build apk --debug
    }
} finally {
    Pop-Location
}
