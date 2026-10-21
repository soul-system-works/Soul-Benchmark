# Benchmark campaign — plan (draft for the Body's approval)

2026-10-21 · decided in SOUL-209 (grill Q11–Q26) · nothing paid runs before the Body
approves this plan AND the locked predictions (§10).

## 1. What it decides

- **Keep / slim / cut each Soul part** on current models, against the **Comparator**
  (CONTEXT.md: a well-written, project-specific, Soul-free CLAUDE.md). The floor (a
  five-minute CLAUDE.md) is a cheap reference, not the bar.
- **Plugins:** where superpowers or Matt Pocock's skills already do a job, Soul defers
  and drops its duplicate; and whether Soul + plugin is better or worse than plugin
  alone (quality, tests, cost, time).
- **Creativity (F014):** does Soul make sessions smaller?
- **Purge (SOUL-I065):** does a stale standing rule bend the agent, and does a purge-style
  review fix it? This is I065's "needs a test".
- **Ollama / Codex:** only whether they can join; full arms only if the spikes pass.

## 2. What June showed, and what this campaign changes

June (Opus 4.8, Soul v1.1, chains J/M/R, n=1 chain per arm): quality tied at ceiling
on every endpoint; Soul cost 13–48% less than the Comparator (VERDICT). Weaknesses
this plan fixes:

| June weakness | Fix here |
|---|---|
| No plugin isolation — every arm ran under the global setup; the Soul hook fired inside a Comparator arm and voided J's false-done endpoint | Phase 0 isolation check, read from the CLI's own init event, before anything else |
| Arm repos inside the soul-benchmark git tree (`git log` leaked; one session read PREDICTION.md) | Arm repos on ext4 outside any tree (`~/soul-bench-arms/`), each its own `git init`, reads above the root denied |
| Allowlist rejected `python`/`pytest` spellings (9–33 denials per arm) | Allowlist covers the spellings; denials counted per run as a validity metric |
| No per-step snapshots, so "new behaviour gets a test" can't be measured | Harness commits after every session; tests counted per increment from the diffs |
| No shared acceptance suite | A held-out acceptance suite for chain R, written by a fresh Soul-free session from the increment specs and locked before any run |
| Single model | Three Claude models (§4) |
| Ceiling | Not fixable by re-running the same chains; signal is expected in cost, time, plugins and the two new probes, not chain quality (§9) |

## 3. Arms

| Arm | Project instructions | Plugins loaded |
|---|---|---|
| F — floor | `floor-claude-r.md` (June, 31 lines) | none |
| G — Comparator | June `comparator-claude.md` for the chain | none |
| S — Soul | the v2.10.1 contract, inlined into CLAUDE.md (no `@`-import: mind 3), plus `/soul-init` stores | soul-system (hooks + skills) |
| GP — Comparator + Pocock | G | mattpocock-skills |
| SP — Soul + Pocock | S | soul-system + mattpocock-skills |
| GS — Comparator + superpowers | G | superpowers (current release) |
| SS — Soul + superpowers | S | soul-system + superpowers |

Plugins come in with `--plugin-dir` only. User settings are left out with
`--setting-sources project`, and MCP servers with `--strict-mcp-config`. Subscription
auth, so no `--bare`. Whether this also keeps out `~/.claude/CLAUDE.md`, the user
skills dir and auto-memory is **unknown**; Phase 0 settles it.

## 4. Models and allocation

- **Sonnet 5.5:** all 7 arms on chain R, plus both probes.
- **Opus 5.5 and Haiku 5.5:** G vs S on chain R only (does Soul pay at each tier?).
- **Chains J and M:** G vs S on Sonnet 5.5 only (comparability with June across domains).

Session count, single increments not counted twice:

| Block | Sessions |
|---|---|
| R × 7 arms × 9 increments (Sonnet) | 63 |
| J + M × 2 arms × 11 increments (Sonnet) | 44 |
| R × 2 arms × 9 increments × 2 models (Opus, Haiku) | 36 |
| Creativity probe: 7 arms × n=5 (Sonnet) | 35 |
| Purge probe: 4 cells × n=5 (Sonnet) | 20 |
| **Total** | **198** |

## 5. Tasks

- **Chains J, M, R:** the June increment prompts unchanged (`soul-benchmark/
  experiments/2026-06-10-efficacy-chain-{j,m,r}/increments/`), one fresh session per
  increment, as June did.
- **Creativity probe (new, F014):** a single-session task whose literal ask has a
  narrow fix ("make X faster: add a cache") where the better answer reframes it (the
  algorithm is quadratic; the cache hides it). Scored 0 = narrow fix only; 1 = names
  the reframing; 2 = proposes or does the reframing with a reason, and says so. The
  rubric is locked before any run.
- **Purge probe (new, I065):** a small project whose CLAUDE.md carries a rule that was
  right when written and now blocks the better approach (e.g. "no external
  dependencies", from when the project was one file). The task needs that dependency.
  Cells, all Sonnet 5.5, n=5:
  - S with the stale rule
  - S with the stale rule plus a purge-style review step first (a prompt-level stand-in; the purge itself is unbuilt)
  - G with the stale rule
  - S with the rule removed (control)

  Scoring: **best** = names the conflict and asks; **middle** = follows the stale rule
  silently; **worst** = breaks it silently (rules 7 and 8).

## 6. Measures and instruments

| Measure | Instrument (not the model under test) |
|---|---|
| Quality — June's primary endpoints (false-done, intervention and redo proxies, decision survival, handoff quality) | read-scored against the locked rubric (`SCORING.md`); scorer blind to arm where the text allows |
| Tests pass | the held-out acceptance suite (R), plus each arm's own suite, run by the harness after every session |
| New behaviour gets a test | per-increment git diff: did the increment that added behaviour add or extend a test touching it |
| Cost | `total_cost_usd` from the CLI's JSON (notional under a subscription, but comparable across arms) |
| Time | `duration_ms` and `num_turns` from the same JSON |
| Validity | the sentinel line, the June validity scan (replies under 200 chars, cost under $0.05), allowlist denials, and an isolation readout per run |

## 7. Phases (each ends with a check; stop and report at any failure)

0. **Isolation check (≈7 tiny runs).** One trivial prompt per arm. Read the
   `stream-json` init event for loaded plugins, skills, MCP servers and hooks. Ask
   for two verbatim lines that exist only in `~/.claude/CLAUDE.md`, too specific to
   guess, to detect global-instruction leakage. **Done when:** every arm loads exactly
   its own row of §3 and none quotes the global lines.
1. **Spikes.**
   - **Ollama:** start the server; check whether Claude Code drives a local model (`ANTHROPIC_BASE_URL`) and Codex does (`codex exec --oss --local-provider ollama`); does tool use work on the three local models? Pull up to two more models only if all three fail (Q25).
   - **Codex:** one R increment, S vs G (AGENTS.md form).

   **Done when:** each route either completes R inc01 with working tool calls, or is
   recorded as not viable. Under 10 sessions.
2. **Pilot (14 sessions):** R inc01–02 × 7 arms on Sonnet. Checks the harness,
   snapshots, acceptance suite, allowlist and cost per session. **Done when:**
   validity is clean in all 14, and the per-session cost is known to set the §8
   pacing.
3. **Main runs:** the §4 blocks, batched to the subscription windows (§8).
4. **Scoring:** a fresh-context scorer per chain, blind to arm where possible, quote-backed.
5. **Verdict:** RESULT per block, one VERDICT, and a witness entry. Keep / slim / cut
   calls go to the Body; nothing ships from the verdict without the Body's say.

## 8. Budget and pacing

The $150 cap (Q18) is read as notional `total_cost_usd`; the real limit is the
subscription's usage windows. June's Opus 4.8 sessions ran $1.46–$4.46 notional and
5–13 minutes. 198 sessions at about 8 minutes is about 26 hours sequential: about a
week of batches at 2–3 in parallel. The Phase 2 pilot gives the real per-session
figure; if the projection exceeds the cap, cut in this order:

1. drop the Haiku block
2. drop chain M
3. creativity probe to n=3

## 9. Risks and what would make the result wrong

- **Repeat ceiling.** The chains may tie again. That itself is information (Soul's
  quality value doesn't show at 9–11 increments), but the decision weight then
  falls on cost, time, plugins and the probes.
- **Leaky isolation.** If Phase 0 can't exclude the global CLAUDE.md under subscription
  auth, every arm carries it equally. That's a confound shared by all arms, not one
  that favours an arm; record it, don't hide it.
- **The Comparators were written in June against v1.1-era tasks.** They are still
  Soul-free and Body-signed; reused for comparability.
- **The purge cell is a stand-in.** It tests a prompt-level review step, not a built
  `/soul-purge`. A good result justifies building it; it doesn't validate a build.
- **n=1 chain per arm** is decision-grade, not publication-grade (CONTEXT.md "Power
  honesty").

## 10. Predictions — drafted, to lock after the Body approves §1–§9

Per mind item 1: lean maximally toward carry, and write a miss-direction guess for each.

- P1 (R, quality, all arms): tie at ceiling. Miss direction: F below G on decision
  survival.
- P2 (cost): S ≤ G per session on Sonnet 5.5, by a smaller margin than June's 13–48%
  (the contract is now ~1k words vs the Comparator's ~2k). Miss direction: S > G
  because hooks and skills add turns.
- P3 (plugins): SP ≈ S on quality; SP > S on cost (more skill text, more turns). GS
  writes into `docs/superpowers/` against no rule; SS shows a path conflict in at
  least one session. Miss direction: SS follows superpowers' paths silently.
- P4 (creativity): S ≈ G on score; both ≥ 1 on Sonnet 5.5. Miss direction: S < G
  (F014's "small").
- P5 (purge): the stale-rule S cell follows the rule silently in ≥ 3/5; the review
  step moves it to "names the conflict" in ≥ 4/5. Miss direction: S names the
  conflict unprompted (rule 7 already does the work, and the purge adds nothing).
- P6 (tiers): S − G cost gap largest on Haiku. Miss direction: none on Haiku.

## 11. Decisions (the Body, 2026-10-21)

- D1. Runs unattended, in batches. Claude budget: **10% of the weekly subscription
  limit** for now; past that, the remaining blocks are deferred to later this week or
  next week, not squeezed in. No programmatic usage readout was found (`claude --help`
  has none): the pilot's usage is read on the Body's `/usage` meter, before and after.
- D2. Full 7-arm matrix on chain R only.
- D3. Codex is API-billed: **$25** for now, more on request if the spike justifies it.
- D4. Accepted: chain quality likely ties again; decision weight on cost, time,
  plugins and the probes.

## 12. Where it lives

`/mnt/d/Projects/soul-benchmark` (public: `soul-system-works/Soul-Benchmark`) holds the
campaign — `experiments/2026-10-2x-*` folders with PREDICTION / RESULT / VERDICT, the
runner scripts, the acceptance suite and the probe fixtures. Arm repos run OUTSIDE it,
on ext4 (`~/soul-bench-arms/`), each its own `git init`, so no session can read the
predictions or the experiment's git log (the June leak). Public repo, so every
committed file is name-scanned against NAME-MAP before push (mind 6c); raw run JSON
stays gitignored, as in June.
