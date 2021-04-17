#!/usr/bin/env bash

function run_format() {
  FORMAT_ISSUES=$(flutter format --set-exit-if-changed -n .)
  if [ $? -eq 1 ]; then
    echo "flutter format issues on"
    echo $FORMAT_ISSUES
    exit 1
  fi
}

echo "Starting Flame Formatter"
echo "------------------------"
for file in $(find . -type f -name "pubspec.yaml"); do
  dir=$(dirname $file)
  cd $dir
  echo "Formatting $dir"
  run_format
  format_result=$?
  if [ $format_result -ne 0 ]; then
    exit $format_result
  fi
  cd $(cd -)
done

exit 0
