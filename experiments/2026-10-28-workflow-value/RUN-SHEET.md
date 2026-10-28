# Run sheet — workflow value, round 1 (for the owner)

`$KIT` below is this folder; set it once in each terminal you use:
`KIT=/mnt/d/Projects/soul/soul-benchmark/experiments/2026-10-28-workflow-value`

## Before the first arm

1. `PREDICTION.md` is locked and committed (PLAN step 3).
2. The Soul System plugin is **v3.7.2**. (When this kit was built, 3.7.0 was installed.)
   Update it with `/plugin` or `claude plugin update soul-system@soul-system`, then check:
   `python3 -c "import json,os; print(json.load(open(os.path.expanduser('~/.claude/plugins/installed_plugins.json')))['plugins']['soul-system@soul-system'][0]['version'])"`
   prints `3.7.2`, and `git -C ~/.claude/plugins/marketplaces/soul-system log --oneline -1`
   shows the v3.7.2 commit (arms B and C import the contract from that folder).
3. Make the arms: `cd $KIT || exit 1; ./make-arms.sh` — creates
   `/mnt/d/Projects/soul/wf-value-arms/{A,B,C}` and `MANIFEST.txt`.

## Each arm (any order; one sitting if you can)

Start the screen recording, then open a fresh terminal in the arm folder.

| Arm | Folder | Launch line |
|---|---|---|
| A · plain | `cd /mnt/d/Projects/soul/wf-value-arms/A \|\| exit 1` | `claude --model opus --setting-sources "" --strict-mcp-config --settings '{"claudeMdExcludes":["/home/fig/.claude/CLAUDE.md"],"autoMemoryEnabled":false}'` |
| B · normal | `cd /mnt/d/Projects/soul/wf-value-arms/B \|\| exit 1` | `claude --model opus` |
| C · workflow | `cd /mnt/d/Projects/soul/wf-value-arms/C \|\| exit 1` | `claude --model opus` |

First prompt, pasted exactly:

- **A and B:** `Build the game described in SPEC.md in this folder. Done when: node check.mjs passes.`
- **C:** `/soul-workflow build-verify Build the game described in SPEC.md in this folder. Done when: node check.mjs passes.`

While it runs:

- Note every time you step in (answer a question, correct, nudge): the clock time and
  what you typed. Keep approving permission prompts as a separate tally — arm A has
  none of your allow-lists, so it will ask more.
- **Stop** when the arm says it is done, or at **90 minutes** from the first prompt,
  whichever comes first. Note the clock time of "done". Then `/exit`.

| Arm | First prompt at | "Done" at | Stepped in (time — what) | Permission approvals |
|---|---|---|---|---|
| A | | | | |
| B | | | | |
| C | | | | |

## After all three

```bash
KIT=/mnt/d/Projects/soul/soul-benchmark/experiments/2026-10-28-workflow-value
cd /mnt/d/Projects/soul/wf-value-arms || exit 1
sha256sum -c MANIFEST.txt                       # a FAILED line: that arm edited its check or spec
mkdir -p $KIT/out
python3 $KIT/measure.py A B C --json $KIT/out/measure.json   # tokens per model, wall time, prompts
for a in A B C; do
  ( cd $a || exit 1; node $KIT/check.mjs > $KIT/out/check-$a.txt )   # the kit's own check, not the arm's copy
  node $KIT/playtest.mjs $a --out $KIT/out/playtest-$a.json > /dev/null
done
```

Then blind the games and hand them to the two scorers as `SCORING-SHEET.md` says.
Keep the coin key private until both sheets are in.
