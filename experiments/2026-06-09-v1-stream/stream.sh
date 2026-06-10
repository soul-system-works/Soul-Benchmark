#!/bin/bash
# Sequential-stream experiment (Phase 3). Stages:
#   canonical — build states S1..S8 (no doctrine), sequential
#   off       — measured soul-off runs: task N on pristine S(N-1)
#   on        — measured soul-on runs: task N on pristine S(N-1) + seed CLAUDE.md +
#               accumulated record/ from soul-on's prior runs (code discarded, record kept)
# Tokens from --output-format json. Quality check: go build + go test after each
# measured run, recorded alongside. See PREDICTION.md (locked first).
# Usage: stream.sh canonical | stream.sh off | stream.sh on
set -u
D="$(cd "$(dirname "$0")" && pwd)"; A="$D/arms"
MODEL="claude-sonnet-4-6"
TOOLS="Read,Write,Edit,Glob,Grep,Bash(go:*),Bash(gofmt:*),Bash(ls:*),Bash(mkdir:*)"
SEED="$D/../2026-06-09-v1-erosion-audit/vehicle/doctrine-post.md"
STAGE="${1:?stage canonical|off|on}"
mkdir -p "$A"

sess(){ # $1=dir $2=prompt $3=outjson
  ( cd "$1" && timeout 1200 claude -p "$2" --model "$MODEL" \
      --output-format json --allowedTools "$TOOLS" < /dev/null ) > "$3" 2>"$3.err"
  local rc=$?
  if [ $rc -ne 0 ] || [ ! -s "$3" ]; then
    echo "RETRY $(basename "$3") rc=$rc"
    ( cd "$1" && timeout 1200 claude -p "$2" --model "$MODEL" \
        --output-format json --allowedTools "$TOOLS" < /dev/null ) > "$3" 2>>"$3.err"
    rc=$?; [ $rc -ne 0 ] && echo "FAIL $(basename "$3") rc=$rc" >> "$A/STREAM-ERRORS.txt"
  fi
}

# Harness-side Go: absolute path, NOT in the sessions' PATH (sessions are uniformly
# go-less — discovered post-canonical, pre-measured; recorded as a symmetric bound).
GO="$HOME/.local/go-harness/go/bin/go"
quality(){ # $1=dir $2=tag
  ( cd "$1" && "$GO" build ./... > "$A/$2.build" 2>&1 && "$GO" test ./... > "$A/$2.test" 2>&1 \
      && echo PASS || echo FAIL ) > "$A/$2.quality"
}

case "$STAGE" in
  canonical)
    mkdir -p "$A/S0"
    for n in 1 2 3 4 5 6 7 8; do
      [ -d "$A/S$n" ] && { echo "skip S$n (exists)"; continue; }
      cp -r "$A/S$((n-1))" "$A/S$n"
      sess "$A/S$n" "$(cat "$D/tasks/t$n.md")" "$A/canonical-t$n.json"
      quality "$A/S$n" "canonical-t$n"
      echo "done canonical t$n ($(cat "$A/canonical-t$n.quality"))"
    done ;;
  off)
    for n in 1 2 3 4 5 6 7 8; do
      [ -s "$A/off-t$n.json" ] && { echo "skip off-t$n (exists)"; continue; }
      [ -d "$A/S$((n-1))" ] || { echo "canonical S$((n-1)) missing" >&2; exit 1; }
      W="$A/wd-off-t$n"; rm -rf "$W"; cp -r "$A/S$((n-1))" "$W"
      sess "$W" "$(cat "$D/tasks/t$n.md")" "$A/off-t$n.json"
      quality "$W" "off-t$n"
      echo "done off t$n ($(cat "$A/off-t$n.quality"))"
    done ;;
  on)
    mkdir -p "$A/record-acc"
    for n in 1 2 3 4 5 6 7 8; do
      [ -s "$A/on-t$n.json" ] && { echo "skip on-t$n (exists)"; continue; }
      [ -d "$A/S$((n-1))" ] || { echo "canonical S$((n-1)) missing" >&2; exit 1; }
      W="$A/wd-on-t$n"; rm -rf "$W"; cp -r "$A/S$((n-1))" "$W"
      cp "$SEED" "$W/CLAUDE.md"
      [ -n "$(ls -A "$A/record-acc" 2>/dev/null)" ] && cp -r "$A/record-acc/." "$W/"
      P="$(cat "$D/tasks/t$n.md")

Operate under this project's CLAUDE.md. Record what a later session cannot re-derive."
      sess "$W" "$P" "$A/on-t$n.json"
      quality "$W" "on-t$n"
      # Harvest record artifacts (not code): witness/findings/ideas/.soul/decision docs
      for r in witness.md ideas.md findings .soul docs; do
        [ -e "$W/$r" ] && cp -r "$W/$r" "$A/record-acc/" 2>/dev/null
      done
      echo "done on t$n ($(cat "$A/on-t$n.quality")) record-acc: $(find "$A/record-acc" -type f | wc -l) files"
    done ;;
  *) echo "unknown stage: $STAGE" >&2; exit 1 ;;
esac
echo "STAGE COMPLETE: $STAGE"
