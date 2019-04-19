if [[ $(flutter format -n .) ]]; then
    echo "files not formatted"
    exit 1
else
    exit 0
fi