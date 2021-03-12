#!/usr/bin/env bash

function run_analyze() {
  flutter pub get

  result=$(flutter pub run dart_code_metrics:metrics .)
  if [ "$result" != "" ]; then
    echo "flutter dart code metrics issues: $1"
    echo "$result"
    exit 1
  fi

  result=$(flutter analyze .)
  if ! echo "$result" | grep -q "No issues found!"; then
    echo "$result"
    echo "flutter analyze issue: $1"
  fi
}

cd examples
run_analyze

cd ../packages/flame
run_analyze

exit 0
