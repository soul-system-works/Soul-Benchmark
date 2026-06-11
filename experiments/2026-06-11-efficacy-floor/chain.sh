#!/bin/bash
# Floor discriminator — arm F runner over the program's frozen chains.
# Usage: chain.sh <chain>   chain in m|r
# Reuses the parent chain's increments verbatim; only CLAUDE.md differs (floor doc).
# P4 protocol: fresh `claude -p` per increment, artifact-only continuity, scoped
# tools, JSON output for usage; arm validity from content+cost (STUDY-007), never
# exit codes alone. seq -f "%02g" — NEVER seq -w (the chain-R empty-prompt bug).
set -u
D="$(cd "$(dirname "$0")" && pwd)"
CHAIN="${1:?chain m|r}"

case "$CHAIN" in
  m) SRC="$D/../2026-06-10-efficacy-chain-m"; N=11
     TOOLS="Read,Write,Edit,Glob,Grep,Bash(omc:*),Bash(ls:*),Bash(mkdir:*)"
     REPO="$D/arms/minibop-f"; FLOOR="$D/floor-claude-m.md" ;;
  r) SRC="$D/../2026-06-10-efficacy-chain-r"; N=9
     TOOLS="Read,Write,Edit,Glob,Grep,Bash(python3:*),Bash(ls:*),Bash(mkdir:*)"
     REPO="$D/arms/rom-f"; FLOOR="$D/floor-claude-r.md" ;;
  *) echo "chain must be m|r"; exit 2 ;;
esac

LOG="$D/arms/log-$CHAIN-f"; mkdir -p "$REPO" "$LOG"

if [ ! -f "$REPO/CLAUDE.md" ]; then
  cp "$FLOOR" "$REPO/CLAUDE.md"
  echo "installed floor CLAUDE.md (chain $CHAIN)"
fi

for i in $(seq -f "%02g" 1 "$N"); do
  out="$LOG/inc$i.json"
  [ -s "$out" ] && { echo "skip inc$i (exists)"; continue; }
  prompt="$(cat "$SRC/increments/inc$i.md")

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
  # STUDY-007 inline validity scan: cost + content, never exit code alone
  python3 - "$out" "$i" << 'PYEOF'
import json, sys
p, inc = sys.argv[1], sys.argv[2]
try:
    d = json.load(open(p))
    res = d.get("result") or ""
    cost = d.get("total_cost_usd", 0)
    flags = []
    if len(res) < 200: flags.append(f"SHORT result ({len(res)} chars)")
    if cost < 0.05: flags.append(f"LOW cost (${cost:.3f})")
    if "don't see a task" in res.lower() or "no task" in res.lower()[:200]: flags.append("EMPTY-PROMPT smell")
    if flags: print(f"  !! VALIDITY inc{inc}: " + "; ".join(flags))
    else: print(f"  ok inc{inc}: ${cost:.2f}, {len(res)} chars")
except Exception as e:
    print(f"  !! VALIDITY inc{inc}: unparseable JSON ({e})")
PYEOF
  echo "done floor chain-$CHAIN inc$i (rc=$rc)"
done
echo "CHAIN COMPLETE: floor-$CHAIN"
