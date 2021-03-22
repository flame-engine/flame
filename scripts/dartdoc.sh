#!/usr/bin/env bash

function run_dartdoc() {
  result=$(flutter pub get 2>&1) # Sadly a pub get can block up our actions as it will retry forever if a package is not found, but this should atleast report everything else.
  if [ $? -ne 0 ]; then
    echo "flutter pub get failed:"
    echo "$result"
    exit 1
  fi

  flutter pub run dartdoc --no-auto-include-dependencies --quiet
}

echo "Starting Flame Dartdoc"
echo "----------------------"
for file in $(find ./packages -maxdepth 2 -type f -name "pubspec.yaml"); do
  dir=$(dirname $file)
  cd $dir
  echo "Generating dartdoc $dir"
  run_dartdoc
  dartdoc_result=$?
  if [ $dartdoc_result -ne 0 ]; then
    exit $dartdoc_result
  fi
  cd $(cd -)
done

exit 0
