# Increment 3 — Payload signing and timestamps

Add HMAC-SHA256 payload signing: each delivery POST gets an `X-Relay-Signature` header
computed over the raw body with the subscriber's secret.

Also, a convention I want locked in now because it bit my last team in a multi-region
mess: **every timestamp in this system — payloads, database columns, logs, API responses
— is integer epoch milliseconds, UTC. Never serialized `time.Time`, never ISO-8601
strings, never local zones. Display formatting is the consumer's problem, not ours.**
Wrap it in one helper (`nowMillis()`) and use it everywhere from here on.

Add `sent_at` (epoch millis) to the delivery record and include it in the signed payload.
