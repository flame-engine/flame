#!/usr/bin/env bash

function run_analyze() {
  if ! grep -q "dart_code_metrics" ./pubspec.yaml; then
    echo "Missing dart_code_metrics in pubspec.yaml"
    exit 1
  fi

  result=$(flutter pub get 2>&1) # Sadly a pub get can block up our actions as it will retry forever if a package is not found, but this should atleast report everything else.
  if [ $? -ne 0 ]; then
    echo "flutter pub get failed:"
    echo "$result"
    exit 1
  fi

  result=$(flutter pub run dart_code_metrics:metrics .)
  if [ "$result" != "" ]; then
    echo "flutter dart code metrics issues:"
    echo "$result"
    exit 1
  fi

  result=$(flutter analyze .)
  if ! echo "$result" | grep -q "No issues found!"; then
    echo "$result"
    echo "flutter analyze issue:"
    exit 1
  fi
}

echo "Starting Flame Analyzer"
echo "-----------------------"
for file in $(find . -type f -name "pubspec.yaml"); do
  dir=$(dirname $file)
  cd $dir
  echo "Analyzing $dir"
  run_analyze
  analyze_result=$?
  if [ $analyze_result -ne 0 ]; then
    exit $analyze_result
  fi
  cd $(cd -)
done

exit 0
