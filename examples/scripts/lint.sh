#!/usr/bin/env bash
FORMAT_ISSUES=$(flutter format --set-exit-if-changed -n .)
if [ $? -eq 1 ]; then
  echo "flutter format issue"
  echo $FORMAT_ISSUES
  exit 1
fi

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
  exit 1
fi

echo "success"
exit 0
