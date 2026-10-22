#!/bin/sh
# Connection test to the PC: ping, sync server, Sunshine, pairing keys
BASE="$(cd "$(dirname "$0")/.." && pwd)"
. "$BASE/conf/stream.conf"
LOG="$BASE/conf/test.log"
rm -f "$BASE/conf/test.done"
: > "$LOG"

probe() {
  if command -v wget >/dev/null 2>&1; then wget -q -T 4 -O /dev/null "$1" 2>/dev/null
  else curl -fsS -m 4 -o /dev/null "$1" 2>/dev/null; fi
}

if [ -z "$HOST" ]; then
  echo "ERR Host not set (START > Streaming > PC host)" >> "$LOG"
  touch "$BASE/conf/test.done"; exit 1
fi
echo "Host: $HOST" >> "$LOG"

OUT=$(ping -c 1 -W 2 "$HOST" 2>/dev/null)
if [ $? -eq 0 ]; then
  MS=$(echo "$OUT" | sed -n 's/.*time=\([0-9.]*\).*/\1/p' | head -n 1)
  echo "OK  Ping ${MS:-?} ms" >> "$LOG"
else
  echo "ERR No ping reply (PC off or different network?)" >> "$LOG"
fi

if probe "http://$HOST:$SYNC_PORT/library.tsv"; then
  echo "OK  Sync server on port $SYNC_PORT" >> "$LOG"
else
  echo "ERR Sync server not answering (is the library server running?)" >> "$LOG"
fi

if probe "http://$HOST:47989/serverinfo"; then
  echo "OK  Sunshine reachable (47989)" >> "$LOG"
else
  echo "ERR Sunshine not answering on 47989 (service running? firewall?)" >> "$LOG"
fi

if [ -s "$BASE/keys/client.pem" ]; then
  echo "OK  Pairing keys present" >> "$LOG"
else
  echo "ERR No keys: use Tools > Pair with Sunshine" >> "$LOG"
fi

touch "$BASE/conf/test.done"
