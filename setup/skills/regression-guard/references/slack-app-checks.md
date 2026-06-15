# Slack App Regression Checks

For Slack apps deployed to sandbox → prod with no dedicated web admin UI (like Website Ops Hub). The testbed is Slack itself.

## The scripted sandbox plan

Since there's no UI to drive, maintain a written list of Slack interactions that constitute the baseline. Keep it with the code.

**Format:**
```
## Sandbox smoke plan — <app name>

Pre-deploy, in the sandbox workspace:

1. Post in #<channel>: "<exact message>"
   → Expected: <bot response / side effect in JIRA / DB / etc>
2. Run /slash-command in #<channel>
   → Expected: <modal shows / ack message / etc>
3. Click button on yesterday's bot message
   → Expected: <state change>
...
```

Keep it to 5-10 checks. Boring is fine — you want predictability.

## What breaks most often in Slack apps

### 1. "New primary path replaced the old fallback"
**Example (Website Ops Hub, 2026-04):** adding JIRA request-type mapping replaced the single call to create a generic "task" ticket. When the mapping didn't fire, the fallback was gone — so nothing got created at all.

**Check:** after adding any "smart" branch, test with an input that will NOT match the smart branch. The old behavior must still run.

### 2. OAuth scope shrunk or changed
Adding a feature sometimes causes someone to "clean up" scopes. If `chat:write.public` gets removed, the bot can no longer post in channels it isn't a member of — silent break.

**Check:** list the scopes before and after the change. Any removal needs explicit justification.

### 3. Event subscription endpoint broken
The endpoint Slack pings (e.g. `/slack/events`) must return 200 within 3s. A refactor that makes it async-heavy or slow can cause Slack to stop sending events — silent break.

**Check:** Slack's event log in the app config shows delivery failures. Look there after every deploy.

### 4. Bot user renamed or re-authed
If the bot token rotates or the bot user ID changes, any code that hardcodes the bot ID (e.g. "ignore messages from @thisbot to avoid loops") breaks.

**Check:** pull bot user info from `auth.test` on startup rather than hardcoding.

### 5. Modal / Block Kit payload validation
Slack's Block Kit is strict. Adding a new field with a typo in the type (`"plain_text_input"` vs `"plain_text"`) breaks the whole modal, not just the field. Errors surface as "something went wrong" to the user with no detail.

**Check:** send every new modal through Slack's Block Kit Builder (https://app.slack.com/block-kit-builder) before deploying.

### 6. Rate-limit backoff disturbed
Changing how the app handles Slack API calls (e.g. switching SDKs, changing retry wrapper) can silently remove exponential backoff. First busy moment in prod → 429 storm → app looks dead.

**Check:** the 429 handler is covered by a unit test OR you've manually verified backoff by hammering sandbox.

### 7. Interactive timeout (3 seconds)
Slack requires an ack for button/slash commands within 3s. Any new step on that path — a synchronous LLM call, an external API, a DB query — can push past it. The user sees "operation_timeout" in Slack.

**Check:** any interactive path must `ack()` immediately and do the work in a background task. Reviewing the code path for this is part of every change.

## Website Ops Hub — concrete smoke set

Use this as a template. Adapt to the specific app.

```
1. Post "dashboard is broken" in #website-help
   → Bot acks + creates JIRA ticket (any type) in project WEB
2. Post "<random gibberish>" in #website-help
   → Bot acks + creates JIRA ticket as fallback "task" type
   [THIS IS THE CHECK THAT WOULD HAVE CAUGHT 2026-04 REGRESSION]
3. Post "my site is extremely slow during peak hours" in #website-help
   → Bot creates JIRA ticket with mapped request type (performance), mandatory fields populated
4. Simulate JIRA API 500 (point at a bad URL temporarily)
   → Bot posts graceful error in thread, retries, doesn't crash
5. Post empty message (just a file attachment) in #website-help
   → Bot still creates ticket with file reference
```

## Deploy discipline

- **Deploy to sandbox only during hours you can test.** Don't ship to sandbox at 5pm Friday — the test happens Monday, and the code has been live for the weekend untested.
- **Wait ~10 minutes between sandbox deploy and prod deploy.** Run smoke in sandbox first. If prod is identical logic and sandbox passed, prod should too. If not, find out why before prod.
- **Keep a ROLLBACK command ready.** Know exactly how to revert (git SHA + redeploy command, or infrastructure command) before you need it.

## Adding new regressions to this file

When something breaks in prod and you fix it, add a new check to the smoke set. Include:
- Date
- One-line description of what broke
- The specific sandbox test that would have caught it

Example future entry:
```
- 2026-05-XX: bot stopped acking DMs after adding home-tab feature
  → new smoke check: "DM the bot 'hi' → bot responds within 3s"
```
