#!/bin/bash
# F044 OPEN RUNGS (Phase 2 of the v1 evaluation study) — interaction / middle-position /
# multi-fact / long-decay, on the SOUL-123 vehicle family. See PREDICTION.md (locked
# before first arm). Records inlined into -p (NEVER @-import — F038). No sentinel ask,
# matching the prior longitudinal family for comparability.
# Usage: run.sh <model-id> <model-label> <n> <rung> <cond> [depth]
#   rung in r1|r2|r3|r4
#   r1 cond in interaction|donly|floor ; r2 cond in middle|control ;
#   r3 cond in withrecord|control|floor ; r4 cond in withrecord|control (depth 50|100)
set -u
D="$(cd "$(dirname "$0")" && pwd)"; WD=/tmp/v1-f044-wd; OUT="$D/arms"; POOL="$OUT/pool"; V="$D/vehicle"
mkdir -p "$WD" "$POOL" "$OUT"
MODEL="${1:?model id}"; ML="${2:?model label}"; N="${3:-5}"; RG="${4:?rung}"; CD="${5:?cond}"; DEPTH="${6:-0}"

# Split the combined pool once (idempotent): 21 original + 85 extension = p0..p105.
# ANCHOR (control stand-in for D) = p105: never inside any burial range (max p0..p99).
if [ ! -f "$POOL/p0.md" ]; then
  { cat "$V/pool-raw.txt"; echo; echo "===ADR==="; echo; cat "$V/pool-ext.txt"; } > "$POOL/combined.txt"
  awk -v out="$POOL" 'BEGIN{i=0} /^===ADR===/{i++; next} {print >> (out"/p"i".md")}' "$POOL/combined.txt"
  echo "split pool → $(ls "$POOL"/p*.md | wc -l) files"
fi
[ -f "$POOL/p105.md" ] || { echo "pool incomplete (need p0..p105)" >&2; exit 1; }
ANCHOR="$POOL/p105.md"

cat_seq(){ local a="$1" b="$2" i; for i in $(seq "$a" "$b"); do echo; echo; cat "$POOL/p$i.md"; done; }

run_one(){ ( cd "$WD" && claude -p "$1" --model "$MODEL" < /dev/null ) > "$2" 2>&1; }

TASK="$(cat "$V/s3-post.md")"   # SendPayout (r1/r2/r4)
case "$RG-$CD" in
  r1-interaction) REC="$(cat "$V/adr-D.md")$(cat_seq 0 4)

$(cat "$V/adr-conflict.md")" ;;
  r1-donly)       REC="$(cat "$V/adr-D.md")$(cat_seq 0 5)" ;;
  r1-floor)       REC="" ;;
  r2-middle)      REC="$(cat "$POOL/p0.md")$(cat_seq 1 9)

$(cat "$V/adr-D.md")$(cat_seq 10 19)" ;;
  r2-control)     REC="$(cat "$POOL/p0.md")$(cat_seq 1 9)

$(cat "$ANCHOR")$(cat_seq 10 19)" ;;
  r3-withrecord)  REC="$(cat "$V/adr-D2.md")

$(cat "$POOL/p0.md")

$(cat "$V/adr-D.md")

$(cat "$POOL/p1.md")

$(cat "$V/adr-D3.md")

$(cat "$POOL/p2.md")"; TASK="$(cat "$V/r3-task.md")" ;;
  r3-control)     REC="$(cat "$ANCHOR")$(cat_seq 0 4)"; TASK="$(cat "$V/r3-task.md")" ;;
  r3-floor)       REC=""; TASK="$(cat "$V/r3-task.md")" ;;
  r4-withrecord)  [ "$DEPTH" -ge 1 ] || { echo "r4 needs depth" >&2; exit 1; }
                  REC="$(cat "$V/adr-D.md")$(cat_seq 0 $((DEPTH-1)))" ;;
  r4-control)     [ "$DEPTH" -ge 1 ] || { echo "r4 needs depth" >&2; exit 1; }
                  REC="$(cat "$ANCHOR")$(cat_seq 0 $((DEPTH-1)))" ;;
  *) echo "unknown rung-cond: $RG-$CD" >&2; exit 1 ;;
esac

if [ -z "$REC" ]; then
  if [ "$RG" = r3 ]; then
    P="You are a senior engineer on the \"Ledger\" payments service (Go).
$TASK"
  else
    P="$(cat "$V/s3-floor.md")"
  fi
else
  P="$(cat "$V/s3-pre.md")

$REC

$TASK"
fi

TAG="${RG}-${CD}$([ "$DEPTH" -gt 0 ] && echo "-d$DEPTH")"
printf '%s' "$P" > "$OUT/${TAG}-PROMPT.txt"
for i in $(seq 1 "$N"); do
  f="$OUT/${TAG}-$ML-$i.txt"
  [ -s "$f" ] && { echo "skip ${TAG}-$ML-$i (exists)"; continue; }
  run_one "$P" "$f"; echo "done ${TAG}-$ML-$i"
done
