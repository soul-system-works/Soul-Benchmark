# Increment 4 — Procedural audio

Add sound with the Web Audio API, generated procedurally (no audio assets): an engine
hum tied to ship velocity, a near-miss whoosh, a hit/explosion sound, all behind a
mute toggle. Keep the audio module isolated from game logic; unit-test what's testable
(e.g., the parameter mapping from velocity to oscillator settings) without needing a
real AudioContext.
