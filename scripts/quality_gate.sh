#!/usr/bin/env sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repository_root/app"

command -v flutter >/dev/null 2>&1 || {
  echo "Flutter is required. Install the approved stable SDK." >&2
  exit 1
}
command -v dart >/dev/null 2>&1 || {
  echo "Dart is required and should be provided by Flutter." >&2
  exit 1
}

"$repository_root/scripts/bootstrap_gradle_wrapper.sh"

flutter pub get
dart run build_runner build
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage --branch-coverage
dart run ../tools/verify_coverage.dart coverage/lcov.info
flutter build apk --debug
