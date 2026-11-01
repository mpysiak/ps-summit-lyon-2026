#!/usr/bin/env bash
# session.cast → webm (and a gif on the way). Big font for the room.
#   tools/render.sh runs/<dir> [speed=1] [font-size=22]
set -euo pipefail
DIR="${1:?run dir}"; SPEED="${2:-1}"; FONT="${3:-22}"
agg --font-size "$FONT" --speed "$SPEED" --idle-time-limit 4 --fps-cap 20 --theme monokai "$DIR/session.cast" "$DIR/session.gif"
ffmpeg -y -loglevel error -i "$DIR/session.gif" -c:v libvpx-vp9 -b:v 0 -crf 32 -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" "$DIR/session-x$SPEED.webm"
rm -f "$DIR/session.gif"
echo "→ $DIR/session-x$SPEED.webm  (step times from metrics.json: divide 't' by $SPEED; idle gaps >4 s are cut, so re-pin by eye)"
