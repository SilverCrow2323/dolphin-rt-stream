#!/bin/bash
# Dolphin Stream — desktop launcher (MX Linux XFCE)
# Apre la GUI in finestra 640x480. Non tocca mux_launch.sh (muOS only).
set -e
cd "$(dirname "$0")"

export DOLPHINSTREAM_WINDOWED=1
# fallback per love di sistema (non usa il binario shim muOS)
LOVE_BIN="$(command -v love || echo '')"
if [ -z "$LOVE_BIN" ]; then
  echo "ERRORE: love non trovato. sudo apt install love" >&2
  exit 1
fi

echo "[desktop] love: $LOVE_BIN"
echo "[desktop] cartella: $(pwd)"
echo "[desktop] avvio GUI (windowed 640x480)..."
exec "$LOVE_BIN" gui "$@"
