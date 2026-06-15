# Agent / Scheduled-Trigger Prompts

Patterns for prompts that run autonomously — scheduled triggers, subagents, cron-like jobs. These extend `core-patterns.md` with specifics that only matter when no human is watching the run.

## The skeleton that works

Our triggers that work reliably share this shape:

```
You are <specific role>. <One-sentence purpose.>

Run this <when>.

<Skip condition — first thing checked:>
OOO: If calendar shows a full-day OOO/vacation event today, skip silently without posting.

Steps:
1. <Read/gather — specific sources>
2. <Read/gather — another source>
…
N. <Send output — with exact tool + recipient>

Output format:
<literal template with placeholders>

Rules:
- <edge cases, quality constraints>

<Stable IDs / reference values at the bottom>
```

Why this order: role first (anchors tone), skip condition second (cheapest exit), steps in execution order, format just before "go", constants last.

## Six patterns that consistently matter

**1. Name the exact tool.** Don't say "send a Slack DM" — say "use `slack_send_message` (NOT `slack_send_message_draft`)". When multiple tools could satisfy "send", the agent picks one, and silent drafts are a real failure mode we've hit.

**2. Guard with skip conditions first.** OOO, empty-input, wrong-day-of-week. Put them as step 1 so the agent bails before doing expensive reads.

**3. Stable IDs at the bottom.** Channel IDs, user IDs, canvas IDs, environment IDs — put them at the end as a reference block. Keeps the prose clean, easy to edit, and the agent still picks them up.

**4. Literal output templates beat descriptions.** Instead of "format as a Slack message with sections for summary and proposals", paste the exact template including emoji and dividers. Shape-matching is more reliable than shape-describing.

**5. Cover the empty case.** If there's no activity, what should the agent do? Post nothing? Post a "quiet day" message? Every prompt needs an answer; silence-as-default causes confused reruns.

**6. Permission to stop short.** For agents that react to user replies ("if Ting-Wei approved X, update the canvas"), add an explicit "if there's nothing to do, confirm briefly and stop" rule — otherwise the agent will invent work.

## Common failure modes → fix

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Trigger fires, no Slack output | Tool was `_draft` variant OR MCP permission not Always-allow | Name the tool explicitly; check connector settings |
| Output format varies run-to-run | Format described in prose, not shown as template | Paste a literal example in the prompt |
| Agent rebuilds context every run | Reading redundant sources | Trim step list; remove duplicate reads |
| Gets stuck on edge case (e.g. no git commits) | No empty-case handling | Add "If there are no commits, post <fallback>" |
| Agent tries to DM but the DM is blank | Prompt was wiped by the UI bug | Restore from `scheduled-triggers/trigger_prompts.md` |

## Before saving a new trigger prompt

- [ ] Back it up to `scheduled-triggers/trigger_prompts.md` *before* the UI can wipe it
- [ ] Test with `RemoteTrigger run <id>` before letting cron fire it
- [ ] Verify all MCP write tools it uses are Always-allow in connector settings
- [ ] Check cron is UTC (not Paris time)
