if [[ $(flutter format -n .) ]]; then
    echo "files not formatted"
    exit 1
fi

if [[ $(dartanalyzer lib/) ]]; then
  echo "lintint issue"
  exit 1
fi
