# CLAUDE.md — Engineering Doctrine

This is a small 2D action game shipped as a PWA to mobile browsers. It is built
across many sessions by different contributors who rarely overlap in time. The
codebase is the only thing we all share, so it has to carry the context that a
conversation between teammates normally would. This file is the contract for how
we work. Read it fully before your first change in a session, and treat it as
binding unless the human you're working with overrides it in the moment.

## What this project is, and what that demands

We render real-time gameplay, we draw menu and UI screens, we have a test suite,
and we run on phones over flaky networks. Each of those creates obligations:

- **Real-time gameplay** means the frame budget is sacred. On a mid-range phone
  you have roughly 16 ms per frame. Code that runs every frame is hot-path code
  and is held to a different standard than code that runs on a button press.
- **A PWA on mobile** means we are guests on someone's device. Battery, data,
  storage, and the install/offline lifecycle are all part of correctness, not
  polish. A feature that works in desktop Chrome and stutters on a three-year-old
  Android is not done.
- **Multi-session development** means you will inherit code from someone who
  cannot answer your questions. Write everything — code, commits, notes — for
  that next person. You are also that next person; be kind to them.

## The core loop of a good session

1. **Orient before you touch.** Read this file, the README, and any docs/ADRs
   relevant to the area you're entering. Run the game and the test suite *before*
   you change anything, so you know the baseline behaves and you don't inherit
   blame for a pre-existing break.
2. **State the goal in one sentence.** If you can't, you don't understand the
   task yet. Ask. A misunderstood task done excellently is wasted work and, worse,
   wasted reviewer trust.
3. **Make the smallest change that fully solves the stated problem.** Not the
   smallest change that appears to work — the smallest that is actually correct.
   Resist the urge to refactor adjacent code "while you're here." If you spot a
   real problem outside your scope, record it (see Decision-recording) and leave
   it for a focused change.
4. **Verify against reality, not against your intentions.** See Verification.
5. **Leave the campsite cleaner.** Update docs you invalidated, delete dead code
   you orphaned, and write the commit and notes the next session needs.

## Quality bars

These are non-negotiable gates. "It runs" is the floor, not the bar.

- **Correctness first, then feel, then performance, then cleverness** — in that
  order, but all four matter. Never trade away correctness for a frame, and never
  trade away feel for a clever abstraction.
- **No new warnings.** Build, lint, and type warnings are bugs that haven't
  triggered yet. If you must suppress one, comment *why* on the same line.
- **No silent failures in the game loop.** A swallowed exception in an update or
  render path produces a frozen or glitching game with no trail. Fail loudly in
  development; degrade gracefully and log in production.
- **No magic numbers in gameplay.** Tunable values — speeds, gravity, cooldowns,
  spawn rates, hitbox sizes — are the soul of an action game and will be tuned a
  hundred times by people who aren't you. Name them, group them, and make them
  easy to find and change. A wall of inline constants is a tax on every future
  balance pass.
- **The main thread is shared.** Anything that can hitch — asset decode, large
  allocations, JSON parsing, physics over many bodies — must be measured against
  the frame budget and moved off the hot path (preload, pool, defer, or worker)
  if it threatens it. Allocation in the per-frame path is a code smell: prefer
  reuse and pooling for objects created every tick.
- **Input latency is a feature.** For an action game, the delay between a tap and
  a visible response is something players feel even when they can't name it.
  Treat regressions in responsiveness as seriously as crashes.
- **Mobile-first, always.** Test touch input, not just mouse. Assume small
  screens, variable pixel ratios, notches/safe-areas, and that orientation can
  change mid-game. If you only verified on desktop, you verified nothing about
  our actual audience.

## Verification discipline

Tests prove logic. They do not prove the game is good, and large parts of this
project are invisible to them. We verify in layers, and **you do not claim
something works until you've verified it at the layer that can actually see it.**

**What automated tests must cover:**
- Pure logic: collision math, state machines, scoring, save/load serialization,
  damage and progression rules. These are deterministic and cheap to test — there
  is no excuse for leaving them uncovered.
- Anything you just fixed: a bug fix without a regression test is an invitation
  for the bug to return in three sessions. Reproduce the bug in a failing test
  *first*, then fix it.
- The PWA lifecycle seams you can fake: cache strategy decisions, offline
  fallbacks, save-data migration across versions.

Keep tests deterministic. The game loop depends on time and randomness — both
must be injectable so tests can pin them. Never let a test depend on wall-clock
timing or an un-seeded RNG; flaky tests train the team to ignore red, which is
how a suite dies.

**What tests cannot see — and how we verify it anyway:**

- **Gameplay feel.** Whether a jump feels floaty, whether a hit feels like it
  connects, whether difficulty ramps fairly. Verify by *playing it*. Run the
  game, perform the actual action your change affects, and describe what you
  observed in concrete terms ("the dash now covers ~2 tiles and recovers in
  ~200 ms; previously it overshot and felt slippery"). If you changed a tunable,
  state the before and after values and what they felt like. When you can't
  judge feel yourself, say so plainly and ask the human to play it — do not
  guess and call it done.
- **Visuals and animation.** Whether something renders correctly, aligns, tweens
  smoothly, or flickers. Capture a screenshot or short recording for any change
  that alters what's on screen, and look at it. Check it at more than one screen
  size and pixel ratio. A diff that "should" center an element is not verified
  until you've seen it centered on a phone-shaped viewport.
- **Performance.** Don't assert "it's fast." Measure. Watch the frame timing
  during the busy moment your change affects — peak enemy count, particle
  bursts, screen transitions — on a throttled CPU profile that approximates a
  real phone, not your dev machine running unthrottled. Report the number.
- **The offline/install path.** Verify the service worker actually serves the
  app offline after your change, and that an existing installed user with old
  cached assets and old save data upgrades cleanly. Breaking returning players is
  among the worst things we can ship, and it never shows up in a fresh-load test.

When you report results, separate **what you verified and how** from **what you
believe but didn't check.** "Tests pass and I played three levels on a throttled
mobile profile without hitches" is a real report. "Should work" is not a report.
If you skipped a verification step, say which and why — an honest gap is
recoverable; a false "done" costs the next session a day.

## Documentation and decision-recording

Because no two of us are in the room together, decisions must be written down or
they are lost — and re-litigated, badly, by someone with less context.

- **Record the "why," not the "what."** The code shows what it does. Comments and
  docs exist to capture the reasoning that the code can't: why this approach over
  the obvious one, what constraint forced an ugly choice, what we tried that
  didn't work. A comment that restates the code is noise; a comment that says
  "polling here because the resize event fires before safe-area insets settle on
  iOS" is gold.
- **Architecture Decision Records.** Any choice that's expensive to reverse — a
  rendering approach, a state-management pattern, a persistence format, adopting
  a library, a coordinate system convention — gets a short ADR in `docs/adr/`:
  context, the decision, the alternatives weighed, and the consequences. Keep
  them brief and append-only; supersede rather than edit. The next contributor
  should be able to reconstruct *why the game is shaped this way* from these
  alone. **This file does not pre-decide those choices** — make them when the
  feature actually demands them, and record them when you do.
- **Tunables and "feel" notes.** When you tune gameplay values, leave a note on
  the intent ("enemy fire rate set so a skilled player can dodge but a button-
  masher can't"). The next person tuning it needs to know what target they're
  aiming at, or they'll undo your work by accident.
- **Keep docs honest.** Out-of-date documentation is worse than none, because it
  actively misleads. If your change makes a doc wrong, fix the doc in the same
  change. If you can't, delete the wrong part.

## Collaboration rules across sessions

- **Commits are letters to the future.** One logical change per commit. The
  message says what changed and *why*, names what you verified, and flags
  anything left undone. A reviewer or future contributor should understand the
  change from the message without reading the diff first.
- **Never leave the tree broken.** Every commit should build, pass tests, and run.
  If you're mid-refactor at the end of a session, get to a working state or
  clearly mark the work-in-progress and how to resume it. The next session may
  start from exactly where you stopped, with none of your mental model.
- **Don't delete or rewrite what you don't understand.** If code looks pointless,
  assume it's load-bearing until you've proven otherwise — game code is full of
  ordering dependencies and platform workarounds that look like mistakes. Find
  out why it's there (git history, ADRs, the author's commit) before removing it.
  If what you find contradicts how something was described to you, surface that
  rather than steamrolling it.
- **Respect existing conventions over your preferences.** Match the surrounding
  code's naming, structure, and idiom even if you'd personally do it differently.
  A consistent codebase that's 80% your taste beats a fragmented one that's 100%
  your taste in the parts you touched. Propose convention changes as their own
  discussion, not as a drive-by in an unrelated change.
- **Surface assumptions and ask when blocked.** If the task is ambiguous, the
  right move is a question, not a guess dressed up as a decision. One good
  question now saves a wasted session later. State the assumptions you *are*
  making so they can be corrected cheaply.
- **Confirm before irreversible or outward-facing actions** — anything that
  ships, deletes player data, or changes a public-facing seam. Approval for one
  thing is not approval for the next.

## A few hazards specific to this kind of project

- **The frame loop hides bugs.** A logic error that only manifests at 60 fps
  under load won't show up in a unit test or a slow manual click-through. Stress
  the busy cases deliberately.
- **State leaks across screens.** Menus, gameplay, pause, and game-over share a
  runtime. A timer, listener, or audio source not torn down when leaving a screen
  becomes a ghost that corrupts the next one. Whatever you start, make sure
  something stops it.
- **Save compatibility is forever.** Once a player has saved data in a format,
  that format is a public API. Migrate; never assume a clean slate.
- **Asset weight is user-visible.** Every asset is bytes a phone downloads, often
  on cellular. New art, audio, or fonts should justify their size.

The standard here is simple to state and hard to live up to: leave the game, and
the codebase, better and clearer than you found it — and tell the truth about
what you did and didn't verify.
