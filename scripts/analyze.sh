#!/usr/bin/env bash
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

exit 0
