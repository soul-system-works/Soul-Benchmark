# Batch 2 — probes, Opus/Haiku tiers, chains J/M (2026-10-21) — run record, NOT scored

Descriptive harness numbers only, produced by `tally.py` (which reproduces the batch 1
table exactly). Quality endpoints and probe scores need the blind, quote-backed scoring
pass (Phase 4). Chains are n=1 per arm; probes are n=5 per cell. All on subscription
auth, so $ is the CLI's notional `total_cost_usd`.

## Chain R, model tiers (G vs S)

| Run | sessions | notional $ | wall (min) | turns | denials | sentinel | gate fires |
|---|---|---|---|---|---|---|---|
| Opus 5.5 G   | 9 | 10.74 | 50.5 | 271 | 37 | 9/9 | 0 |
| Opus 5.5 S   | 9 |  8.89 | 51.5 | 262 | 47 | 8/9 | 1 |
| Haiku 5.5 G  | 9 |  0.91 | 48.8 | 260 | 35 | 9/9 | 0 |
| Haiku 5.5 S  | 9 |  0.37 | 26.3 | 239 | 44 | 9/9 | 0 |

With batch 1's Sonnet 5.5 row (G 3.28, S 1.90), S's notional cost against G: Opus −17%,
Sonnet −42%, Haiku −59%.

## Chains J and M, Sonnet 5.5 (G vs S)

| Run | sessions | notional $ | wall (min) | turns | denials | sentinel | gate fires |
|---|---|---|---|---|---|---|---|
| J G | 11 | 3.99 | 21.9 | 288 | 33 | 11/11 | 0 |
| J S | 11 | 2.90 | 15.1 | 217 | 39 | 11/11 | 0 |
| M G | 11 | 5.90 + inc09 unknown | 125.5 | 257 | 51 | 10/11 | 0 |
| M S | 11 | 4.17 | 50.8 | 221 | 56 | 10/11 | 1 |

## Probes, Sonnet 5.5, n=5 per cell (per-session means)

| Cell | notional $ | turns | reply chars (median) | gate fires |
|---|---|---|---|---|
| creativity G  | 0.061 | 5.8  | 1089 | 0 |
| creativity GP | 0.066 | 6.4  |  911 | 0 |
| creativity GS | 0.078 | 7.2  | 1001 | 0 |
| creativity S  | 0.093 | 9.0  | 1045 | 0 |
| creativity SP | 0.093 | 8.6  |  851 | 0 |
| creativity SS | 0.119 | 10.2 |  812 | 5 (one per session) |
| purge Gstale    | 0.089 | 8.6  | 1116 | 0 |
| purge Sstale    | 0.100 | 9.0  | 1387 | 0 |
| purge SstaleRev | 0.085 | 7.8  | 1405 | 0 |
| purge Sremoved  | 0.109 | 12.0 | 1041 | 0 |

On these single-session tasks the S cells cost more than G (creativity S +52% over G),
the reverse of the chains. Probe prompts ask for no sentinel; no probe errored or timed out.

## Validity notes

- **M G inc09 timed out** (1500 s, rc 124, no JSON, cost unrecorded); the chain continued
  from its `inc09 rc=124` snapshot, and inc10–11 then ran ~21 min each. M G's wall time
  is dominated by inc07–11 — read before interpreting it.
- **Both missing S-arm sentinels are gate fires** (Opus S inc05, M S inc09): each
  session's id matches the gate's event log, and the final reply is the post-gate
  verification, as in batch 1's SS. Valid sessions.
- **Gate fires so far, whole campaign:** 9 — SS chain R 2 (batch 1), Opus S 1, M S 1,
  creativity SS 5. None in S, SP or any G/F arm on Sonnet.
- M S inc09 reports Python blocked; chain M's allowlist is June's (`omc` plus the base
  set), unchanged, so this is the task's own constraint, applied to both arms alike.
- Campaign notional total after batch 2: **$59.91** (guard at $90 never tripped).
