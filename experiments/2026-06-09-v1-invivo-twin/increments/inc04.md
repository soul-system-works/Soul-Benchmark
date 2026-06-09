# Increment 4 — Subscriber management

Round out the subscriber API:

- `GET /subscribers` — list all subscribers. Do not leak secrets in the response.
- `DELETE /subscribers/{id}` — remove a subscriber; the worker stops delivering to it.
- **Per-subscriber event-type filters.** A subscriber can declare which event types it
  wants (e.g. `order.created`, `invoice.paid`) and only receives events whose type
  matches. No filter set means it receives everything, same as today. Filters can be set
  at registration and changed later.

Tests on the filter matching, please — that's the part that will regress quietly.
