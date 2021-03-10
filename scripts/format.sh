#!/usr/bin/env bash

function run_format() {
  FORMAT_ISSUES=$(flutter format --set-exit-if-changed -n .)
  if [ $? -eq 1 ]; then
    echo "flutter format issues on"
    echo $FORMAT_ISSUES
    exit 1
  fi
}

cd examples
run_format

cd ../packages/flame
run_format

