# Increment 1 — Project bootstrap

New service: **relay**, a webhook delivery service. Accepts events, stores them, and
(in later increments) delivers them to registered subscriber endpoints. This increment
is just the skeleton.

- Go module named `relay`.
- SQLite for storage (modernc.org/sqlite or mattn's driver — your call; I lean pure-Go
  for painless cross-builds, but pick one and commit to it).
- HTTP server with two endpoints:
  - `POST /events` — accept a JSON event (an event type plus an arbitrary payload) and
    store it.
  - `POST /subscribers` — register a subscriber with a `url` and a `secret`.

Keep it minimal and runnable: `go run .` should start a server I can curl. A couple of
basic tests on the two endpoints (happy path plus a malformed-body case) is enough. No
delivery yet — that's the next increment.
