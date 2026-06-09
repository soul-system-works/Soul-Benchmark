#!/bin/bash
# Full Phase-1 sweep for one model: all probes × conds at n=5. Resumable (run.sh skips
# completed arms). Usage: sweep.sh <model-id> <model-label>
set -u
D="$(cd "$(dirname "$0")" && pwd)"
MODEL="${1:?model id}"; ML="${2:?model label}"
for spec in "p11 pre" "p11 post" "p12 pre" "p12 post" "p12 floor" \
            "p13 pre" "p13 post" "p13 floor" "p14 pre" "p14 post" "p14 floor"; do
  set -- $spec
  "$D/run.sh" "$MODEL" "$ML" 5 "$1" "$2" || echo "CELL-FAIL $1 $2 $ML" >> "$D/arms/SWEEP-ERRORS.txt"
done
echo "SWEEP COMPLETE: $ML"
