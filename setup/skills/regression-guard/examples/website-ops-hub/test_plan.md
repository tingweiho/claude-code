# Website Ops Hub — Test Plan

Drop this at the root of the repo. Keep it updated as the app evolves. Run it by hand in the sandbox Slack workspace before deploying to prod.

---

## Baseline (must always work — run before AND after every change)

| # | Input to sandbox Slack | Expected outcome |
|---|-----------------------|------------------|
| 1 | Post in `#website-help`: "Landing page is slow during peak hours" | Bot acks + JIRA ticket created in project WEB (any request type), mandatory fields populated |
| 2 | Post in `#website-help`: "hey can someone help" (vague, unmappable) | Bot acks + JIRA ticket created as **fallback "task" type** — **this is the regression check from 2026-04** |
| 3 | Post in `#website-help` with JIRA temporarily unreachable | Bot posts graceful error in thread, retries 2×, doesn't crash |
| 4 | Post a ~3-word message: "site down help" | Bot creates ticket, body populated with the short text |
| 5 | Post with a file attachment but no description | Ticket created, file link/reference preserved in description |

---

## Smoke set (run before every prod deploy — subset of baseline)

The smallest set that would catch a broken deploy:
- #1 (happy path)
- #2 (fallback path) ← the one that burned us
- #3 (error handling)

3 tests, ~2 minutes. Skipping these is the root cause of most "works in dev, broken in prod" incidents.

---

## New-feature tests (specific to the change you're making)

When adding a feature, write tests here BEFORE implementing. Delete or archive when the feature is stable and its tests are folded into baseline.

**Example — request-type mapping feature:**

| # | Input | Expected |
|---|-------|----------|
| A | "My site takes 10 seconds to load on mobile" | Mapped to `performance`, mandatory fields filled from form schema |
| B | "Need help with branding guidelines" | Mapped to `content-request` or falls back to `task` |
| C | "asdfghjkl test" (gibberish) | Falls back to `task` — DO NOT crash or skip ticket creation |
| D | Low-confidence AI classification (model returns 0.3) | Falls back to `task` |
| E | AI classifier throws an exception | Falls back to `task` — exception caught, logged |

---

## Past incidents (tests added after things broke)

Every production issue earns a row. Format: `YYYY-MM-DD — what broke — which test now covers it`.

- **2026-04-XX** — Adding request-type mapping removed the fallback "task" creation path. Unmappable messages produced no ticket at all. → Baseline #2 now explicitly tests this.

---

## Deploy protocol

1. ✅ Run baseline in sandbox — all pass before any change
2. ✅ Make change (one concern at a time)
3. ✅ Run baseline again — must still pass
4. ✅ Run new-feature tests
5. ✅ Run smoke set one final time
6. ✅ Deploy to prod
7. ✅ Run smoke set in prod (yes, in prod — use a dedicated `#website-help-test` channel)
8. ✅ Watch for errors for 10 minutes before walking away

If any step fails, fix before continuing. Don't layer changes on a broken baseline.

---

## What "done" means

A change is done when:
- All baseline tests still pass
- New-feature tests pass (happy path AND failure path)
- Smoke set passes
- No errors in logs for 10 minutes post-deploy
- If the change introduces a new failure mode, its check has been added to baseline
