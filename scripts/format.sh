#!/usr/bin/env bash

FORMAT_ISSUES=$(flutter format --set-exit-if-changed -n .)
if [ $? -eq 1 ]; then
  echo "flutter format issues on"
  echo $FORMAT_ISSUES
  exit 1
fi