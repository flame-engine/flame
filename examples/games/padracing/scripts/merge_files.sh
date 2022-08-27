#!/usr/bin/env bash
# This script is used to create a dart file that can run in Dartpad.
# If you are on linux it will copy the output to the clipboard, otherwise
# you can find the resulting file in scripts/main.dart (which also is generated
# on linux).
PROJECT_ROOT=$(dirname $(realpath -s $0))/..
LIB=$PROJECT_ROOT/lib
OUTPUT=$PROJECT_ROOT/scripts

cat $LIB/main.dart > $OUTPUT/main.dart
cat $LIB/padracing_game.dart >> $OUTPUT/main.dart
cd $LIB
cat $(ls | grep -v 'main.dart' | grep -v 'padracing_game.dart') >> $OUTPUT/main.dart
cd $OUTPUT
grep import < main.dart > imports.dart
grep -v import < main.dart > tmp.dart
LC_COLLATE=c sort -u imports.dart | grep -v padracing > imports_tmp.dart
cat imports_tmp.dart tmp.dart > main.dart
rm tmp.dart imports_tmp.dart imports.dart
echo '//ignore_for_file: avoid_web_libraries_in_flutter' >> main.dart
flutter format main.dart

if command -v xclip &> /dev/null
then
    echo "Copied with xclip"
    xclip -selection clipboard < main.dart
elif command -v wl-copy &> /dev/null
then
    echo "Copied with wl-copy"
    wl-copy < main.dart
fi

