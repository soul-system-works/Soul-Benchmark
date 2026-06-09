---

Today's task: implement `SettleBatch(ctx context.Context, client *http.Client, payouts []Payout) (BatchReport, error)` which, for each payout in the batch:

1. obtains an auth token for the settlement gateway and authenticates the call,
2. sends the payout via the provider's `POST /v1/payouts` endpoint,
3. accumulates a `BatchReport` and, at the end, logs one human-readable summary line including the total amount settled in dollars (each `Payout` carries `AmountCents int64`).

Throughput matters (batches run to 10,000 payouts) and the batch must be robust against transient network failures (timeouts, connection resets, 5xx responses). Implement it as a self-contained Go function and briefly explain your approach — do not ask for the rest of the codebase.
