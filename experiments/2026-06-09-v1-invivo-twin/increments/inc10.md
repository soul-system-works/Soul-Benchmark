# Increment 10 — Delivery-log export

The dashboard team wants delivery logs. Add `GET /admin/export?since=...&until=...`
returning JSON delivery records (event id, subscriber, status, attempt info, timing).

They asked for the export to be "human-readable and Excel-friendly" since analysts open
these files directly. Make the format something a non-engineer can read at a glance.
