# CLAUDE.md — relay

relay is a webhook delivery service written in Go: it accepts events over HTTP, stores
them in SQLite, and a worker pool delivers them to registered subscriber endpoints. This
file is the standing engineering guidance for working in this repository. It is not a
checklist to skim once — it should shape every change you make here.

## How to approach a task

- Read the relevant code before changing it. Five minutes spent understanding how a
  handler, store method, or worker path actually behaves saves an hour of unwinding a
  change built on a wrong guess.
- Restate the task to yourself in one sentence before starting. If you cannot, the task
  is not yet understood — ask for clarification rather than picking an interpretation
  silently.
- Prefer the smallest change that fully solves the problem. Fully is the operative word:
  do not stop at the happy path, but also do not solve problems we do not have yet.
- When a requirement is ambiguous, a clarifying question costs a minute; a wrong
  assumption costs a rewrite. Ask.
- Leave code slightly better than you found it, but keep cleanups in separate commits
  from behavior changes so each can be reviewed on its own terms.

## Simplicity

- Default to the simple structure. Complexity must earn its place with a concrete,
  present need — never a hypothetical future one.
- Three similar lines are better than a premature abstraction. Extract a helper after
  the third real use, not before the first.
- One package until it hurts. Split a package when a boundary is forced by an import
  cycle or a genuinely separate concern, not because a directory "feels big".
- Interfaces belong to consumers. Define an interface where it is used, only when a
  second implementation actually exists (a real one or a test fake), and keep it exactly
  as small as the call site demands.
- If a function needs a comment to explain *what* it does, rename or restructure it
  first. Comments are for *why*.
- Deleting code is a contribution. When a change makes something unused, remove it in
  the same review rather than leaving it "in case".

## Go style

- `gofmt` and `go vet` clean at all times. Formatting is not a discussion.
- Follow standard idioms: early returns over nested conditionals, useful zero values,
  accept broad inputs and return concrete types.
- Keep functions short enough that a reader holds the whole thing in their head —
  roughly a screen. A long straight-line function is fine; deep nesting is the real
  enemy.
- No global mutable state. Wire dependencies — the store, the HTTP client, configuration
  — through struct fields, constructed in `main` and passed down explicitly.
- `context.Context` flows from the request or the worker loop downward as the first
  parameter. Never store a context in a struct.
- Exported surface area is a promise. Export the minimum; widening later is easy,
  narrowing later breaks callers.

## Naming

- Names carry the design. A precise name makes half the documentation unnecessary; a
  vague one (`data`, `info`, `Manager`, `Util`) hides a fuzzy idea that should have been
  sharpened before coding.
- Name things for what they mean in the domain — `subscriber`, `delivery`, `event type`
  — not for their implementation (`row47`, `jsonBlob`).
- Short names for short scopes (`i`, `tx`, `w`), full words for anything that crosses a
  function boundary.
- Avoid stutter: `relay.Server`, not `relay.RelayServer`.
- A boolean's name should read as the true case at the call site: `if sub.Active` rather
  than `if sub.Status == 1`.
- When you rename something, rename it everywhere — code, tests, comments. A name that
  means two things is worse than a bad name that means one.

## Error handling

- Handle every error. A discarded error (`_ = f()`) is acceptable only with a comment
  saying why discarding is correct.
- Wrap with context as errors travel upward: `fmt.Errorf("loading subscriber %d: %w",
  id, err)`. The goal is that a single message at the top tells you what failed and
  where, without a debugger.
- Errors are values: branch on them with `errors.Is`/`errors.As` and defined sentinel
  errors, never by matching message strings.
- Fail loudly at startup. If configuration is invalid or the database cannot open, exit
  with a clear message immediately — a service that limps up half-working is far harder
  to diagnose than one that refuses to start.
- In HTTP handlers, map errors to status codes deliberately: client mistakes are 4xx
  with a message that helps the caller fix their request; internal failures are 5xx with
  a generic body. Log the detail server-side; never leak stack traces, SQL, or file
  paths to a client.
- Do not use panics for control flow. A panic is for programmer error (impossible
  states), and the HTTP layer should recover, log, and return 500 rather than killing
  the process.

## Testing discipline

- Every behavior change ships with a test that fails without the change. If you cannot
  write that test, you do not yet understand the change.
- Test through the public surface — handlers via `httptest`, the store via its exported
  methods. Tests that reach into private internals calcify the current implementation
  and punish refactoring.
- Use real SQLite in tests (in-memory or a temp file). It is fast and honest; a mocked
  store mostly verifies that the mock was called, which proves little.
- Table-driven tests for input/output behavior; give each case a name that reads as a
  sentence in the failure output.
- Cover the failure paths, not just success: malformed bodies, missing IDs, a subscriber
  endpoint returning 500, a full queue. The unhappy paths are where production incidents
  live.
- Tests must be fast and deterministic. No `time.Sleep` to "wait for" concurrent work —
  synchronize with channels or wait groups. A flaky test is worse than no test because
  it trains people to ignore failures.
- Run `go test -race ./...` before considering any change done, and run the actual code
  path at least once yourself — start the server, send a request, watch it behave. Tests
  passing and the program working are related but not identical facts.

## HTTP API conventions

- JSON in, JSON out, explicit status codes. 201 for creation, 404 for an unknown
  resource, 400 with a useful message for a malformed request.
- Validate input at the edge. Decode into a typed struct, reject unknown or missing
  required fields with a message naming the field, and pass only validated values
  inward. Inner layers should never re-check what the handler guarantees.
- Bound every request body with `http.MaxBytesReader`. An endpoint that accepts
  arbitrary payloads must not accept arbitrarily large ones.
- Set timeouts on the server (`ReadTimeout`, `WriteTimeout`) and on every outbound
  client call. An HTTP call without a deadline is an outage waiting for a slow peer.
- Keep handlers thin: parse, validate, call into the store or service layer, encode the
  response. Business rules live below the handler so they can be tested without HTTP.

## Database and SQL

- Parameterized queries, always and without exception. String-built SQL is both an
  injection hole and a cache-defeating habit.
- The store package owns all SQL. Handlers and the worker speak in terms of typed
  methods (`store.SubscribersForEvent`), never raw queries.
- Schema changes are numbered migration files applied in order at startup. Never edit a
  migration that has shipped; add a new one.
- Use transactions wherever multiple statements must succeed or fail together. SQLite is
  forgiving locally and unforgiving under concurrency — assume the worst.
- Remember SQLite's single-writer model: keep write transactions short, and do not hold
  one open across a network call.

## Concurrency

- Every goroutine has an owner who knows how it stops. A goroutine started without a
  shutdown path is a leak with a delay on it.
- Bound all pools and queues. An unbounded channel turns back-pressure into an
  out-of-memory crash at the worst possible moment.
- Prefer channels for handing work off, mutexes for guarding state; do not mix both
  around the same data.
- Share by communicating where it simplifies; when a plain mutex around a map is
  clearer, use the mutex. Cleverness in concurrent code is a liability.
- The race detector is part of the test suite, not an occasional audit. New concurrent
  code gets a test that actually exercises the concurrency.

## Security hygiene

- Secrets come from the environment, never from source code, and never appear in logs,
  error messages, or API responses — including the subscriber secrets we store. List
  endpoints must not echo secrets back.
- Compare secrets and signatures with `crypto/subtle.ConstantTimeCompare`, not `==`.
- Treat every inbound payload as hostile: size-bounded, schema-checked, and stored — not
  interpreted, evaluated, or templated into anything.
- Outbound requests go to URLs supplied by users. Validate them on registration (scheme,
  shape) and think about what an attacker gains by pointing us at an internal address.
- Run with least privilege: the service needs its database file and its port, nothing
  else. Do not add capabilities speculatively.
- When you touch authentication or signing code, slow down and get a second pair of eyes
  on it. This is the one area where a subtle bug is a breach, not a bug report.

## Performance judgment

- Measure before optimizing. A profile or a benchmark earns an optimization; a hunch
  does not. Most "obviously slow" code is not the bottleneck.
- Keep allocations out of the worker's hot loop where it is free to do so (reuse
  buffers, avoid gratuitous marshaling), but do not contort code for unmeasured gains.
- Latency in this system is dominated by subscriber endpoints and disk, not CPU. Design
  for that: do not block the world on one slow peer.
- Benchmarks (`go test -bench`) belong next to genuinely hot paths so regressions show
  up in review rather than in production.
- Caching is a last resort. Every cache adds an invalidation problem; earn it with a
  measurement first.

## Documentation lives in the code

- Every exported identifier gets a doc comment that says something the signature does
  not. Each package gets a package comment stating its purpose in a sentence or two.
- Explain *why* in comments next to the code: a surprising constant, a workaround for an
  upstream bug, a deliberately rejected alternative. The reader can see what the code
  does; they cannot see what it avoids.
- Mark known debt where it sits — `TODO(name): context` — so it is discovered by the
  next person editing that code, not lost in a wiki.
- Keep the README's build-and-run instructions accurate. A stale README is worse than
  none because it is trusted.

## Dependencies

- Standard library first. Go's stdlib covers HTTP, JSON, crypto, and SQL plumbing well;
  reach outside it only when the gap is real.
- Every new dependency must pay for itself: it should replace a meaningful amount of
  code we would otherwise have to write *and maintain*, come from a maintained source,
  and bring acceptable transitive weight. Check what it pulls in before adopting it.
- Prefer small, focused libraries over frameworks. A framework's conventions outlive
  your ability to disagree with them.
- Pin versions in `go.mod`, review `go.sum` changes in PRs, and upgrade deliberately —
  read the changelog, run the tests, bump one thing at a time.

## Commits and small changes

- One logical change per commit; one concern per PR. A reviewer should be able to hold
  the whole diff in their head — roughly 400 lines is the comfortable ceiling.
- Subject line in the imperative ("add subscriber filters"), body explaining why the
  change exists and anything a reviewer would otherwise have to ask.
- Never mix a refactor with a behavior change in one diff. The refactor hides the
  behavior change from review, which is exactly where bugs slip through.
- If a task is growing beyond one reviewable change, stop and slice it: land the
  scaffolding first, then the behavior, then the polish.

## When unsure

- Say so. "I am not certain; here is what I checked and what I would do to confirm" is a
  professional answer; confident guessing is not.
- Prefer the reversible step. When two designs are close, pick the one that is cheaper
  to undo.
- Surface trade-offs to the human instead of silently choosing: two honest options with
  costs beat one polished recommendation built on an assumption they never saw.
