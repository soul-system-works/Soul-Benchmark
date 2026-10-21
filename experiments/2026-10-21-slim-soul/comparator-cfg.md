# CLAUDE.md — stationcfg

Working rules for any coding session on this repository. Read this whole file before changing anything. If something here is wrong or out of date, fix this file in the same change, and tell the owner you did.

## What this project is

`stationcfg` loads weather-station configuration files and validates them for field teams. The public entry point is `stationcfg.load.load(path)`. It returns a `dict` or raises `ValueError`.

People use this in the field. A config that loads "successfully" but is wrong can put a station on the wrong coordinates or the wrong sampling interval, and nobody may notice for weeks. So the library's main job is **loud, specific failure on bad input**. When you have to choose between convenience and strictness, choose strictness and ask the owner.

The project is maintained by AI coding agents across many sessions, with one human owner who makes the decisions. You will not remember earlier sessions. This file and the repository are the only memory. Write things down as if the next engineer has never seen the code, because they haven't.

## Current layout (as of the last update to this file)

```
pyproject.toml          # name, version (0.6.0), requires-python >=3.11, dependencies
stationcfg/__init__.py  # empty; exports nothing
stationcfg/load.py      # load(): JSON only, checks REQUIRED keys are present
test_load.py            # pytest: happy path + one missing-key case
```

There is no README, changelog, build-system table, lockfile, CI config, or lint config. The directory is **not a git repository**. If any of this has changed by the time you read it, update this section.

## Known gaps and open questions

These are observations, not assignments. Don't fix them unprompted as a side effect of other work. Raise them with the owner, or fix them when the task is about them.

1. **`requests>=2.31` is declared but never imported.** It looks like a leftover or a placeholder for a planned feature (remote config fetch?). Ask the owner before you remove it or start using it.
2. **Validation checks presence only.** Nothing checks `lat` ∈ [-90, 90], `lon` ∈ [-180, 180], that `sample_seconds` is a positive integer, that `station_id` is a non-empty string, or that values aren't `bool` (in Python `True` is an `int`). For the field use case this is the biggest real risk.
3. **A non-object JSON top level crashes badly.** A file containing `[]` or `42` raises `AttributeError` from `data.keys()`, not a clear `ValueError`.
4. **Malformed JSON raises `json.JSONDecodeError`.** That is a subclass of `ValueError`, so it technically fits the contract. The message doesn't name the file, though.
5. **The suffix check is case-sensitive.** `STATION.JSON` is rejected.
6. **`read_text()` uses the platform default encoding.** It should almost certainly be `encoding="utf-8"`.
7. **Unknown keys pass silently.** A typo like `sample_second` alongside a correct key is ignored. Whether extra keys should be rejected or warned about is an **owner decision**.
8. **Python ≥3.11 makes `tomllib` available in the stdlib.** TOML support would be easy to add. Adding a format is a product decision, not a refactor.
9. **No `[build-system]` table** in `pyproject.toml`. Editable installs rely on the installer's defaults.
10. **No version control.** Don't run `git init` on your own. Suggest it to the owner, because without it there is no undo and no history.

When you resolve one of these, delete it from this list (or update it) in the same change.

## How to work here

**Understand before editing.** The codebase is small enough to read completely every session. Do that. Don't guess at behavior you could check in under a minute.

**Keep changes small and single-purpose.** One behavioral change per piece of work. Don't mix a refactor, a new validation rule, and a dependency change. If you notice something unrelated, record it under "Known gaps" and don't fix it in passing.

**Preserve the public contract unless the owner approves a break.** The contract today:
- `load(path)` accepts a `str` or `os.PathLike`.
- It returns a plain `dict` holding the parsed data, unmodified (no normalization, no defaults injected).
- It raises `ValueError`, or a subclass, for anything wrong with the file's format or contents. `OSError` from a missing or unreadable file propagates unchanged.

Field teams may catch `ValueError` specifically. Any new failure mode about bad config content must raise `ValueError` or a subclass. Never let an `AttributeError`, `TypeError`, or `KeyError` escape for bad input. If you think the contract should change (e.g. returning a dataclass, or a custom `ConfigError(ValueError)`), propose it first.

**Error messages are user interface.** A field technician reads them, often on a laptop in bad conditions. Each message should say what is wrong, which key, and ideally which file and what was expected: `"lat must be between -90 and 90, got 123.4 (in /path/station.json)"`. Keep the existing sorted-list style for multiple missing keys. Report all problems of one kind at once rather than one per run, where that's cheap.

**Keep it boring.** Standard library first. Plain functions, no classes unless they earn their place, no metaprogramming, no clever config DSLs. Code should read like the code already here: short, flat, obvious. Add type hints when you touch a signature. Don't sweep the whole codebase adding them.

**Don't widen what counts as valid input without a decision.** Accepting new formats, coercing types (`"60"` → `60`), filling defaults, and ignoring unknown keys all make bad configs load silently. Each one needs owner approval and a recorded decision.

## Testing and verification

- Run the suite with `python -m pytest -q` from the repository root. Before your first change, run it once so you know the baseline. If it already fails, say so; don't silently fix unrelated failures.
- **Every behavior change gets a test in the same change.** Every bug fix gets a regression test that fails before the fix. Check that it fails first, by running it against the unfixed code, whenever that's practical.
- Test through the public function `load()` with real files written to `tmp_path`, as the existing tests do. Don't mock `Path` or `json`.
- For error cases, assert on the exception type **and** on the key part of the message, using `pytest.raises(ValueError, match=...)`. A bare `pytest.raises(ValueError)` can pass for the wrong reason, e.g. a `JSONDecodeError` from a typo in the test fixture. Tighten the existing `test_missing_key` when you next touch it.
- Cover boundaries explicitly for numeric rules: exactly -90, 90, -180, 180, zero, negative, `bool`, `float` where `int` is required, `NaN`/`Infinity` (Python's `json` accepts them by default).
- A small helper or fixture that writes a valid baseline config and lets a test override one field is welcome once there are more than a few tests. Don't build a framework.
- "Done" means: tests run and pass, you've read your own diff, and the docs and this file reflect the change. If you couldn't run the tests (no permission, missing interpreter, missing pytest), **say that plainly** in your report. Never write "tests pass" without having seen them pass in this session.

## Dependencies

- The runtime dependency budget is effectively **zero**. This library parses a small file and checks some fields; the stdlib is enough. The one declared dependency, `requests`, isn't used (see Known gaps).
- Don't add a runtime dependency without the owner's explicit approval. Ask in a short note: what it's for, why the stdlib isn't enough, its maintenance status, and how much it pulls in transitively.
- Test-only tools (pytest, and possibly a linter later) belong in an optional dependency group such as `[project.optional-dependencies] test = ["pytest"]`, not in `dependencies`. Adding that group is a reasonable small change to propose.
- Don't change `requires-python` casually. Field machines may run older interpreters, so raising the floor is an owner decision.
- Don't install packages globally or change the user's environment beyond what the task needs. Prefer a virtualenv and say which one you used.

## Versioning and release hygiene

- The version is in `pyproject.toml` (currently `0.6.0`). Don't bump it unless the owner asks or you're preparing a release they've requested.
- When a release does happen, pre-1.0 semver applies loosely: a new validation rule that rejects configs that used to load is a **breaking change** for users, even though it's a "fix". Call it out as one.
- If a CHANGELOG is created, keep it human-readable with entries grouped under the unreleased version. Any change that alters which configs load gets an entry.

## Documentation and decision recording

- **Docstrings:** `load()` and any new public function document accepted inputs, return value, and every exception raised along with its cause. Keep the module docstring accurate.
- **Config format:** once validation goes beyond presence checks, the authoritative list of keys, types, units and ranges must exist in exactly one place. Prefer the code: a single schema-like table in `load.py`, plus a README that describes it for field teams. Don't let the README and the code disagree. Update both in the same change.
- **Decisions:** when the owner makes a choice that future sessions must respect (reject vs. warn on unknown keys, add TOML, drop `requests`, introduce `ConfigError`), record it. If `docs/decisions.md` doesn't exist yet, create it when the first decision is made. Each entry is short: date, decision, reason, who decided, and what was rejected. Don't record decisions the owner hasn't actually made, and don't put your own preferences there as if they were settled.
- Units belong in names or docs, never assumed: `sample_seconds` is seconds; `lat`/`lon` are presumably WGS84 decimal degrees. Confirm that with the owner before encoding it as a rule.

## Continuity across sessions

You start every session without memory. Do this:

1. **At the start:** read this file, then every source and test file, then `docs/decisions.md` if it exists. Run the tests for a baseline.
2. **During work:** if a task will take more than one session or is left half-done, leave a clear note. Put it in a "Work in progress" section at the end of this file: what was done, what's left, what's uncertain, and how to verify it. Never leave the code in a state where tests fail without that note.
3. **At the end:** update the "Current layout" and "Known gaps" sections if they changed. Remove a work-in-progress note once the work is finished. Keep this file accurate and under about 2,000 words. Prune stale content rather than piling on more.

Because there is no git, there's no history to fall back on. Before you restructure or delete a file, make sure the owner wants it, and describe exactly what you removed in your report.

## Collaborating with the owner

- **The owner decides product questions:** what counts as a valid config, which formats are supported, what's a breaking change, which dependencies are allowed, and when to release. You decide implementation details inside those boundaries.
- **Ask when the answer changes what you build.** Ask once, concisely, with a recommendation: "Unknown keys: I recommend rejecting them, because typos currently pass silently. Reject, warn, or keep ignoring?" Don't ask about things you can find out by reading the code.
- **Do exactly what was asked.** If you think the request is mistaken or risky (e.g. "accept strings for lat/lon"), say so and explain why, then follow the owner's call. If a task is ambiguous, go with the stricter interpretation and say which one you chose.
- **Report honestly and specifically.** Say what changed (files and behavior), what you verified and how, what you couldn't verify, and anything you noticed but deliberately left alone. Name failures and skipped steps outright, and don't paper over them.
- **No surprises.** Don't take outward-facing or hard-to-reverse actions without explicit approval. That includes publishing to PyPI, initializing or rewriting version control, deleting files, and mass reformatting.
