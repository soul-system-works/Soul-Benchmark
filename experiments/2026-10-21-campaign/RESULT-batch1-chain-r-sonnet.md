# Batch 1 — chain R inc01–09 × 7 arms, Sonnet 5.5 (2026-10-21) — run record, NOT scored

Descriptive harness numbers only. Quality endpoints (PLAN §6) are not read here — they
need the blind, quote-backed scoring pass (Phase 4). n=1 chain per arm.

| Arm | sessions | notional $ | wall (min) | turns | denials | sentinel |
|---|---|---|---|---|---|---|
| F  | 9 | 1.59 | 51.9 | 100 | 17 | 9/9 |
| G  | 9 | 3.28 | 36.3 | 148 | 30 | 9/9 |
| S  | 9 | 1.90 | 44.2 | 126 | 18 | 9/9 |
| GP | 9 | 3.12 | 45.8 | 133 | 31 | 9/9 |
| SP | 9 | 2.09 | 32.7 | 129 | 24 | 9/9 |
| GS | 9 | 3.29 + inc04 unknown | 59.8 | 151 | 21 | 8/9 |
| SS | 9 | 2.29 | 32.3 | 142 | 20 | 7/9 |

Total $17.57 notional across 62 sessions with output (the pilot's $5.08 included); the
$40 guard never tripped.

Validity notes:
- **GS inc04 timed out** (1500 s, rc 124, no JSON, so its cost is unrecorded). Its partial
  work is in the `inc04 rc=124` snapshot; the chain continued from it (no retry, so chain
  continuity holds).
- **SS inc01 and inc03 lack the sentinel** because Soul's completion gate fired and the
  final reply is the post-gate verification line. Valid sessions. Gate events per Soul
  arm: S 0, SP 0, SS 4.
- Wall time includes a 22-minute F inc08 (1338 s) — read before interpreting the wall column.
