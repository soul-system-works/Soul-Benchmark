#!/bin/bash
# Efficacy program — Chain M runner. One invocation = one arm's full 11 increments.
# Usage: chain.sh <arm>   arm in s|g   (s = Soul v1.1, g = comparator)
# P4 protocol: fresh `claude -p` per increment, artifact-only continuity, scoped
# tools (node, NO npm), JSON output for usage; arm validity from content.
set -u
D="$(cd "$(dirname "$0")" && pwd)"
ARM="${1:?arm s|g}"
REPO="$D/arms/minibop-$ARM"; LOG="$D/arms/log-$ARM"; mkdir -p "$REPO" "$LOG"
N=11
TOOLS="Read,Write,Edit,Glob,Grep,Bash(omc:*),Bash(ls:*),Bash(mkdir:*)"

if [ ! -f "$REPO/CLAUDE.md" ]; then
  case "$ARM" in
    s) cp "$D/../2026-06-10-v11-a019-gate-block/vehicle/doctrine-v110.md" "$REPO/CLAUDE.md" ;;
    g) cp "$D/comparator-claude.md" "$REPO/CLAUDE.md" ;;
  esac
  echo "installed CLAUDE.md (arm $ARM)"
fi

for i in $(seq -w 1 "$N"); do
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
  echo "done chain-m arm-$ARM inc$i (rc=$rc)"
done
echo "CHAIN COMPLETE: j-$ARM"
