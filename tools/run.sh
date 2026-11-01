#!/usr/bin/env bash
# Record N fresh Claude Code sessions for one variant and model; collect cast + transcript + metrics.
#
#   tools/run.sh <bare|mate> <model> [N=1]
#   e.g. tools/run.sh bare claude-fable-5-1 5
#        tools/run.sh mate claude-haiku-4-5 5
#
# Env: DEMO_DIR, PORT (8000), PROMPT, COLS/ROWS (120x34), TIMEOUT (900 s), RUNS_DIR (runs/).
set -euo pipefail

VARIANT="${1:?bare|mate}"; MODEL="${2:?model id}"; N="${3:-1}"
DEMO_DIR="${DEMO_DIR:-$HOME/Sylius/phpers-demo-23}"
PORT="${PORT:-8000}"
URL="https://127.0.0.1:$PORT/en_US/taxons/t-shirts/men"
PROMPT="${PROMPT:-The page $URL is slow for me. Find the cause.}"
COLS="${COLS:-120}"; ROWS="${ROWS:-34}"
ALLOWED="${ALLOWED:-Bash Read Grep Glob Edit Write}"   # pre-approved tools: models without auto mode (Haiku) fall back to manual and would block on the first Bash
TIMEOUT="${TIMEOUT:-900}"
HERE="$(cd "$(dirname "$0")" && pwd)"
RUNS_DIR="${RUNS_DIR:-$HERE/../runs}"
PROJECT_SLUG="$(echo "$DEMO_DIR" | sed 's#/#-#g')"
TRANSCRIPTS="$HOME/.claude/projects/$PROJECT_SLUG"

say() { printf '\033[1;32m▶ %s\033[0m\n' "$*"; }
die() { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

for t in tmux asciinema claude python3 curl; do command -v "$t" >/dev/null || die "missing $t"; done
[ -d "$DEMO_DIR/.git" ] || die "no demo project at $DEMO_DIR (run tools/prep.sh)"
case "$VARIANT" in bare) BRANCH=demo-bare;; mate) BRANCH=demo-mate;; *) die "variant: bare|mate";; esac

# server: must be THIS project on PORT (the profiler the agent reads lives in its var/cache)
if ! symfony server:list 2>/dev/null | grep -q "$(basename "$DEMO_DIR").*$PORT"; then
  lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1 && die "port $PORT is taken by another server; stop it (symfony server:stop in that dir) or set PORT"
  (cd "$DEMO_DIR" && symfony server:start -d --port="$PORT" >/dev/null) || die "could not start the server (TLS needs symfony server:ca:install once)"
fi

# trust dialog would block an unattended interactive session
python3 - "$DEMO_DIR" <<'PY'
import json, sys, os
p = os.path.expanduser('~/.claude.json'); d = json.load(open(p))
proj = d.setdefault('projects', {}).setdefault(sys.argv[1], {})
if not proj.get('hasTrustDialogAccepted'):
    proj['hasTrustDialogAccepted'] = True
    json.dump(d, open(p, 'w'), indent=2)
PY

cd "$DEMO_DIR"
say "variant=$VARIANT branch=$BRANCH model=$MODEL runs=$N"
git diff --quiet || die "demo project has uncommitted changes"
git checkout -q "$BRANCH"
BASE="$(git rev-parse HEAD)"
reset_project() {   # agents sometimes "fix" the bug and even commit; every run starts from the same commit
  git reset -q --hard "$BASE" && git clean -fdq
  for f in mate AGENTS.md CLAUDE.md .agents .mcp.json; do git ls-files --error-unmatch "$f" >/dev/null 2>&1 || rm -rf "$f"; done
  bin/console cache:clear -q 2>/dev/null || true
}
reset_project
git status --porcelain | grep -q . && die "stray files after checkout: $(git status --porcelain | tr '\n' ' ')"

for i in $(seq 1 "$N"); do
  STAMP="$(date +%Y%m%d-%H%M%S)"
  SID="$(python3 -c 'import uuid;print(uuid.uuid4())')"
  OUT="$RUNS_DIR/$STAMP-$VARIANT-$MODEL"; mkdir -p "$OUT"
  say "run $i/$N → $OUT"

  rm -rf "$TRANSCRIPTS/memory"                      # no memory from earlier runs
  curl -sk -o /dev/null "$URL" || die "page not reachable: $URL"   # a fresh profile for the agent to find
  echo "$PROMPT" > "$OUT/prompt.txt"
  printf 'variant=%s\nbranch=%s\nmodel=%s\nsession=%s\nurl=%s\ncols=%s\nrows=%s\nclaude=%s\ndemo_commit=%s\n' \
    "$VARIANT" "$BRANCH" "$MODEL" "$SID" "$URL" "$COLS" "$ROWS" "$(claude --version)" "$(git rev-parse --short HEAD)" > "$OUT/meta.txt"

  tmux kill-session -t rec 2>/dev/null || true
  tmux new-session -d -s rec -x "$COLS" -y "$ROWS" -c "$DEMO_DIR" \
    "asciinema rec --overwrite --cols $COLS --rows $ROWS -c 'claude --model $MODEL --permission-mode auto --allowedTools $ALLOWED --session-id $SID' '$OUT/session.cast'"

  echo "  watching: tmux attach -t rec   (detach: Ctrl-b d; do not type into it)"
  JSONL="$TRANSCRIPTS/$SID.jsonl"
  # wait for the TUI, then type the prompt like a human would
  for _ in $(seq 1 60); do tmux capture-pane -pt rec 2>/dev/null | grep -qE '^\s*[>›❯]' && break; sleep 1; done
  sleep 2
  tmux send-keys -t rec -l "$PROMPT"; sleep 1; tmux send-keys -t rec Enter
  START=$(date +%s)

  # done = last assistant message ended the turn without a tool call and the transcript stayed quiet
  while :; do
    sleep 3
    [ $(( $(date +%s) - START )) -gt "$TIMEOUT" ] && { echo "timeout" >> "$OUT/meta.txt"; break; }
    tmux has-session -t rec 2>/dev/null || break
    [ -f "$JSONL" ] || continue
    if python3 "$HERE/metrics.py" --done "$JSONL" 2>/dev/null; then
      sleep 8; python3 "$HERE/metrics.py" --done "$JSONL" 2>/dev/null && break
    fi
  done

  tmux send-keys -t rec -l "/exit"; sleep 1; tmux send-keys -t rec Enter
  for _ in $(seq 1 30); do tmux has-session -t rec 2>/dev/null || break; sleep 1; done
  tmux kill-session -t rec 2>/dev/null || true

  git status --porcelain | grep -q . && echo "agent_changed_files=yes" >> "$OUT/meta.txt"
  [ "$(git rev-parse HEAD)" != "$BASE" ] && echo "agent_committed=yes" >> "$OUT/meta.txt"
  reset_project
  cp "$JSONL" "$OUT/transcript.jsonl" 2>/dev/null || echo "no transcript" >> "$OUT/meta.txt"
  python3 "$HERE/metrics.py" "$OUT/transcript.jsonl" > "$OUT/metrics.json" 2>/dev/null && \
    python3 -c "import json;m=json.load(open('$OUT/metrics.json'));print('  turns=%(api_requests)s tools=%(tool_calls)s wall=%(wall_s)ss diagnosis=%(diagnosis_s)ss out=%(output_tokens)s cache_read=%(cache_read_tokens)s' % m)"
done
say "all runs done → $RUNS_DIR ; summary: python3 tools/summary.py"
