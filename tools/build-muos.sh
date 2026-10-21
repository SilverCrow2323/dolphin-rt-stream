#!/usr/bin/env bash
# Builds dist/DolphinStream-muOS-<version>.zip (the folder to copy into ROMS/APPLICATIONS).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/VERSION")"
OUT="${1:-$ROOT/dist}"
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"
cd "$ROOT/muos"
rm -f "$OUT/DolphinStream-muOS-$VERSION.zip"
zip -qr "$OUT/DolphinStream-muOS-$VERSION.zip" DolphinStream \
  -x '*/__pycache__/*' '*/conf/*.tsv' '*/conf/*.log' '*/conf/ui.cfg' '*/conf/state.txt' '*/conf/*.result' '*/conf/*.done'
echo "built $OUT/DolphinStream-muOS-$VERSION.zip"
