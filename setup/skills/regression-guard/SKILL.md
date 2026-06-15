---
name: regression-guard
description: Use this skill whenever you are building, modifying, or deploying a feature to an existing Slack app, AI agent, dbt model, or any system where a change risks breaking what already works. Trigger on phrases like "add a feature to Website Ops Hub", "ship this to sandbox", "deploy to prod", "QA this change", "make sure nothing breaks", "the Slack app is broken after my last change", "my agent used to work and now doesn't", or any time iterative development could introduce a regression. This skill codifies the baseline → change → re-verify protocol that catches "new feature becomes the only code path" failures like the Website Ops Hub JIRA mapping incident. For prompt-specific craft use `prompt-authoring`; for dbt data QA specifics use `data-stack`.
---

# Regression Guard

Protects against the most common iteration failure: **a new feature silently replaces a path that used to work**, so the "basic" functionality breaks in ways the author doesn't notice until a user hits it.

## The core protocol

```
1. BASELINE   → capture what currently works, as concrete test inputs with expected outputs
2. CHANGE     → make the change (one concern at a time)
3. RE-VERIFY  → run BASELINE again — it must still pass BEFORE testing new features
4. NEW-FEATURE→ test the new functionality, including its failure path
5. SMOKE      → run the 5-10 "must always work" checks before declaring done
```

The critical step is #3. It's the one most often skipped under "the change is small" pressure. Skipping it is exactly how the Website Ops Hub JIRA-mapping feature removed the fallback-ticket path without anyone noticing.

## Read the right reference for your stack

| Building | Read |
|----------|------|
| A Slack app deployed to sandbox/prod (no web UI) — e.g. Website Ops Hub | `references/slack-app-checks.md` |
| An AI agent (triage, classification, routing) with LLM calls | `references/ai-agent-checks.md` |
| A dbt model or warehouse change | `references/data-model-checks.md` |
| Unsure where to start — the full protocol with examples | `references/workflow.md` |

## Anchor principles

**1. New path ≠ only path.** When you add a "smart" version of something (AI mapping, type inference, enrichment), the old "dumb" fallback must still run when the smart path fails. Test the failure case of the new path explicitly — that's where the safety net lives.

**2. Sandbox is not a test harness.** Deploying to sandbox and poking it by hand is slower, less reliable, and easy to skip under time pressure. A short scripted test plan beats hand-verification every time. Even just "here are the 5 Slack messages I'll send and what should happen" written down is enough.

**3. Every production incident earns a regression check.** When something breaks and you fix it, the fix should include adding a check to the smoke set so the same thing can't break the same way twice. This is how your test set grows toward actual coverage.

**4. Know what "basic" means before the change.** "Don't break basic functionality" is unactionable. "Creating a JIRA ticket from a Slack message must still work even if mapping fails" is. Write the "basic" down first.

## When something DOES break in prod

1. Stop shipping. Don't add more changes on top of a broken baseline.
2. Revert to the last-known-good version if the fix isn't obvious within 15 minutes.
3. After the fix, add the failure scenario to your smoke set in the relevant `references/*.md`.
4. Log it: a short note in the relevant reference file on *why* this check now exists.
