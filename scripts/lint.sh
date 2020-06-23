#!/usr/bin/env bash
set -xe

if [[ $(flutter format -n .) ]]; then
  echo "flutter format issue"
  exit 1
fi

flutter pub get

# We need to run pubget on all the examples
for f in doc/examples/**/pubspec.yaml; do
  d=$(dirname $f)
  cd $d
  flutter pub get
  cd - > /dev/null
done

analyzer() {
  cd $1
  flutter pub get
  result=$(flutter analyze .)
  if ! echo "$result" | grep -q "No issues found!"; then
    echo "$result"
    echo "flutter analyze issue: $1"
    exit 1
  fi
  cd - > /dev/null
}

analyzer .

echo "success"
exit 0
