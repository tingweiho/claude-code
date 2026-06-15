---
name: prompt-authoring
description: Use this skill whenever the user is writing, refining, or debugging a prompt that will be sent to Claude — agent prompts for scheduled triggers (daily-digest, EOD, pre-1-1, canvas-updater), system prompts for apps built on the Anthropic API, subagent prompts, or one-off orchestration prompts. Trigger on phrases like "write a prompt for…", "the agent is ignoring X", "my trigger returned empty output", "refine this prompt", "make it more reliable", "how should I word this so Claude…", or on pasted prompt text that looks like it's being iterated on. This is about the words inside the prompt (craft); for SDK mechanics (caching, tool_use, batch API) use `claude-api` instead.
---

# Prompt Authoring

Distilled from Anthropic's prompt engineering tutorial (https://github.com/anthropics/courses/tree/master/prompt_engineering_interactive_tutorial). This skill covers the *craft* of writing prompts that reliably produce the behavior you want.

## Read the right reference for the task

| Task | Read |
|------|------|
| Writing a new prompt from scratch | `references/core-patterns.md` |
| Writing or refining a scheduled trigger / agent prompt | `references/agent-prompts.md` |
| The prompt "works" but gives wrong output — debugging it | `references/debugging.md` |

## Core principles (always-on)

These are small enough to keep in the router; the references expand them.

**1. Be direct and specific.** Vague requests produce vague outputs. "Summarize today's activity" → generic summary. "Produce 5 bullet points, each under 20 words, covering only git commits and Slack threads where Ting-Wei was mentioned" → usable output.

**2. Give Claude a role.** "You are Ting-Wei's end-of-day agent. Your job is to reconstruct today's activity across git, Slack, calendar…" anchors tone and scope.

**3. Separate data from instructions.** When feeding context (channel messages, calendar events, email), wrap it in XML tags (`<slack_messages>…</slack_messages>`) so Claude doesn't confuse data for instructions.

**4. Define the output shape explicitly.** The prompt should specify structure, length, format — "Reply with a JSON object…", "Format as a Slack message with emoji section headers", "One sentence, no preamble". Claude follows shape rules reliably when given them.

**5. Let Claude think before answering.** For multi-step reasoning, ask it to think through steps first — "Before answering, list the relevant git commits, then for each one note…". Skipping this for complex tasks produces shallow, wrong outputs.

**6. Show, don't just tell.** Two or three examples in the prompt are worth a paragraph of explanation. "Here's how I want the log entry formatted: `<example>…</example>`" + 2–3 samples = reliable formatting.

**7. Anticipate and guard against hallucination.** Give Claude permission to say "I don't have enough information" when relevant. Otherwise it will invent.

## What to do next

If the user has pasted a prompt they want help with, load `references/debugging.md` first — it maps symptoms to fixes.

If the user is writing a new scheduled trigger or agent, load `references/agent-prompts.md` — it covers the specific patterns (OOO skip, tool specificity, output contracts) that our existing triggers use.

If this is a one-off prompt for an app or script, `references/core-patterns.md` has the full toolkit.
