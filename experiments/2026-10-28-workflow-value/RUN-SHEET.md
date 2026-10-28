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

Start the screen recording, then open a fresh terminal in the arm folder. Put every
arm in the **same permission mode** before the first prompt — the one you normally work
in (e.g. auto mode, Shift+Tab) — so no arm is slowed by prompts the others don't get.

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
| A | 11:58 | 12:03 | - | - | 
| B | 12:06 | 12:12 | | |
| C | 12:14 | 12:23| | |


## Usage

### A
Total cost:            $0.74
Total duration (API):  2m 52s
Total duration (wall): 7m 1s
Total code changes:    714 lines added, 0 lines removed
Usage by model:
    claude-haiku-5-5:  1.2k input, 17 output, 0 cache read, 0 cache write ($0.0001)
     claude-opus-5-5:  16 input, 19.8k output, 355.2k cache read, 34.4k cache write ($0.74)
Prompt cache (main):   8 requests · 91% of input tokens from cache · no misses · warm (1h TTL, last activity 2m 15s ago)

### B
Total cost:            $1.11
Total duration (API):  4m 3s
Total duration (wall): 15m 3s
Total code changes:    777 lines added, 1 line removed
Usage by model:
    claude-haiku-5-5:  1.2k input, 17 output, 0 cache read, 0 cache write ($0.0001)
     claude-opus-5-5:  22 input, 26.8k output, 697.8k cache read, 54.6k cache write ($1.11)
Prompt cache (main):   11 requests · 93% of input tokens from cache · no misses · warm (1h TTL, last activity 1m 1s ago)

### C
Total cost:            $1.42
Total duration (API):  3m 58s
Total duration (wall): 26m 56s
Total code changes:    70 lines added, 0 lines removed
Usage by model:
     claude-opus-5-5:  74 input, 18.1k output, 2.5m cache read, 70.5k cache write ($1.42)
Prompt cache (main):   32 requests · 97% of input tokens from cache · no misses · warm (1h TTL, last activity 1m 4s ago)

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
