#!/usr/bin/env bash
set -e

cspell "$@" --no-progress -c .github/cspell.json "**/*.{md,dart}"