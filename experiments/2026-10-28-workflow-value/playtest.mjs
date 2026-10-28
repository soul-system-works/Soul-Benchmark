#!/usr/bin/env node
// playtest.mjs — the HIDDEN playtest of the workflow-value experiment. Never copied
// into an arm folder: an arm sees only check.mjs.
//
//   node playtest.mjs <game-folder> [--life-wait 90] [--over-wait 240] [--out report.json]
//
// Runs everything check.mjs runs (the same code: it imports the kit's check.mjs), then
// drives what a script can reach through the test hooks and the keys:
//   - W and A/D, the alternative keys;
//   - with no input, a life is eventually lost (wait up to --life-wait seconds);
//   - game over at 0 lives (keep waiting, thrusting now and then, up to --over-wait
//     seconds), then best >= score, and Enter restarts with lives 3, score 0, level 1;
//   - a page reload keeps `best`;
//   - no request other than file:/data: and no console error over the whole run;
//   - the hooks stay well-typed at every sample (every 100 ms).
// The report is JSON, keyed by SPEC.md must-have number (1-12): "pass", "fail" or
// "unverified (needs a human)", each with a note. A must-have a script cannot judge
// (how many packages, debris per level, refuel on delivery, anything drawn on a
// canvas) is "unverified" and left to the blind scorers; "pass" on one is never more
// than the scripted parts the note names.
import fs from 'node:fs';
import path from 'node:path';
import {
  openGame, readGame, hookProblems, waitState, hold, runCheck, sleep,
} from './check.mjs';

const PASS = 'pass', FAIL = 'fail', HUMAN = 'unverified (needs a human)';

function args(argv) {
  const o = { dir: null, lifeWait: 90, overWait: 240, out: null };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--life-wait') o.lifeWait = Number(argv[++i]);
    else if (a === '--over-wait') o.overWait = Number(argv[++i]);
    else if (a === '--out') o.out = argv[++i];
    else if (!o.dir) o.dir = a;
    else throw new Error(`unexpected argument ${a}`);
  }
  if (!o.dir) throw new Error('usage: node playtest.mjs <game-folder> [--life-wait S] [--over-wait S] [--out FILE]');
  return o;
}

const say = (s) => process.stderr.write(s + '\n');
const text = (page) => page.evaluate(() => (document.body ? document.body.innerText : '')).catch(() => '');
const has = (t, s) => t.toLowerCase().includes(s.toLowerCase());

async function main() {
  const opt = args(process.argv.slice(2));
  const dir = path.resolve(opt.dir);
  const t0 = Date.now();
  const secs = () => Math.round((Date.now() - t0) / 100) / 10;
  const { browser, page, log, loadError } = await openGame(dir);

  // What the run saw; the must-haves are judged from this at the end.
  const seen = {
    startText: '', playText: '', overText: '', check: [], hookProblems: new Set(),
    lifeDrops: [], badDrops: [], noInputLifeLostAt: null, overReached: false,
    overAt: null, zeroLivesNotOver: false, negativeLives: false, carriedEver: false, maxDeliveries: 0, maxScore: 0,
    maxLevel: 0, alt: {}, overState: null, restart: null, reload: null,
  };
  let last = null, zeroSince = null;

  // One sample: hook types, life drops, the farthest the game got.
  async function sample() {
    const g = await readGame(page).catch(() => null);
    for (const p of hookProblems(g)) seen.hookProblems.add(p);
    if (!g) return null;
    if (last && typeof g.lives === 'number' && g.lives < last.lives && g.state !== 'start') {
      seen.lifeDrops.push({ t: secs(), from: last.lives, to: g.lives });
      if (last.lives - g.lives !== 1) seen.badDrops.push(`${last.lives} -> ${g.lives}`);
    }
    if (g.carrying === true) seen.carriedEver = true;
    seen.maxDeliveries = Math.max(seen.maxDeliveries, g.deliveries || 0);
    seen.maxScore = Math.max(seen.maxScore, g.score || 0);
    seen.maxLevel = Math.max(seen.maxLevel, g.level || 0);
    if (typeof g.lives === 'number' && g.lives < 0) seen.negativeLives = true;
    if (g.lives <= 0 && g.state === 'playing') {
      zeroSince = zeroSince ?? Date.now();
      if (Date.now() - zeroSince > 3000) seen.zeroLivesNotOver = true;
    } else zeroSince = null;
    last = g;
    return g;
  }

  // 1. The check sequence, word for word what an arm's check.mjs runs.
  seen.startText = await text(page);
  await runCheck(page, log, (name, ok, detail) => seen.check.push({ name, ok, detail }), loadError);
  const checkOk = (prefix) => seen.check.find((c) => c.name.startsWith(prefix))?.ok === true;
  const hooked = (await readGame(page).catch(() => null)) !== null;
  say(`[${secs()}s] check: ${seen.check.filter((c) => c.ok).length}/${seen.check.length} passed`);

  if (hooked) {
    // 2. The alternative keys: W thrusts, A/D rotate without error.
    const ensurePlaying = async () => {
      const g = await readGame(page);
      if (g.state === 'paused') await page.keyboard.press('p');
      else if (g.state === 'start' || g.state === 'over') await page.keyboard.press('Enter');
      return waitState(page, 'playing', 1500);
    };
    await ensurePlaying();
    seen.playText = await text(page);
    const f0 = (await readGame(page)).fuel;
    await hold(page, 'w', 600);
    const f1 = (await readGame(page)).fuel;
    seen.alt.w = { ok: f1 < f0, detail: `W: fuel ${f0} -> ${f1}` };
    const n = log.errors.length;
    await hold(page, 'a', 300);
    await hold(page, 'd', 300);
    seen.alt.ad = { ok: log.errors.length === n, detail: log.errors.slice(n).join(' | ') };

    // 3. No input: is a life eventually lost?
    await ensurePlaying();
    last = await readGame(page);
    const lives0 = last.lives;
    const lifeEnd = Date.now() + opt.lifeWait * 1000;
    say(`[${secs()}s] waiting up to ${opt.lifeWait}s with no input for a life to be lost`);
    while (Date.now() < lifeEnd) {
      const g = await sample();
      if (!g) break;
      if (g.lives < lives0 || g.state === 'over') { seen.noInputLifeLostAt = secs(); break; }
      await sleep(100);
    }

    // 4. On to game over: wait, and thrust (with a turn first) after 15 s without a loss.
    say(`[${secs()}s] driving toward game over for up to ${opt.overWait}s`);
    const overEnd = Date.now() + opt.overWait * 1000;
    let quietSince = Date.now(), turn = 0;
    let lives = last?.lives;
    while (Date.now() < overEnd) {
      const g = await sample();
      if (!g) break;
      if (g.state === 'over') break;
      if (g.state === 'paused' || g.state === 'start') await ensurePlaying();
      if (g.lives !== lives) { lives = g.lives; quietSince = Date.now(); }
      if (Date.now() - quietSince > 15000) {
        await hold(page, turn++ % 2 ? 'ArrowLeft' : 'ArrowRight', 250 + 150 * (turn % 3));
        await hold(page, 'ArrowUp', 1500);
        quietSince = Date.now();
      }
      await sleep(100);
    }
    const g = await sample();
    if (g && g.state === 'over') {
      seen.overReached = true;
      seen.overAt = secs();
      seen.overState = g;
      await sleep(300);
      seen.overText = await text(page);
      await page.keyboard.press('Enter');
      const r = await waitState(page, 'playing', 2000);
      seen.restart = { ok: r.state === 'playing' && r.lives === 3 && r.score === 0 && r.level === 1,
        detail: `state=${r.state} lives=${r.lives} score=${r.score} level=${r.level}` };
      await sample();
    }
    say(`[${secs()}s] game over ${seen.overReached ? 'reached' : 'not reached'}`);

    // 5. A reload keeps best.
    const before = (await readGame(page)).best;
    await page.reload({ waitUntil: 'load' });
    await sleep(500);
    const after = await readGame(page).catch(() => null);
    seen.reload = { before, after: after ? after.best : undefined, state: after ? after.state : undefined };
    await sample();
  }
  await browser.close();

  // ---- judge each must-have from what was seen
  const r = {};
  const failedChecks = seen.check.filter((c) => !c.ok).map((c) => `${c.name}${c.detail ? ' (' + c.detail + ')' : ''}`);
  const hp = [...seen.hookProblems];
  const noHooks = !hooked;

  // 1 Start screen
  if (!checkOk('page loads')) r[1] = [FAIL, `page did not load: ${loadError}`];
  else if (noHooks || !checkOk('state is "start"')) r[1] = [FAIL, noHooks ? 'no window.game, so no start state' : 'state was not "start" on load'];
  else if (has(seen.startText, 'orbit courier') && has(seen.startText, 'press enter to start')) r[1] = [PASS, 'state "start"; title and "Press Enter to start" in the page text'];
  else r[1] = [HUMAN, 'state "start" on load; title/prompt not in the page text (drawn on a canvas?)'];

  // 2 Controls
  {
    const parts = ['Enter starts', 'holding Up', 'Left and Right', 'P pauses', 'P resumes'];
    const bad = parts.filter((p) => !checkOk(p));
    if (seen.alt.w && !seen.alt.w.ok) bad.push(seen.alt.w.detail);
    if (seen.alt.ad && !seen.alt.ad.ok) bad.push('A/D raised errors: ' + seen.alt.ad.detail);
    if (seen.restart && !seen.restart.ok) bad.push('Enter after game over: ' + seen.restart.detail);
    if (noHooks) r[2] = [FAIL, 'no window.game: no key could be checked'];
    else if (bad.length) r[2] = [FAIL, bad.join('; ')];
    else r[2] = [HUMAN, 'Enter, Up/W thrust (fuel drops), Left/Right/A/D (no error), P pause/resume' +
      (seen.restart ? ', Enter restart' : '') + ' all work; rotation itself is not visible through the hooks' +
      (seen.restart ? '' : '; restart not reached')];
  }

  // 3 Gravity
  if (noHooks) r[3] = [HUMAN, 'no window.game: nothing to drive'];
  else if (seen.noInputLifeLostAt !== null) r[3] = [PASS, `a life was lost with no input (at ${seen.noInputLifeLostAt}s), as gravity should cause; whether by the planet or debris, and pull stronger when closer, a human checks`];
  else r[3] = [HUMAN, `no life lost in ${opt.lifeWait}s with no input`];

  // 4-6: not judgeable by a script
  r[4] = [HUMAN, `packages: count and pickup need a human; carrying was ${seen.carriedEver ? 'true at some sample' : 'never true'}`];
  r[5] = [HUMAN, `station and delivery need a human; most deliveries seen ${seen.maxDeliveries}, top score ${seen.maxScore}`];
  r[6] = [HUMAN, `debris per level needs a human; highest level seen ${seen.maxLevel}`];

  // 7 Lives and levels
  {
    const bad = [];
    if (!checkOk('Enter starts')) bad.push('a new game did not start with lives 3, score 0, level 1');
    if (seen.badDrops.length) bad.push('lives dropped by more than 1 at once: ' + seen.badDrops.join(', '));
    if (noHooks) r[7] = [FAIL, 'no window.game'];
    else if (bad.length) r[7] = [FAIL, bad.join('; ')];
    else r[7] = [HUMAN, `starts at 3 lives, level 1; ${seen.lifeDrops.length} life loss(es), each by 1; level up every 3 deliveries needs a human`];
  }

  // 8 Fuel
  {
    const fuelBad = hp.filter((p) => p.startsWith('fuel'));
    if (noHooks) r[8] = [FAIL, 'no window.game'];
    else if (!checkOk('holding Up') || fuelBad.length) r[8] = [FAIL, [...(checkOk('holding Up') ? [] : ['Up did not lower fuel']), ...fuelBad].join('; ')];
    else r[8] = [HUMAN, 'thrust lowers fuel and fuel stays in 0-100; refuel on delivery and no thrust at 0 fuel need a human'];
  }

  // 9 HUD
  {
    const words = ['score', 'lives', 'level', 'fuel'].filter((w) => has(seen.playText, w));
    r[9] = [HUMAN, words.length === 4 ? 'score, lives, level and fuel are in the page text while playing; a human checks they stay visible'
      : `HUD needs a human (page text while playing names: ${words.join(', ') || 'none'} — a canvas HUD is not readable here)`];
  }
  if (noHooks) for (const k of [4, 5, 6, 9]) r[k] = [HUMAN, 'no window.game: nothing seen through the hooks'];

  // 10 Game over
  if (noHooks) r[10] = [FAIL, 'no window.game'];
  else if (seen.zeroLivesNotOver || seen.negativeLives) r[10] = [FAIL, [
    ...(seen.zeroLivesNotOver ? ['lives reached 0 but state stayed "playing" for over 3 s'] : []),
    ...(seen.negativeLives ? ['lives went below 0'] : [])].join('; ')];
  else if (!seen.overReached) r[10] = [HUMAN, `game over not reached in ${opt.overWait}s (${seen.lifeDrops.length} life loss(es) seen)`];
  else {
    const o = seen.overState, bad = [];
    if (o.lives !== 0) bad.push(`state "over" with lives ${o.lives}`);
    if (!(o.best >= o.score)) bad.push(`best ${o.best} < score ${o.score}`);
    if (!seen.restart.ok) bad.push('Enter did not restart cleanly: ' + seen.restart.detail);
    const textOk = has(seen.overText, 'press enter to play again');
    if (bad.length) r[10] = [FAIL, bad.join('; ')];
    else if (textOk) r[10] = [PASS, `game over at 0 lives (${seen.overAt}s), best ${o.best} >= score ${o.score}, Enter restarts with 3/0/1; "Press Enter to play again" in the page text`];
    else r[10] = [HUMAN, `game over at 0 lives (${seen.overAt}s), best ${o.best} >= score ${o.score}, Enter restarts with 3/0/1; the screen text needs a human`];
  }

  // 11 Best score across reloads
  if (noHooks || !seen.reload) r[11] = [noHooks ? FAIL : HUMAN, 'no window.game'];
  else if (seen.reload.before > 0) r[11] = seen.reload.after === seen.reload.before
    ? [PASS, `best ${seen.reload.before} kept across a reload`]
    : [FAIL, `best ${seen.reload.before} before the reload, ${seen.reload.after} after`];
  else r[11] = [HUMAN, `best was ${seen.reload.before} (the script scored no points), so the reload proved nothing; after reload best=${seen.reload.after}`];

  // 12 No downloads at runtime
  if (log.requests.length) r[12] = [FAIL, 'requests: ' + log.requests.slice(0, 5).join(' ')];
  else if (!fs.existsSync(path.join(dir, 'index.html'))) r[12] = [FAIL, 'no index.html'];
  else r[12] = [PASS, 'no request other than file: or data: over the whole run'];

  const report = {
    game: dir,
    seconds: secs(),
    must_haves: Object.fromEntries(Object.entries(r).map(([k, [status, note]]) => [k, { status, note }])),
    check: seen.check,
    console_errors: log.errors,
    hook_problems: hp,
    life_losses: seen.lifeDrops,
    reload: seen.reload,
  };
  const out = JSON.stringify(report, null, 2);
  if (opt.out) fs.writeFileSync(opt.out, out + '\n');
  console.log(out);
}

main().catch((e) => { console.error(`playtest.mjs crashed: ${e.stack || e}`); process.exit(2); });
