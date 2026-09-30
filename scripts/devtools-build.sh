#!/usr/bin/env bash
set -e

# Builds the Flame DevTools extension and copies the output into the flame
# package, mirroring `dart run devtools_extensions build_and_copy` but without
# the deprecated `--pwa-strategy` flag that the upstream command still passes.

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_dir="$root_dir/packages/flame_devtools"
destination_dir="$root_dir/packages/flame/extension/devtools/build"

echo "[devtools-build] Building the extension Flutter web app..."
(
  cd "$source_dir"
  flutter build web --release --no-tree-shake-icons
)

if [[ -d "$source_dir/build/web/canvaskit" ]]; then
  echo "[devtools-build] Setting canvaskit permissions..."
  chmod 0755 "$source_dir/build/web/canvaskit/canvaskit.js" \
    "$source_dir/build/web/canvaskit/canvaskit.wasm"
fi

echo "[devtools-build] Replacing the existing extension build with the new one..."
rm -rf "$destination_dir"
mkdir -p "$destination_dir"
cp -R "$source_dir/build/web/." "$destination_dir"

echo "[devtools-build] Successfully copied extension assets to \"$destination_dir\""
