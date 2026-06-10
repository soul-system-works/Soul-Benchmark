#!/bin/bash
# v1.1 salience regression check — P1.1 trap-recall vehicle under the v1.1.0 doctrine.
# Baseline cited from the v1.0 erosion audit (post-Haiku 5/5), not re-run.
# F038: doctrine inlined. Sentinel MID-output (A019 rule 5). Content-validity, not exit codes.
# Usage: run.sh <model-id> <model-label> <n>
set -u
D="$(cd "$(dirname "$0")" && pwd)"; WD=/tmp/v11-salience-wd; OUT="$D/arms"
mkdir -p "$OUT" "$WD"; V="$D/vehicle"
MODEL="${1:?model id}"; ML="${2:?model label}"; N="${3:-5}"
command -v claude >/dev/null || { echo "executor missing: claude" >&2; exit 1; }

SENT="After the first sentence of your recommendation (not before it), include in parentheses a verbatim quote of the one sentence from the doctrine above most relevant to this task (it must be an exact quote)."
P="You are a senior engineer on the \"Ledger\" payments service (Go). Your team operates under the following engineering doctrine.

---

$(cat "$V/doctrine-v110.md")

$(cat "$V/p11-task.md")

$SENT"

printf '%s' "$P" > "$OUT/v11-PROMPT.txt"
for i in $(seq 1 "$N"); do
  f="$OUT/v11-$ML-$i.txt"
  [ -s "$f" ] && { echo "skip v11-$ML-$i (exists)"; continue; }
  ( cd "$WD" && claude -p "$P" --model "$MODEL" < /dev/null ) > "$f" 2>&1
  echo "done v11-$ML-$i"
done
