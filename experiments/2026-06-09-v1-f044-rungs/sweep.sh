#!/bin/bash
# Full Phase-2 sweep for one model: all rungs × conds at n=5. Resumable.
# Usage: sweep.sh <model-id> <model-label>
set -u
D="$(cd "$(dirname "$0")" && pwd)"
MODEL="${1:?model id}"; ML="${2:?model label}"
for spec in "r1 interaction 0" "r1 donly 0" "r1 floor 0" \
            "r2 middle 0" "r2 control 0" \
            "r3 withrecord 0" "r3 control 0" "r3 floor 0" \
            "r4 withrecord 50" "r4 control 50" "r4 withrecord 100" "r4 control 100"; do
  set -- $spec
  "$D/run.sh" "$MODEL" "$ML" 5 "$1" "$2" "$3" || echo "CELL-FAIL $1 $2 $3 $ML" >> "$D/arms/SWEEP-ERRORS.txt"
done
echo "SWEEP COMPLETE: $ML"
