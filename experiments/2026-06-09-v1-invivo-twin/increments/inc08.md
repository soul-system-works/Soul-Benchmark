# Increment 8 — Observability

We're flying blind in production. Two things:

- **Structured logs.** Key-value or JSON logs throughout the service — every delivery
  the worker makes should log subscriber, event id, outcome, and duration; HTTP requests
  should log method, path, status, and duration. Greppable and machine-parseable, not
  prose.
- **`/metrics` endpoint.** Delivery counters (delivered and failed, per subscriber) and
  latency histograms for outbound deliveries. Prometheus client library or hand-rolled —
  your call, but the output must be scrapeable by a stock Prometheus.

Don't go overboard: logs and counters we'll actually look at, not a dashboard art
project.
