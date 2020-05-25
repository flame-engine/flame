#!/bin/bash -xe

if [[ $(flutter format -n .) ]]; then
    echo "flutter format issue"
    exit 1
fi

flutter pub get
result=$(dartanalyzer lib/)
if ! echo "$result" | grep -q "No issues found!"; then
  echo "$result"
  echo "dartanalyzer issue: lib"
  exit 1
fi

cd example/
flutter pub get
result=$(dartanalyzer .)
if ! echo "$result" | grep -q "No issues found!"; then
  echo "$result"
  echo "dartanalyzer issue: example"
  exit 1
fi
cd ..

#  Examples that are changed
changed=$(git diff --name-only develop... doc/examples \
  | xargs -I {} dirname {} | sed 's/\/lib$//' | uniq \
  | xargs -I {} find {} -name pubspec.yaml | xargs -I {} dirname {})

# Examples that are affected by changed code
affected=$(git diff --name-only develop... lib/ \
  | xargs -I {} basename {} | xargs -I {} grep -r -l --include \*.dart {} doc/examples/ \
  | xargs -I {} dirname {} | sed 's/\/lib$//' | uniq \
  | xargs -I {} find {} -name pubspec.yaml | xargs -I {} dirname {})

both=("${changed[@]}" "${affected[@]}")
lint_examples=$(printf "%s\n" "${both[@]}" | sort -u)
for d in $lint_examples; do
  cd $d
  flutter pub get
  result=$(dartanalyzer .)
  if ! echo "$result" | grep -q "No issues found!"; then
    echo "$result"
    echo "dartanalyzer issue: $d"
    exit 1
  fi
  cd -
done

echo "success"
exit 0
