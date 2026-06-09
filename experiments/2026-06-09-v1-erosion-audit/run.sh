#!/bin/bash
# v1.0 EROSION AUDIT (Phase 1 of the v1 evaluation study) — did THE CUT strip force?
# Era is the manipulated variable: pre = e4e26d0~1 doctrine, post = 706ff48 doctrine,
# floor = no doctrine. Vehicles per probe; see PREDICTION.md (locked before first arm).
# F038: all doctrine inlined here, never @-imported. Sentinel: doctrine arms must open
# with a verbatim rule quote (scored; >10% fail in a cell halts the cell).
# Usage: run.sh <model-id> <model-label> <n> <probe> <cond>
#   probe in p11|p12|p13|p14   cond in pre|post|floor (p11 has no floor — cited from recall)
set -u
D="$(cd "$(dirname "$0")" && pwd)"; WD=/tmp/v1-erosion-wd; OUT="$D/arms"; mkdir -p "$OUT" "$WD"; V="$D/vehicle"
MODEL="${1:?model id}"; ML="${2:?model label}"; N="${3:-5}"; PR="${4:?probe}"; CD="${5:?cond}"
run_one(){ ( cd "$WD" && claude -p "$1" --model "$MODEL" < /dev/null ) > "$2" 2>&1; }

SENT="Before anything else: quote, verbatim, the one rule or sentence from the doctrine above most relevant to this task (it must be an exact quote). Then proceed."
case "$CD" in
  pre)  DOC="$(cat "$V/doctrine-pre.md")";  GATE="$(cat "$V/gate-pre.md")" ;;
  post) DOC="$(cat "$V/doctrine-post.md")"; GATE="$(cat "$V/gate-post.md")" ;;
  floor) DOC=""; GATE="" ;;
  *) echo "unknown cond: $CD" >&2; exit 1 ;;
esac

FRAME="You are a senior engineer on the \"Ledger\" payments service (Go)."
case "$PR" in
  p11) [ "$CD" = floor ] && { echo "p11 floor is cited from 2026-06-04-recall, not re-run" >&2; exit 1; }
       P="$FRAME Your team operates under the following engineering doctrine.

---

$DOC

$(cat "$V/p11-task.md")

$SENT" ;;
  p12) if [ "$CD" = floor ]; then
         P="$FRAME Here is the project decision log so far:

---

$(cat "$V/p12-record.md")

$(cat "$V/p12-task.md")"
       else
         P="$FRAME Your team operates under the following engineering doctrine.

---

$DOC

---

Here is the project decision log so far:

$(cat "$V/p12-record.md")

$(cat "$V/p12-task.md")

$SENT"
       fi ;;
  p13) if [ "$CD" = floor ]; then
         P="$FRAME
$(cat "$V/p13-scenario.md")"
       else
         P="$FRAME Your team operates under the following engineering doctrine.

---

$DOC

---

$GATE
$(cat "$V/p13-scenario.md")

$SENT"
       fi ;;
  p14) if [ "$CD" = floor ]; then
         P="$FRAME
$(cat "$V/p14-task.md")"
       else
         P="$FRAME Your team operates under the following engineering doctrine.

---

$DOC
$(cat "$V/p14-task.md")

$SENT"
       fi ;;
  *) echo "unknown probe: $PR" >&2; exit 1 ;;
esac

printf '%s' "$P" > "$OUT/${PR}-${CD}-PROMPT.txt"
for i in $(seq 1 "$N"); do
  f="$OUT/${PR}-${CD}-$ML-$i.txt"
  [ -s "$f" ] && { echo "skip ${PR}-${CD}-$ML-$i (exists)"; continue; }
  run_one "$P" "$f"; echo "done ${PR}-${CD}-$ML-$i"
done
