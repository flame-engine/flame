#!/usr/bin/env bash

./scripts/format.sh
if [ $? -eq 1 ]; then
  echo "Formatting failed!"
  exit 1
fi

echo ""

./scripts/analyze.sh
if [ $? -eq 1 ]; then
  echo "Analyzing failed!"
  exit 1
fi

echo "Succesfully linted!"
