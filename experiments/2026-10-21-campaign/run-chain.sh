#!/usr/bin/env bash
# 2026-10-21 campaign — one arm through a chain's increments (PLAN.md §3–§7).
# Usage: run-chain.sh <arm> <chain> <model> <provider> [first] [last]
#   arm      F G S GP SP GS SS
#   chain    r j m           (June increment prompts, unchanged)
#   model    sonnet | opus | haiku | <ollama model> | <codex model>
#   provider claude | ollama | codex
# Arm repos live OUTSIDE this tree (~/soul-bench-arms/runs/), each its own git repo,
# so no session can read PREDICTION.md or this repo's log (the June leak).
# Isolation (RESULT-phase0-isolation.md): user settings, MCP, the global CLAUDE.md
# and auto-memory are all kept out; plugins come in only by --plugin-dir.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"; EXP="$(cd "$HERE/.." && pwd)"
ARM="${1:?arm}"; CHAIN="${2:?chain}"; MODEL="${3:?model}"; PROV="${4:?provider}"
ROOT=~/soul-bench-arms; PLUG=$ROOT/plugins
case "$CHAIN" in
  r) SRC=$EXP/2026-06-10-efficacy-chain-r; N=9;  EXTRA="Bash(python3:*),Bash(python:*),Bash(pytest:*),Bash(PYTHONPATH=src python3:*),Bash(PYTHONPATH=src python:*),Bash(PYTHONPATH=src pytest:*)";
     FLOOR=$EXP/2026-06-11-efficacy-floor/floor-claude-r.md ;;
  m) SRC=$EXP/2026-06-10-efficacy-chain-m; N=11; EXTRA="Bash(omc:*)";
     FLOOR=$EXP/2026-06-11-efficacy-floor/floor-claude-m.md ;;
  j) SRC=$EXP/2026-06-10-efficacy-chain-j; N=11; EXTRA="Bash(node:*)"; FLOOR="" ;;
  *) echo "bad chain"; exit 2 ;;
esac
FIRST="${5:-1}"; LAST="${6:-$N}"
TOOLS="Read,Write,Edit,Glob,Grep,Bash(ls:*),Bash(mkdir:*),Bash(pip list:*),$EXTRA"
TAG="${CHAIN}-${ARM}-${PROV}-${MODEL//[:\/]/_}"
REPO=$ROOT/runs/$TAG/repo; LOG=$ROOT/runs/$TAG/log; mkdir -p "$REPO" "$LOG"

case "$ARM" in
  F) DOC=$FLOOR; SOUL=0; PD=() ;;
  G) DOC=$SRC/comparator-claude.md; SOUL=0; PD=() ;;
  S) DOC=$PLUG/soul-system/operations/CLAUDE.md; SOUL=1; PD=(--plugin-dir $PLUG/soul-system) ;;
  GP) DOC=$SRC/comparator-claude.md; SOUL=0; PD=(--plugin-dir $PLUG/mattpocock-skills) ;;
  SP) DOC=$PLUG/soul-system/operations/CLAUDE.md; SOUL=1; PD=(--plugin-dir $PLUG/soul-system --plugin-dir $PLUG/mattpocock-skills) ;;
  GS) DOC=$SRC/comparator-claude.md; SOUL=0; PD=(--plugin-dir $PLUG/superpowers) ;;
  SS) DOC=$PLUG/soul-system/operations/CLAUDE.md; SOUL=1; PD=(--plugin-dir $PLUG/soul-system --plugin-dir $PLUG/superpowers) ;;
  *) echo "bad arm"; exit 2 ;;
esac
[ -n "$DOC" ] && [ -f "$DOC" ] || { echo "no doctrine for $ARM/$CHAIN"; exit 2; }
DOCNAME=CLAUDE.md; [ "$PROV" = codex ] && DOCNAME=AGENTS.md
if [ ! -d "$REPO/.git" ]; then
  git -C "$REPO" init -q
  cp "$DOC" "$REPO/$DOCNAME"
  # Soul arms get what /soul-init leaves behind, so the gate scopes as in real use.
  [ $SOUL = 1 ] && printf '# Witness log\n' > "$REPO/witness.md" && printf '# Ideas\n' > "$REPO/ideas.md"
  snap() { git -C "$REPO" add -A && git -C "$REPO" -c core.hooksPath=/dev/null \
    -c user.name=harness -c user.email=harness@local commit -q --allow-empty -m "$1"; }
  snap "inc00 install $ARM"
fi
snap() { git -C "$REPO" add -A && git -C "$REPO" -c core.hooksPath=/dev/null \
  -c user.name=harness -c user.email=harness@local commit -q --allow-empty -m "$1"; }

SETTINGS='{"claudeMdExcludes":["/home/fig/.claude/CLAUDE.md"],"autoMemoryEnabled":false,"permissions":{"deny":["Read(//mnt/d/**)","Read(//home/fig/soul-bench-arms/plugins/**)"]}}'
ENVV=(); case "$PROV" in
  claude) PRE=(claude -p); CMD=(--model "$MODEL" --setting-sources project --strict-mcp-config
               --settings "$SETTINGS" "${PD[@]}" --output-format json --allowedTools "$TOOLS") ;;
  ollama) ENVV=(ANTHROPIC_BASE_URL=http://localhost:11434 ANTHROPIC_AUTH_TOKEN=ollama ANTHROPIC_API_KEY=)
          PRE=(claude -p); CMD=(--model "$MODEL" --setting-sources project --strict-mcp-config
               --settings "$SETTINGS" "${PD[@]}" --output-format json --allowedTools "$TOOLS") ;;
  codex)  PRE=(codex exec --ignore-user-config -m "$MODEL" -s workspace-write --skip-git-repo-check
               --json -o "$LOG/.last.txt"); CMD=() ;;
  *) echo "bad provider"; exit 2 ;;
esac

for i in $(seq -f "%02g" "$FIRST" "$LAST"); do
  out="$LOG/inc$i.json"
  [ -s "$out" ] && { echo "skip $TAG inc$i (exists)"; continue; }
  # Budget guard (Body D1): stop starting sessions once the campaign's notional Claude
  # spend reaches CAP_USD. Sessions already in flight finish; overshoot ≤ one per arm.
  if [ -n "${CAP_USD:-}" ] && [ "$PROV" = claude ]; then
    spent=$(python3 -c 'import json,glob,os,sys
t=0
for f in glob.glob(os.path.expanduser("~/soul-bench-arms/runs/*-claude-*/log/*.json")):
    try: t+=json.load(open(f)).get("total_cost_usd") or 0
    except Exception: pass
print(round(t,2))')
    if python3 -c "import sys; sys.exit(0 if $spent >= $CAP_USD else 1)"; then
      echo "CAP reached: \$$spent >= \$$CAP_USD — stopping $TAG before inc$i"; exit 0; fi
  fi
  pf="$SRC/increments/inc$i.md"; [ -s "$pf" ] || { echo "EMPTY PROMPT $pf"; exit 3; }
  prompt="$(cat "$pf")

When done, end your reply with one line: 'Governing doctrine this session: <first heading of the CLAUDE.md you operated under>'."
  [ "$PROV" = codex ] && prompt="${prompt//CLAUDE.md/AGENTS.md}"
  t0=$(date +%s)
  ( cd "$REPO" && env "${ENVV[@]}" timeout 1500 "${PRE[@]}" "$prompt" "${CMD[@]}" < /dev/null ) > "$out" 2> "$LOG/inc$i.err"
  rc=$?; echo "$(( $(date +%s)-t0 ))" > "$LOG/inc$i.wall"
  snap "inc$i rc=$rc"
  if [ "$CHAIN" = r ]; then
    ( cd "$REPO" && PYTHONPATH=src:. PYTHONDONTWRITEBYTECODE=1 timeout 600 python3 -m pytest -q -p no:cacheprovider 2>&1 | tail -3 ) > "$LOG/inc$i.tests"
  fi
  echo "done $TAG inc$i rc=$rc wall=$(cat "$LOG/inc$i.wall")s"
done
