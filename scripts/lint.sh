#!/usr/bin/env bash
FORMAT_ISSUES=$(flutter format --set-exit-if-changed -n .)
if [ $? -eq 1 ]; then
  echo "flutter format issues on"
  echo $FORMAT_ISSUES
  exit 1
fi

flutter pub get

# We need to run pubget on all the examples
for f in $(find doc/examples -name 'pubspec.yaml'); do
  d=$(dirname $f)
  cd $d
  flutter pub get
  cd - > /dev/null
done

cd .
flutter pub get
result=$(flutter pub run dart_code_metrics:metrics --set-exit-on-violation-level=noted .)
if [ $? -eq 2 ]; then
  echo "$result"
  echo "flutter dart code metrics issues: $1"
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
