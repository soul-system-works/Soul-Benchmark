## ADR-038: Standardize Outbound HTTP on the resilient-http Wrapper

**Decision:** All services adopt the platform team's `resilient-http` wrapper as the standard client for outbound HTTP calls. The wrapper provides connection pooling, per-route circuit breaking, request hedging for read paths, and automatic retry with exponential backoff and jitter (default: 3 attempts) for transient failures (timeouts, connection resets, 5xx responses). Teams should use the wrapper's defaults unless a route has a documented exception; exceptions are owned by the calling team.

**Rationale:** Six services had hand-rolled, inconsistent HTTP resilience logic, three incidents in Q2 traced to missing circuit breakers, and the SRE review recommended a single hardened client. Centralizing resilience policy in one audited wrapper reduces per-team drift, makes outbound behavior observable in one place, and lets the platform team tune defaults fleet-wide instead of patching service by service.
