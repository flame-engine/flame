#!/usr/bin/env bash
# We need to run pubget on all the examples
for f in $(find doc/examples -name 'pubspec.yaml'); do
  d=$(dirname $f)
  cd $d
  flutter pub get
  cd - > /dev/null
done

cd .
result=$(flutter analyze --pub .)
if ! echo "$result" | grep -q "No issues found!"; then
  echo "$result"
  exit 1
fi

exit 0
