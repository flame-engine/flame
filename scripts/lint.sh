if [[ $(flutter format -n .) ]]; then
    echo "formatting issue"
    exit 1
fi

if [[ $(dartanalyzer lib/) ]]; then
  echo "lint issue"
  exit 1
fi
