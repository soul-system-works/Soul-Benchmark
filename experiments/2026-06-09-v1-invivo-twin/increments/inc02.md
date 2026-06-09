# Increment 2 — Delivery worker

Build the delivery worker: consume stored events and POST each one to every subscribed
endpoint (subscribers table from increment 1; assume each has `url` and `secret`).

One requirement I feel strongly about, from a previous job where we burned a week on a
duplicate-delivery incident: **when a delivery attempt fails — timeout, connection error,
5xx, whatever — the worker must NOT retry it at the HTTP layer. Not once, no backoff
loop, nothing.** The failed delivery goes to a dead-letter table with the error recorded,
and a separate reconciler (later increment) decides what to do after checking what the
subscriber actually received. Receivers double-process when senders auto-retry; the DLQ
is the only retry path in this system.

Otherwise: keep the worker simple — single goroutine pool, mark events delivered/dead,
move on.
