if [[ $(flutter format -n .) ]]; then
    echo "flutter format issue"
    exit 1
fi

result=`dartanalyzer lib/`
if ! echo "$result" | grep -q "No issues found!"; then
  echo "$result"
  echo "dartanalyzer issue"
  exit 1
fi

echo "success"
exit 0
