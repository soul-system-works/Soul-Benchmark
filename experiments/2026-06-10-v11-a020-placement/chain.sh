#!/bin/bash
# v1.1 VERIFICATION PASS — A020/Rule-14 placement probe (SOUL-I048 part A).
# ONE new in-vivo chain (arm C): CLAUDE.md = v1.1.0 doctrine; the SAME frozen 12
# increments as the v1.0 twin study (referenced, not copied — comparability).
# Baselines are the recorded v1.0 arms (A soul / B control), cited from that
# experiment's RESULT.md — their repos were gitignored and cleaned, so this is a
# fresh-chain comparison against recorded results, not a snapshot replay.
# Protocol identical to the study chain: fresh `claude -p` per increment, no
# conversational carryover, scoped allowlist, sessions go-less (comparability with
# arms A/B — the A019 give-an-executor rule is deliberately suspended HERE ONLY,
# as the handoff cursor records). Usage: chain.sh
set -u
D="$(cd "$(dirname "$0")" && pwd)"
TWIN="$D/../2026-06-09-v1-invivo-twin"
REPO="$D/arms/relay-c"; LOG="$D/arms/log-c"; mkdir -p "$REPO" "$LOG"

TOOLS="Read,Write,Edit,Glob,Grep,Bash(go:*),Bash(gofmt:*),Bash(ls:*),Bash(mkdir:*),Bash(sqlite3:*)"

if [ ! -f "$REPO/CLAUDE.md" ]; then
  cp "$D/../2026-06-10-v11-a019-gate-block/vehicle/doctrine-v110.md" "$REPO/CLAUDE.md"
  echo "installed CLAUDE.md (arm C = v1.1.0 doctrine)"
fi

for i in $(seq -w 1 12); do
  out="$LOG/inc$i.json"
  [ -s "$out" ] && { echo "skip inc$i (exists)"; continue; }
  prompt="$(cat "$TWIN/increments/inc$i.md")

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
  echo "done arm-C inc$i (rc=$rc)"
done
echo "CHAIN COMPLETE: arm C"
