#!/usr/bin/env bash
set -e

fix=$([[ "$*" == *--fix* ]] && echo true || echo false)

function sort_check_fn() {
    sort -f -c
}

function sort_run_fn() {
    sort -f
}

function sort_dictionary() {
    local file="$1"
    local tmp_file=$(mktemp)

    head -n 1 "$file" > "$tmp_file"
    tail -n +2 "$file" | sort_run_fn >> "$tmp_file"
    mv "$tmp_file" "$file"
}

function delete_unused() {
    local file="$1"
    local word="$2"

    perl -i -ne "print unless /^\s*${word}\s*([# ].*)?$/i" "$file"
}

function lowercase() {
    tr 'A-Z' 'a-z'
}

word_list="word_list.tmp"

dictionary_dir=".github/.cspell"
tmp_dir=".cspell.tmp"

mv "$dictionary_dir" "$tmp_dir"
mkdir "$dictionary_dir"
for file in "$tmp_dir"/*; do
    if [[ -f "$file" ]]; then
        touch "$dictionary_dir/$(basename "$file")"
    fi
done

./scripts/cspell-run.sh --dot --unique --words-only | lowercase | sort -f > $word_list  || exit 1
rm -r "$dictionary_dir"
mv "$tmp_dir" "$dictionary_dir"

error=0
for file in .github/.cspell/*.txt; do
    echo "Processing dictionary '$file'..."

    violation=$(awk '!/^\s*(#|$)/' "$file" | sort_check_fn 2>&1 || true)
    if [ -n "$violation" ]; then
        # Extract only the line content after the last ': '
        violation_line=$(echo "$violation" | sed 's/.*: //')
        echo "Error: The dictionary '$file' is not in alphabetical order. First violation: '$violation_line'" >&2
        error=1
        if $fix; then
            echo "Fixing the dictionary '$file'"
            sort_dictionary "$file"
        fi
    fi

    while IFS= read -r line; do
        # split the line by # to remove comments
        word=$(echo "$line" | cut -d '#' -f 1 | xargs | lowercase) # xargs trims whitespace

        # check if the word exists in the project
        if [[ -n "$word" ]] && ! grep -wxF "$word" "$word_list" >/dev/null; then
            echo "Error: The word '$word' in the dictionary '$file' is not needed." >&2
            error=1
            if $fix; then
                echo "Fixing the dictionary '$file' with excess word $word"
                delete_unused "$file" "$word"
            fi
        fi
    done < "$file"
done

rm $word_list
exit $error