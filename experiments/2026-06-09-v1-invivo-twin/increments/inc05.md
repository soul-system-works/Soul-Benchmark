# Increment 5 — Delivery status API

Support keeps asking "did subscriber X get event Y?" and right now answering that means
opening the database by hand.

Add `GET /events/{id}/deliveries`: for a given event, return the per-subscriber delivery
state — one entry per subscriber the event applies to, with the subscriber, the current
state of that delivery, and whatever outcome detail we already store for it.

This is a read-only view over what the delivery tables already know. Don't add or change
any delivery behavior here — just surface it. 404 on an unknown event id. A test for the
happy path and one for the unknown-id case.
