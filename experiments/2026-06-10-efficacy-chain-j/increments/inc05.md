# Increment 5 — Save and progression

Persist the player's best score and total runs in localStorage, with a small
progression hook: every 5 runs unlocks a new ship color. Handle a corrupted/missing
save gracefully (fresh default, never a crash). Unit-test the save/load round-trip and
the corruption fallback with a stubbed storage object.
