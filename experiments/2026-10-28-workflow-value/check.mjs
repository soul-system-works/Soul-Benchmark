#!/usr/bin/env node
// check.mjs — the "Done when" of the Orbit Courier task (SPEC.md). Run it from the
// game's folder: `node check.mjs`. It opens ./index.html in headless Chromium, checks
// the start screen and the test hooks, starts a game, presses the controls, pauses and
// resumes, and fails on any console error or any request that is not file: or data:.
// Each check prints PASS or FAIL; the exit code is 0 only when all of them pass.
//
// A minimum on purpose (SPEC.md: "The check is a minimum"): the games are judged on
// the whole must-have list by a hidden playtest and by two blind scorers.
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import path from 'node:path';

// Playwright comes from the experiment's own kit by absolute path, so a game folder
// needs no `npm install` and no network.
export const KIT = '/mnt/d/Projects/soul/soul-benchmark/experiments/2026-10-28-workflow-value';
const { chromium } = createRequire(path.join(KIT, 'package.json'))('playwright');

export const HOOKS = {
  state: 'string', score: 'number', lives: 'number', level: 'number',
  fuel: 'number', carrying: 'boolean', deliveries: 'number', best: 'number',
};
export const STATES = ['start', 'playing', 'paused', 'over'];
export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

const LOCAL = /^(file|data):/;

// Open <dir>/index.html. Chromium's own sandbox is off so the check also runs inside
// a bubblewrap jail (the Soul System confines a workflow's checks that way), where
// Chromium cannot make its own namespaces. log.errors collects console errors and
// uncaught page errors; log.requests every request that is not file: or data: (those
// are aborted too, so an unconfined run downloads nothing).
export async function openGame(dir) {
  const browser = await chromium.launch({
    headless: true, chromiumSandbox: false, args: ['--disable-dev-shm-usage'],
  });
  const context = await browser.newContext();
  const log = { errors: [], requests: [] };
  await context.route((url) => !LOCAL.test(url.href), (route) => route.abort());
  const page = await context.newPage();
  page.on('console', (m) => { if (m.type() === 'error') log.errors.push(m.text()); });
  page.on('pageerror', (e) => log.errors.push('uncaught: ' + e.message));
  page.on('request', (r) => { if (!LOCAL.test(r.url())) log.requests.push(r.url()); });
  page.on('websocket', (ws) => log.requests.push(ws.url()));
  let loadError = null;
  try {
    await page.goto(pathToFileURL(path.join(dir, 'index.html')).href, { waitUntil: 'load', timeout: 15000 });
    await sleep(500); // let the game set itself up
  } catch (e) {
    loadError = e.message.split('\n')[0];
  }
  return { browser, context, page, log, loadError };
}

// window.game's eight fields, or null when there is no window.game object.
export async function readGame(page) {
  return page.evaluate((keys) => {
    const g = window.game;
    if (!g || typeof g !== 'object') return null;
    const o = {};
    for (const k of keys) o[k] = g[k];
    return o;
  }, Object.keys(HOOKS));
}

// Problems with the hook values, as a list of strings (empty = all well-typed).
export function hookProblems(g) {
  if (!g) return ['window.game is missing'];
  const out = [];
  for (const [k, t] of Object.entries(HOOKS)) {
    if (typeof g[k] !== t) out.push(`${k} is ${typeof g[k]}, want ${t}`);
    else if (t === 'number' && !Number.isFinite(g[k])) out.push(`${k} is ${g[k]}`);
  }
  if (typeof g.state === 'string' && !STATES.includes(g.state)) out.push(`state "${g.state}" is not one of ${STATES.join('/')}`);
  if (typeof g.fuel === 'number' && (g.fuel < 0 || g.fuel > 100)) out.push(`fuel ${g.fuel} is outside 0-100`);
  return out;
}

// Poll until window.game.state === want; returns the last value read.
export async function waitState(page, want, ms = 2000) {
  const end = Date.now() + ms;
  let g = await readGame(page);
  while ((!g || g.state !== want) && Date.now() < end) {
    await sleep(50);
    g = await readGame(page);
  }
  return g;
}

export async function hold(page, key, ms) {
  await page.keyboard.down(key);
  await sleep(ms);
  await page.keyboard.up(key);
}

// The check sequence. report(name, ok, detail) is called once per check, in order;
// once window.game is missing the remaining checks are reported as not run.
export async function runCheck(page, log, report, loadError = null) {
  const steps = [
    ['page loads', async () => (loadError ? [false, loadError] : [true, ''])],
    ['window.game has all 8 hooks, right types', async () => {
      const p = hookProblems(await readGame(page));
      return [p.length === 0, p.join('; ')];
    }],
    ['state is "start" on load', async () => {
      const g = await readGame(page);
      return [g.state === 'start', `state=${g.state}`];
    }],
    ['Enter starts: state "playing", lives 3, score 0, level 1', async () => {
      await page.keyboard.press('Enter');
      const g = await waitState(page, 'playing');
      const ok = g.state === 'playing' && g.lives === 3 && g.score === 0 && g.level === 1;
      return [ok, `state=${g.state} lives=${g.lives} score=${g.score} level=${g.level}`];
    }],
    ['holding Up ~600 ms lowers fuel', async () => {
      const before = (await readGame(page)).fuel;
      await hold(page, 'ArrowUp', 600);
      const after = (await readGame(page)).fuel;
      return [after < before, `fuel ${before} -> ${after}`];
    }],
    ['Left and Right cause no error', async () => {
      const n = log.errors.length;
      await hold(page, 'ArrowLeft', 300);
      await hold(page, 'ArrowRight', 300);
      const g = await readGame(page);
      const p = hookProblems(g);
      const ok = log.errors.length === n && p.length === 0;
      return [ok, ok ? '' : [...log.errors.slice(n), ...p].join('; ')];
    }],
    ['P pauses; score and fuel hold for 600 ms', async () => {
      await page.keyboard.press('p');
      const a = await waitState(page, 'paused', 1000);
      if (a.state !== 'paused') return [false, `state=${a.state}`];
      await sleep(600);
      const b = await readGame(page);
      const ok = b.state === 'paused' && a.score === b.score && a.fuel === b.fuel;
      return [ok, `score ${a.score} -> ${b.score}, fuel ${a.fuel} -> ${b.fuel}, state=${b.state}`];
    }],
    ['P resumes: state "playing"', async () => {
      await page.keyboard.press('p');
      const g = await waitState(page, 'playing', 1000);
      return [g.state === 'playing', `state=${g.state}`];
    }],
  ];
  let all = true;
  let stop = null;
  for (const [name, fn] of steps) {
    if (stop) { report(name, false, `not run: ${stop}`); all = false; continue; }
    let ok, detail;
    try {
      [ok, detail] = await fn();
    } catch (e) {
      [ok, detail] = [false, e.message.split('\n')[0]];
    }
    report(name, ok, detail);
    all = all && ok;
    if (name === 'page loads' && !ok) stop = 'the page did not load';
    else if (name.startsWith('window.game') && !ok && !(await readGame(page).catch(() => null))) stop = 'no window.game';
  }
  report('no console errors', log.errors.length === 0, log.errors.slice(0, 5).join(' | '));
  report('no request other than file: or data:', log.requests.length === 0, log.requests.slice(0, 5).join(' '));
  return all && log.errors.length === 0 && log.requests.length === 0;
}

async function main() {
  const { browser, page, log, loadError } = await openGame(process.cwd());
  let passed = 0, total = 0;
  const report = (name, ok, detail) => {
    total += 1; passed += ok ? 1 : 0;
    console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail && !ok ? ' — ' + detail : ''}`);
  };
  let ok = false;
  try {
    ok = await runCheck(page, log, report, loadError);
  } finally {
    await browser.close();
  }
  console.log(`check.mjs: ${passed}/${total} passed — ${ok ? 'PASS' : 'FAIL'}`);
  process.exit(ok ? 0 : 1);
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  main().catch((e) => { console.log(`FAIL  check.mjs crashed — ${e.message.split('\n')[0]}`); process.exit(1); });
}
