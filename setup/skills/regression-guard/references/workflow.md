# The Baseline → Change → Re-Verify Protocol

## Full workflow with example

**Scenario:** you're about to add JIRA request-type mapping to Website Ops Hub.

### Phase 1: Baseline (before touching anything)

Write down, in a `test_plan.md` beside the code or in a scratch note:
- **What works today** — list every user-visible behavior you can think of
- **The 3-5 happy paths** — inputs you'll send to sandbox and what JIRA should look like after
- **The 2-3 failure paths** — what happens when JIRA is down, when a user message is empty, when the AI classifies low-confidence

For Website Ops Hub, a baseline might be:

```
BASELINE (as of 2026-04-22)
1. User posts "my dashboard is slow" in #website-help
   → bot replies with ack, creates JIRA ticket type "task" in project WEB, assigned to on-call
2. User posts "site is totally down" with no details
   → bot creates JIRA ticket type "task" with message body as description
3. JIRA API returns 500
   → bot posts error in thread, retries 2×, then gives up gracefully
```

Run each of these in sandbox **before your first change** and confirm they work. If any are broken *already*, don't layer your new work on top — fix the baseline first.

### Phase 2: Change (one concern at a time)

Make the smallest possible change that introduces the new feature. For the request-type mapping:
- Add the mapping logic (form-field lookup)
- **Do NOT** also refactor the ticket-creation code
- **Do NOT** also change the default ticket type
- **Do NOT** also add retry logic

Why: when re-verify fails, you need to know which change caused it. Bundled changes = ambiguous blame.

### Phase 3: Re-verify (run the baseline AGAIN)

Re-run the exact same 3-5 happy paths and 2-3 failure paths from Phase 1. **All must still pass** before you touch the new feature tests.

This is where Website Ops Hub regressed. The new mapping logic replaced the call to "create task type ticket" — so when the mapping didn't fire or returned nothing, the ticket creation path no longer existed. Running Baseline #2 (a vague "site is down" message, unlikely to map cleanly) would have caught this immediately.

### Phase 4: Test the new feature (including its failure mode)

For each new behavior, explicitly test both:
- **Happy path** — mappable input → correct new-type ticket
- **Failure path** — unmappable input → falls back to the baseline behavior

This is the specific check that would have caught the JIRA regression.

### Phase 5: Smoke test (final pass)

A "smoke set" is a curated list of 5-10 tests that must always work. Keep it short, high-signal. Run it:
- Before every deploy to prod
- After every incident (add the incident scenario to it)

Smoke set for Website Ops Hub might be:
1. Normal issue → JIRA ticket created (any type)
2. Empty-description message → ticket still created with placeholder body
3. JIRA outage simulation → graceful error message in thread
4. Low-confidence AI classification → falls back to "task" type
5. User with no Slack profile info → ticket still assigned correctly

## The "test plan" artifact

The single most useful thing is a plain-text `test_plan.md` in the repo next to the code. No framework, no CI, just prose:

```
## Baseline tests (run before any change)
1. <input> → <expected output>
2. ...

## Smoke tests (run before prod deploy)
1. <input> → <expected output>
2. ...

## Past incidents (tests added after things broke)
- 2026-04-18: JIRA mapping broke fallback → added test #4 above
```

This file is the skill applied to your repo. It evolves with the app.

## Why this protocol works

- **Forces written expectations.** "Still works" is vague until you write it down. Written tests make regressions obvious.
- **Splits change from validation.** Most regressions happen in Phase 3 (re-verify). Knowing to run *old* tests, not just new ones, catches 80%.
- **Failure-path coverage.** New features almost always work on happy paths — they break on failure paths the author didn't imagine.
- **Smoke set grows with pain.** Every incident earns a check. Coverage compounds over time rather than being built in a day.
