#!/bin/sh
# Pairs the handheld with Sunshine: moonlight prints a PIN to enter in the Sunshine web UI
BASE="$(cd "$(dirname "$0")/.." && pwd)"
. "$BASE/conf/stream.conf"
LOG="$BASE/conf/pair.log"
MOON="$BASE/moonlight"
: > "$LOG"
mkdir -p "$BASE/keys"

if [ -z "$HOST" ]; then
  echo "ERR Host not set (START > Streaming > PC host)" >> "$LOG"
  exit 1
fi
cd "$MOON" || { echo "ERR moonlight folder not found" >> "$LOG"; exit 1; }
export LD_LIBRARY_PATH="$MOON/libs:/usr/lib/compat:$BASE/libs:$LD_LIBRARY_PATH"

if command -v stdbuf >/dev/null 2>&1; then
  stdbuf -oL -eL ./moonlight pair -keydir "$BASE/keys" "$HOST" >> "$LOG" 2>&1 &
else
  ./moonlight pair -keydir "$BASE/keys" "$HOST" >> "$LOG" 2>&1 &
fi
echo $! > "$BASE/conf/pair.pid"
wait $!
RC=$?
rm -f "$BASE/conf/pair.pid"
if [ "$RC" -eq 0 ]; then echo "OK  Pairing complete" >> "$LOG"
else echo "ERR Pairing ended (code $RC)" >> "$LOG"; fi
