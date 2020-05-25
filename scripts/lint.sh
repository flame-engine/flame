#!/usr/bin/env bash
set -xe

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

analyzer() {
  cd $1
  flutter pub get
  result=$(dartanalyzer .)
  if ! echo "$result" | grep -q "No issues found!"; then
    echo "$result"
    echo "dartanalyzer issue: $1"
    exit 1
  fi
  cd - > /dev/null
}

analyzer "example"

#  Examples that are changed
changed=$(git diff --name-only origin/develop doc/examples \
  | xargs -I {} dirname {} | sed 's/\/lib$//' | uniq \
  | xargs -I {} find {} -name pubspec.yaml | xargs -I {} dirname {})

# Examples that are affected by changed code
affected=$(git diff --name-only origin/develop lib/ \
  | xargs -I {} basename {} | xargs -I {} grep -r -l --include \*.dart {} doc/examples/ \
  | xargs -I {} dirname {} | sed 's/\/lib$//' | uniq \
  | xargs -I {} find {} -name pubspec.yaml | xargs -I {} dirname {})

both=("${changed[@]}" "${affected[@]}")
lint_examples=$(printf "%s\n" "${both[@]}" | sort -u)
for d in $lint_examples; do
  analyzer $d
done

for f in doc/examples/**/pubspec.yaml; do
  d=$(dirname $f)
  if [[ ! " ${lint_examples[@]} " =~ " ${d} " ]]; then
    analyzer $d
  fi
done

echo "success"
exit 0
