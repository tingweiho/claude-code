---
name: scheduled-triggers
description: Use this skill whenever the user is working with Claude Code scheduled triggers, CCR, remote agents, cron agents, or scheduled routines — whether creating, updating, diagnosing a missed run, restoring a wiped prompt, or troubleshooting Slack/Gmail/Calendar MCP permissions in an autonomous run. Trigger on oblique phrasings like "why didn't my morning brief come in", "the EOD DM was blank", "schedule a new job", or "my trigger fired but did nothing". Covers the job_config.ccr.events API structure, Always-allow MCP permission requirement, the slack_send_message-vs-draft pitfall, and a prompt-templates.md backup.
---

# Scheduled Triggers (CCR) Ops

## Managing your triggers
Triggers are managed at: https://claude.ai/code/scheduled

Each trigger stores its prompt in `job_config.ccr.events[0].data.message.content` (role: `"user"`).

**Important:** The API also accepts top-level `prompt`/`instructions` fields (returns HTTP 200) but these are **silently ignored**. Do not use them.

**To restore a prompt via `RemoteTrigger update`:**
```json
{
  "job_config": {
    "ccr": {
      "environment_id": "[YOUR_ENV_ID]",
      "events": [{
        "data": {
          "message": {"content": "PROMPT TEXT", "role": "user"},
          "parent_tool_use_id": null,
          "session_id": "",
          "type": "user",
          "uuid": "any-unique-uuid"
        }
      }],
      "session_context": {"allowed_tools": ["Bash","Read","Write","Edit","Glob","Grep"], "model": "claude-sonnet-4-6"}
    }
  }
}
```

**Prompt backup:** Keep a `prompt-templates.md` in this directory — restore via the structure above. The UI can silently wipe prompts (see "Why prompts disappear" below).

## Why prompts disappear
Opening a trigger in the UI to edit any field (e.g. permissions) can silently wipe the prompt if the prompt field renders blank before the page fully loads. Saving at that point overwrites with empty. No warning shown. This is a platform bug.

**Mitigation:** keep `prompt-templates.md` up to date after every prompt edit so restore is trivial.

## MCP permissions for autonomous triggers
All write tools on all MCP connectors (Slack, Gmail, Calendar) must be **Always allow** — not "needs approval". Autonomous CCR sessions have no one to approve, so any "needs approval" tool call silently blocks execution.

Symptom: trigger fires (`updated_at` changes), job run shows no messages or no Slack output.

Specifically, for Slack: ensure `slack_send_message` is Always-allow (not `slack_send_message_draft`). Use `slack_send_message` explicitly in prompts so the agent doesn't pick draft.

## Creating a new trigger

Use the `schedule` built-in skill, or `RemoteTrigger create` directly. Conventions:

- **Cron is UTC.** Common conversions from Central European time:
  - CEST (summer, UTC+2): 9:00 → `0 7 * * *`
  - CET (winter, UTC+1): 9:00 → `0 8 * * *`
- **Weekdays only:** `* * * * 1-5`
- **OOO skip convention:** prompts should start with a calendar check — "If calendar shows a full-day OOO/vacation/out-of-office event today, skip silently without posting."
- **MCP connectors:** attach only what the trigger needs (Slack / Gmail / Calendar). Verify every write tool is Always-allow in the connector settings before enabling the schedule.
- **Test before going live:** `RemoteTrigger run <trigger_id>` fires it immediately
- **Back up the prompt** to `prompt-templates.md` the moment you save it — the UI can wipe prompts (see above)

## Diagnosing a broken trigger
1. Check `updated_at` on trigger — if it changed, the trigger fired
2. Open the job run in the desktop app — "no messages" = empty prompt; messages visible but no Slack output = MCP permission issue
3. Check `job_config.ccr.events[0].data.message.content` is non-empty in the API response
4. If prompt is empty, restore from `prompt-templates.md`
