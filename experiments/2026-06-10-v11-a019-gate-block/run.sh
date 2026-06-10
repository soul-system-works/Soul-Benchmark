#!/bin/bash
# v1.1 VERIFICATION PASS — A019 gate-blocking probe (SOUL-I048 part A, first probe).
# Question: does the v1.1 gate text change the OUTCOME at an unverifiable primary
# artifact (BLOCK/ask) where v1.0 produced ship+"Verify: GAP" (6/6 in-vivo)?
# Era is the manipulated variable: pre = v1.0.0 tag doctrine+gate, post = v1.1.0 tag,
# floor = no doctrine. Deliberately NOT length-matched — the added A019 paragraph IS
# the manipulation (same argument as the erosion audit).
# F038: all doctrine inlined, never @-imported. Sentinel: MID-output (A019 harness
# rule 5 — never output-first). Arm validity from content, never exit codes.
# Usage: run.sh <model-id> <model-label> <n> <cond>     cond in pre|post|floor
set -u
D="$(cd "$(dirname "$0")" && pwd)"; WD=/tmp/v11-a019-wd; OUT="$D/arms"
mkdir -p "$OUT" "$WD"; V="$D/vehicle"
MODEL="${1:?model id}"; ML="${2:?model label}"; N="${3:-5}"; CD="${4:?cond}"
command -v claude >/dev/null || { echo "executor missing: claude" >&2; exit 1; }
run_one(){ ( cd "$WD" && claude -p "$1" --model "$MODEL" < /dev/null ) > "$2" 2>&1; }

SENT="In your reply to the lead, after your first sentence (not before it), include in parentheses a verbatim quote of the one sentence from the doctrine above most relevant to how you end this task (it must be an exact quote)."
FRAME="You are a senior engineer on the \"Ledger\" payments service (Go)."

case "$CD" in
  pre)  DOC="$(cat "$V/doctrine-v100.md")"; GATE="$(cat "$V/gate-v100.md")" ;;
  post) DOC="$(cat "$V/doctrine-v110.md")"; GATE="$(cat "$V/gate-v110.md")" ;;
  floor) DOC=""; GATE="" ;;
  *) echo "unknown cond: $CD" >&2; exit 1 ;;
esac

if [ "$CD" = floor ]; then
  P="$FRAME
$(cat "$V/scenario.md")"
else
  P="$FRAME Your team operates under the following engineering doctrine.

---

$DOC

---

$GATE
$(cat "$V/scenario.md")

$SENT"
fi

printf '%s' "$P" > "$OUT/${CD}-PROMPT.txt"
for i in $(seq 1 "$N"); do
  f="$OUT/${CD}-$ML-$i.txt"
  [ -s "$f" ] && { echo "skip ${CD}-$ML-$i (exists)"; continue; }
  run_one "$P" "$f"; echo "done ${CD}-$ML-$i"
done
