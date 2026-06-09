#!/bin/bash
# Twin-arm in-vivo session chain (Phase 4). One invocation runs ONE ARM's full 12
# increments sequentially; run the two arms as two parallel background processes.
# Each increment: fresh `claude -p` in the arm's repo dir (no conversational carryover);
# continuity only via repo artifacts. JSON output captured for usage/cost.
# Sessions run with a SCOPED tool allowlist (file tools + Go toolchain only — no
# unrestricted shell), identical for both arms. See PREDICTION.md (locked first).
# Usage: chain.sh <arm>   arm in a|b
set -u
D="$(cd "$(dirname "$0")" && pwd)"
ARM="${1:?arm a|b}"
REPO="$D/arms/relay-$ARM"; LOG="$D/arms/log-$ARM"; mkdir -p "$REPO" "$LOG"

TOOLS="Read,Write,Edit,Glob,Grep,Bash(go:*),Bash(gofmt:*),Bash(ls:*),Bash(mkdir:*),Bash(sqlite3:*)"

# Arm doctrine installed once (idempotent)
if [ ! -f "$REPO/CLAUDE.md" ]; then
  case "$ARM" in
    a) cp "$D/../2026-06-09-v1-erosion-audit/vehicle/doctrine-post.md" "$REPO/CLAUDE.md" ;;
    b) cp "$D/control-claude.md" "$REPO/CLAUDE.md" ;;
  esac
  echo "installed CLAUDE.md (arm $ARM)"
fi

for i in $(seq -w 1 12); do
  out="$LOG/inc$i.json"
  [ -s "$out" ] && { echo "skip inc$i (exists)"; continue; }
  prompt="$(cat "$D/increments/inc$i.md")

When done, end your reply with one line: 'Governing doctrine this session: <first heading of the CLAUDE.md you operated under>'."
  ( cd "$REPO" && timeout 1500 claude -p "$prompt" --model claude-opus-4-8 \
      --output-format json --allowedTools "$TOOLS" < /dev/null ) > "$out" 2> "$LOG/inc$i.err"
  rc=$?
  if [ $rc -ne 0 ] || [ ! -s "$out" ]; then
    echo "RETRY inc$i (rc=$rc)"
    ( cd "$REPO" && timeout 1500 claude -p "$prompt" --model claude-opus-4-8 \
        --output-format json --allowedTools "$TOOLS" < /dev/null ) > "$out" 2>> "$LOG/inc$i.err"
    rc=$?
    [ $rc -ne 0 ] && echo "FAIL inc$i rc=$rc" >> "$LOG/CHAIN-ERRORS.txt"
  fi
  ( cd "$REPO" && find . -type f -not -path './.git/*' | sort | xargs wc -c 2>/dev/null | tail -1 ) > "$LOG/inc$i.reposize"
  echo "done arm-$ARM inc$i (rc=$rc)"
done
echo "CHAIN COMPLETE: arm $ARM"
