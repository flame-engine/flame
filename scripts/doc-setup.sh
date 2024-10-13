#!/usr/bin/env bash
set -e

echo Checking python version:
python3 --version && python3 -c "import sys; sys.exit(0 if sys.version_info >= (3,8) else 2)" || (echo "Error: Python 3.8+ is required" && exit 1)
echo Installing required python modules:
python3 -m pip install -r "$MELOS_ROOT_PATH/doc/_sphinx/requirements.txt"
echo Installing dartdoc_json:
dart pub global activate dartdoc_json
echo Done.
