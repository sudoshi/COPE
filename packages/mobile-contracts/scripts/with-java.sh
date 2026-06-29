#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${JAVA_HOME:-}" ]]; then
  for candidate in \
    "$(/usr/libexec/java_home 2>/dev/null || true)" \
    /usr/local/opt/openjdk/libexec/openjdk.jdk/Contents/Home \
    /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home \
    /usr/local/Cellar/openjdk/*/libexec/openjdk.jdk/Contents/Home \
    /opt/homebrew/Cellar/openjdk/*/libexec/openjdk.jdk/Contents/Home
  do
    if [[ -n "$candidate" && -x "$candidate/bin/java" ]]; then
      export JAVA_HOME="$candidate"
      break
    fi
  done
fi

if [[ -z "${JAVA_HOME:-}" || ! -x "$JAVA_HOME/bin/java" ]]; then
  echo "JAVA_HOME is not set and no local JDK was found." >&2
  exit 1
fi

export PATH="$JAVA_HOME/bin:$PATH"
exec "$@"
