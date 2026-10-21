#!/usr/bin/env bash
# Usage: run-probe.sh <probe> <cell> <rep> [model]
#   creativity cells: G S GP SP GS SS     purge cells: Sstale SstaleRev Gstale Sremoved
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; PR=$HERE/probes
PROBE="${1:?}"; CELL="${2:?}"; REP="${3:?}"; MODEL="${4:-sonnet}"
ROOT=~/soul-bench-arms; PLUG=$ROOT/plugins; CONTRACT=$PLUG/soul-system/operations/CLAUDE.md
TAG="probe-$PROBE-$CELL-$REP-${MODEL//[:\/]/_}"; REPO=$ROOT/runs/$TAG/repo; LOG=$ROOT/runs/$TAG/log
[ -s "$LOG/out.json" ] && { echo "skip $TAG"; exit 0; }
if [ -n "${CAP_USD:-}" ]; then  # budget guard, same total as run-chain.sh
  spent=$(python3 -c 'import json,glob,os
t=0
for f in glob.glob(os.path.expanduser("~/soul-bench-arms/runs/*-claude-*/log/*.json"))+glob.glob(os.path.expanduser("~/soul-bench-arms/runs/probe-*/log/out.json")):
    try: t+=json.load(open(f)).get("total_cost_usd") or 0
    except Exception: pass
print(round(t,2))')
  python3 -c "import sys; sys.exit(0 if $spent >= $CAP_USD else 1)" && { echo "CAP reached: \$$spent — skip $TAG"; exit 0; }
fi
rm -rf "$ROOT/runs/$TAG"; mkdir -p "$REPO" "$LOG"; cp -r "$PR/$PROBE/project/." "$REPO/"
PREFIX=""; SOUL=0; PD=()
case "$PROBE:$CELL" in
  creativity:G)  NOTES=$PR/creativity/project-notes.md ;;
  creativity:S)  NOTES=$PR/creativity/project-notes.md; SOUL=1 ;;
  creativity:GP) NOTES=$PR/creativity/project-notes.md; PD=(--plugin-dir $PLUG/mattpocock-skills) ;;
  creativity:SP) NOTES=$PR/creativity/project-notes.md; SOUL=1; PD=(--plugin-dir $PLUG/mattpocock-skills) ;;
  creativity:GS) NOTES=$PR/creativity/project-notes.md; PD=(--plugin-dir $PLUG/superpowers) ;;
  creativity:SS) NOTES=$PR/creativity/project-notes.md; SOUL=1; PD=(--plugin-dir $PLUG/superpowers) ;;
  purge:Sstale)    NOTES=$PR/purge/project-notes-stale.md; SOUL=1 ;;
  purge:SstaleRev) NOTES=$PR/purge/project-notes-stale.md; SOUL=1; PREFIX="$(cat $PR/purge/review-step.md)" ;;
  purge:Gstale)    NOTES=$PR/purge/project-notes-stale.md ;;
  purge:Sremoved)  NOTES=$PR/purge/project-notes-removed.md; SOUL=1 ;;
  *) echo "bad probe/cell"; exit 2 ;;
esac
if [ $SOUL = 1 ]; then
  { cat "$CONTRACT"; echo; cat "$NOTES"; } > "$REPO/CLAUDE.md"
  printf '# Witness log\n' > "$REPO/witness.md"; PD=(--plugin-dir $PLUG/soul-system "${PD[@]}")
else
  cp "$NOTES" "$REPO/CLAUDE.md"
fi
snap() { git -C "$REPO" add -A && git -C "$REPO" -c core.hooksPath=/dev/null \
  -c user.name=harness -c user.email=harness@local commit -q --allow-empty -m "$1"; }
git -C "$REPO" init -q; snap "before"
SETTINGS='{"claudeMdExcludes":["/home/fig/.claude/CLAUDE.md"],"autoMemoryEnabled":false,"permissions":{"deny":["Read(//mnt/d/**)","Read(//home/fig/soul-bench-arms/plugins/**)"]}}'
TOOLS="Read,Write,Edit,Glob,Grep,Bash(ls:*),Bash(python3:*),Bash(python:*),Bash(pytest:*)"
prompt="${PREFIX}$(cat $PR/$PROBE/prompt.md)"
t0=$(date +%s)
( cd "$REPO" && timeout 1200 claude -p "$prompt" --model "$MODEL" --setting-sources project --strict-mcp-config \
    --settings "$SETTINGS" "${PD[@]}" --output-format json --allowedTools "$TOOLS" < /dev/null ) \
    > "$LOG/out.json" 2> "$LOG/err.txt"
rc=$?; echo $(( $(date +%s)-t0 )) > "$LOG/wall"; snap "after rc=$rc"
git -C "$REPO" diff HEAD~1 HEAD > "$LOG/diff.patch"
( cd "$REPO" && PYTHONPATH=src:. PYTHONDONTWRITEBYTECODE=1 timeout 300 python3 -m pytest -q -p no:cacheprovider 2>&1 | tail -2 ) > "$LOG/tests"
echo "done $TAG rc=$rc wall=$(cat $LOG/wall)s"
