#!/bin/sh
# HELP: Dolphin Rt:Stream
# ICON: moonlight
# GRID: Dolphin Rt:Stream

. /opt/muos/script/var/func.sh

APP_BIN="love"
SETUP_APP "$APP_BIN" ""

# -----------------------------------------------------------------------------

LOVEDIR="$1"
MOONDIR="$LOVEDIR/moonlight"
PM_DIR="$(GET_VAR "device" "storage/rom/mount")/MUOS/PortMaster"

cd "$LOVEDIR" || exit

SET_VAR "system" "foreground_process" "love"

# cleanup globale su SIGTERM/SIGINT
cleanup_all() {
	[ -n "$GPTK_PID" ] && kill -9 "$GPTK_PID" 2>/dev/null && wait "$GPTK_PID" 2>/dev/null
	[ -n "$STREAM_GPTK_PID" ] && kill -9 "$STREAM_GPTK_PID" 2>/dev/null && wait "$STREAM_GPTK_PID" 2>/dev/null
	exit 0
}
trap cleanup_all INT TERM

while true; do
	rm -f "$LOVEDIR/launch.txt" "$LOVEDIR/launch.env"

	export LD_LIBRARY_PATH="$LOVEDIR/libs:$LD_LIBRARY_PATH"
	"$PM_DIR"/gptokeyb2 "$APP_BIN" &
	GPTK_PID=$!
	./$APP_BIN gui
	kill -9 "$GPTK_PID" 2>/dev/null
	wait "$GPTK_PID" 2>/dev/null
	# sicurezza: kill di eventuali gptokeyb2 orfani legati a love
	pkill -f "gptokeyb2.*$APP_BIN" 2>/dev/null || true

	[ -f "$LOVEDIR/launch.txt" ] || break
	APP="$(cat "$LOVEDIR/launch.txt")"
	rm -f "$LOVEDIR/launch.txt"
	# difesa in profondità: rifiuta app con caratteri strani
	case "$APP" in
		"") echo "invalid app name: empty" >&2; continue ;;
	esac
	if echo "$APP" | grep -qE '[`$;&|<>(){}*?!#]'; then
		echo "invalid app name: $APP" >&2; continue
	fi

	# fresh settings (the GUI may have changed them) + per-game overrides
	. "$LOVEDIR/conf/stream.conf"
	if [ -f "$LOVEDIR/launch.env" ]; then
		. "$LOVEDIR/launch.env"
		rm -f "$LOVEDIR/launch.env"
	fi

	set -- stream -app "$APP" -keydir "$LOVEDIR/keys" \
		-bitrate "$BITRATE" -width "$WIDTH" -height "$HEIGHT" \
		-fps "$FPS" -codec "$CODEC" -remote "$REMOTE"
	[ "$SOPS" = "no" ] && set -- "$@" -nosops
	[ -n "$PLATFORM" ] && set -- "$@" -platform "$PLATFORM"
	# EXTRA_ARGS is split into words on purpose
	# shellcheck disable=SC2086
	[ -n "$EXTRA_ARGS" ] && set -- "$@" $EXTRA_ARGS
	set -- "$@" -quitappafter "$HOST"

	T0=$(date +%s)
	cd "$MOONDIR" || exit
	LD_LIBRARY_PATH="$MOONDIR/libs:/usr/lib/compat:$LOVEDIR/libs:$LD_LIBRARY_PATH" \
		./moonlight "$@" >"$LOVEDIR/conf/last_stream.log" 2>&1
	RC=$?
	cd "$LOVEDIR" || exit
	T1=$(date +%s)

	# stream failed or ended at once: the GUI shows it and points to the log
	if [ "$RC" -ne 0 ] || [ $((T1 - T0)) -lt 6 ]; then
		echo "rc=$RC dur=$((T1 - T0))" >"$LOVEDIR/conf/last_result.txt"
	fi
done
