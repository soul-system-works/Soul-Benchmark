#!/bin/bash
# Full A019-probe sweep for one model: all conds at n=5. Resumable (run.sh skips
# completed arms). Usage: sweep.sh <model-id> <model-label>
set -u
D="$(cd "$(dirname "$0")" && pwd)"
MODEL="${1:?model id}"; ML="${2:?model label}"
for cd in pre post floor; do
  "$D/run.sh" "$MODEL" "$ML" 5 "$cd" || echo "CELL-FAIL $cd $ML" >> "$D/arms/SWEEP-ERRORS.txt"
done
echo "SWEEP COMPLETE: $ML"
