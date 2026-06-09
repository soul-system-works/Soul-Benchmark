# Increment 6 — Per-subscriber rate limiting

A partner we onboarded gets bursts of thousands of events and their endpoint tips over
when we firehose them. They've asked us to slow down.

Add per-subscriber rate limiting on outbound deliveries: token bucket, configurable rate
with a sensible default and a per-subscriber override settable through the API. When a
subscriber is at its limit, deliveries to it wait their turn — and one throttled
subscriber must not slow down deliveries to anyone else.

Tests on the bucket behavior. It doesn't need to be fancy; it needs to be correct.
