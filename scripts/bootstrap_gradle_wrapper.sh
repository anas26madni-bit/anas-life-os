#!/usr/bin/env sh
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
target="$repository_root/app/android/gradle/wrapper/gradle-wrapper.jar"
expected=81a82aaea5abcc8ff68b3dfcb58b3c3c429378efd98e7433460610fecd7ae45f

if [ ! -f "$target" ]; then
  curl --fail --location --silent --show-error \
    https://raw.githubusercontent.com/gradle/gradle/v8.13.0/gradle/wrapper/gradle-wrapper.jar \
    --output "$target"
fi

echo "$expected  $target" | sha256sum --check
