#!/usr/bin/env bash
# make-arms.sh — create the three arm folders of the workflow-value experiment.
#
#   ./make-arms.sh                         # creates /mnt/d/Projects/soul/wf-value-arms/{A,B,C}
#   WFV_ARMS_BASE=/tmp/x ./make-arms.sh    # anywhere else (how the script was tested)
#
# Each arm: its own git repo holding SPEC.md, check.mjs and a .gitignore (.ai/,
# node_modules/), one commit "start". B and C are also minimal Soul projects: a
# CLAUDE.md that imports the installed Soul contract (the line /soul-init writes),
# and witness.md and ideas.md holding just a heading. A is plain.
# MANIFEST.txt beside the arms holds the sha256 of each arm's check.mjs and SPEC.md,
# so an arm that edits its own check or spec shows up: `sha256sum -c MANIFEST.txt`.
# Refuses to run if any arm folder (or the manifest) already exists.
set -euo pipefail
KIT="$(cd "$(dirname "$0")" && pwd)"
BASE="${WFV_ARMS_BASE:-/mnt/d/Projects/soul/wf-value-arms}"

for x in A B C MANIFEST.txt; do
  if [ -e "$BASE/$x" ]; then echo "refusing: $BASE/$x already exists" >&2; exit 1; fi
done
mkdir -p "$BASE"
# Playwright for the arms, installed in their parent folder (Node finds it walking up),
# so check.mjs needs no path back to this kit.
cp "$KIT/package.json" "$KIT/package-lock.json" "$BASE/"
( cd "$BASE" || exit 1; npm ci --no-audit --no-fund --silent )

for arm in A B C; do
  d="$BASE/$arm"
  mkdir "$d"
  cp "$KIT/check.mjs" "$d/"
  # The arm's copy of the spec opens with the game's name only: the kit's first heading
  # says it is the experiment's task, which would tell the arm it is being tested.
  sed '1s/.*/# Orbit Courier/' "$KIT/SPEC.md" > "$d/SPEC.md"
  printf '.ai/\nnode_modules/\n' > "$d/.gitignore"
  if [ "$arm" != A ]; then
    printf '@~/.claude/plugins/marketplaces/soul-system/operations/CLAUDE.md\n' > "$d/CLAUDE.md"
    printf '# Witness log\n' > "$d/witness.md"
    printf '# Ideas\n' > "$d/ideas.md"
  fi
  git -C "$d" init -q -b main
  git -C "$d" add -A
  git -C "$d" -c core.hooksPath=/dev/null -c user.name=wf-value-kit -c user.email=kit@local \
    commit -q -m start
  echo "made $d ($(git -C "$d" ls-files | tr '\n' ' '))"
done

( cd "$BASE" || exit 1; sha256sum A/check.mjs A/SPEC.md B/check.mjs B/SPEC.md C/check.mjs C/SPEC.md ) \
  > "$BASE/MANIFEST.txt"
echo "wrote $BASE/MANIFEST.txt"
