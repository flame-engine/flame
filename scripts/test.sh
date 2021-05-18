#!/usr/bin/env bash

echo "Starting Flame Tester"
echo "---------------------"
root_dir="$(realpath $(dirname "$0")/..)"
for file in $(find . -type d -name "test"); do
  dir=$(dirname $file)
  cd $dir
  echo "Testing $dir"
  flutter test --coverage
  test_result=$?
  if [ $test_result -ne 0 ]; then
    exit $test_result
  fi

  if [ -f ".min_coverage" ]; then
    min_coverage=$(cat .min_coverage)

    coverage_summary=$(lcov --summary coverage/lcov.info)
    coverage_line=$(echo "$coverage_summary" | grep lines)
    echo "$coverage_summary"

    dart "$root_dir/scripts/check_coverage.dart" "$coverage_line" "$min_coverage"
    coverage_result=$?
    if [ $coverage_result -ne 0 ]; then
      echo "Current coverage $current_cov is smaller than min: $min_coverage"
      exit $coverage_result
    fi
  fi
  cd $(cd -)
done

exit 0
