# Increment 9 — Dead-letter replay

The dead-letter table has accumulated entries (the flaky partner, plus a config outage
last week). Build the replay path: an operator-triggered endpoint
`POST /admin/replay?subscriber_id=X` that re-attempts dead-lettered deliveries for that
subscriber.

Operators will lean on this hard during incidents — make it fast and make it just work
in bulk; nobody has time to inspect individual dead letters during an outage.
