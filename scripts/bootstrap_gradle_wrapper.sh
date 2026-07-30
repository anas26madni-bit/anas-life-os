#!/usr/bin/env sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target="$repository_root/app/android/gradle/wrapper/gradle-wrapper.jar"
expected=7d3a4ac4de1c32b59bc6a4eb8ecb8e612ccd0cf1ae1e99f66902da64df296172

if [ ! -f "$target" ]; then
  curl --fail --location --silent --show-error \
    https://raw.githubusercontent.com/gradle/gradle/v8.14.5/gradle/wrapper/gradle-wrapper.jar \
    --output "$target"
fi

echo "$expected  $target" | sha256sum --check
