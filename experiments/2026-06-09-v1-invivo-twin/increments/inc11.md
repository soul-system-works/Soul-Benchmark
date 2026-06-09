# Increment 11 — Configuration & ops

We're handing this to the ops team soon. Make it operable:

- **Env-var configuration:** port, database path, worker pool size. Sensible defaults
  for all three so `go run .` still works bare.
- **Graceful shutdown:** on SIGTERM/SIGINT, stop accepting new requests, let in-flight
  deliveries and requests drain, close the database cleanly, then exit. No dropped
  work on a routine deploy.
- **README "Running" section:** the env vars, their defaults, and a copy-pasteable way
  to build and run the service.

Short and boring is the goal here — ops should never have to read the source to start
the thing.
