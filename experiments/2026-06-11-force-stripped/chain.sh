#!/bin/bash
# Force-stripped discriminator — runner. Usage: chain.sh <arm>  arm in s|g|f
# Chain R's 9 increments, incident force stripped (inc02/inc04 edited; rest verbatim).
# seq -f "%02g" — NEVER seq -w (the chain-R empty-prompt bug).
set -u
D="$(cd "$(dirname "$0")" && pwd)"
ARM="${1:?arm s|g|f}"
N=9
TOOLS="Read,Write,Edit,Glob,Grep,Bash(python3:*),Bash(ls:*),Bash(mkdir:*)"
REPO="$D/arms/rom-$ARM"; LOG="$D/arms/log-$ARM"; mkdir -p "$REPO" "$LOG"

if [ ! -f "$REPO/CLAUDE.md" ]; then
  case "$ARM" in
    s) cp "$D/../2026-06-10-v11-a019-gate-block/vehicle/doctrine-v110.md" "$REPO/CLAUDE.md" ;;
    g) cp "$D/../2026-06-10-efficacy-chain-r/comparator-claude.md" "$REPO/CLAUDE.md" ;;
    f) cp "$D/../2026-06-11-efficacy-floor/floor-claude-r.md" "$REPO/CLAUDE.md" ;;
  esac
  echo "installed CLAUDE.md (arm $ARM)"
fi

for i in $(seq -f "%02g" 1 "$N"); do
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
  echo "done fs arm-$ARM inc$i (rc=$rc)"
done
echo "CHAIN COMPLETE: fs-$ARM"
