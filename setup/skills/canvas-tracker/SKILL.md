---
name: canvas-tracker
description: Use this skill whenever the user mentions the canvas, the project tracker, their projects (P1/P2/P3/P4), a log entry, "add to the canvas", "update my status", an ETA change, a priority bump, "mark this done", completed projects, or monitoring channels — even if they don't explicitly say "canvas". Trigger on any status/ETA/next-action update that sounds like a project, or on troubleshooting canvas rendering issues (channel mentions not rendering, proxy errors, missing sections). Covers the full-replace rule (never section-level edits), channel mention format, MCP proxy size limits, emoji section headers, and a companion learnings.md with known gotchas.
---

# Slack Project Tracker Canvas

- **Canvas ID:** `[YOUR_CANVAS_ID]` — find it in the canvas URL: `https://[workspace].slack.com/docs/[team_id]/[canvas_id]`
- **Purpose:** Single source of truth for your active projects, priorities, and status
- **Read by:** Daily digest trigger (if configured) every morning

## Canvas structure
- Projects sorted by priority: P1 (Do First) → P2 → P3 → P4 → Completed Projects
- Each project has: Scope, Channel (if applicable), Role, Status, ETA, Next action, Log (timestamped)
- Monitoring Channels section: channels to read but not tracked as projects
- Status emojis: 🟡 In progress · 🔴 Blocked · 🔧 Maintenance · ⏸️ Deprioritized · ✅ Done
- Priority section emoji headers: 🔴 P1 · 🟠 P2 · 🟡 P3 · 🟢 P4 · ✅ Completed · 💬 Monitoring Channels
- **Deprioritized ≠ Completed.** A deprioritized/parked project goes to **P4 (lowest priority)** with Status `⏸️ Deprioritized` and a Next line stating the revival condition — NOT the Completed section. Completed is reserved for work that was genuinely delivered/shipped or formally closed. A project whose deliverable shipped but had further scope dropped stays Completed.

## Canvas editing rules — CRITICAL
- **Always use full canvas replace** (`slack_update_canvas` with `action=replace`, no `section_id`) — NEVER use section-level edits
- Section-level edits corrupt the canvas and truncate content
- After any update, verify all sections are intact
- **Always update `~/.claude/canvas_backup.md`** after every canvas change (safety net in case of platform wipe)
- **STRIP the canvas title from the body before writing.** The canvas has a persistent title that renders separately from body content. `slack_read_canvas` returns this title as the first H1 in `markdown_content`. If you write that H1 back into the body, it shows as a duplicate AND each replace round-trip multiplies them. Before calling `slack_update_canvas`, remove any line matching the canvas's own title. The body MUST start with `# Project Tracker — [Your Name]`.

## How to update the canvas
When user says "update project X" or gives a status change:
1. Read the canvas first to get current content (`slack_read_canvas`)
2. Apply the change (update Status / ETA / Next, append to Log with today's date)
3. Do a full replace with the entire updated content
4. Sync `~/.claude/canvas_backup.md` with the new content

## Log entry format — CANONICAL
Every Log entry uses this exact shape:

    YYYY-MM-DD: <one-line description>

Examples:
    * 2026-04-22: Scope finalized; extraction handed to teammate. ETA Apr 28.
    * 2026-04-21: Phase 1 done. Phase 2 deferred — protecting bandwidth.

Rules:
- Date-prefix with a colon. Newest entries at the TOP of the Log list.
- One line per entry. If you need more, split into multiple dated entries or trim.
- **Never use the trailing-timestamp variant** (`<description> [YYYY-MM-DD HH:MM:SS TZ]`). Past entries in this format should be normalized when you next touch them.

## Channel mention format
- Use bare `<#CHANNEL_ID>` — the only format that reliably renders as a clickable link
- `<#ID|name>` renders as literal text (don't use)
- `#channel-name` is plain text (not clickable)
- `#CHANNELID` causes a hard MCP proxy error (don't use)
- Private channel IDs may not resolve to clickable links if the MCP bot isn't a member — accept this

## MCP proxy size limit
- Large canvases trigger "Anthropic Proxy: Invalid content from server" errors
- Emoji characters are 3–4 bytes in UTF-8 vs 1 byte for ASCII — they push payloads over faster
- Mitigation: keep log entries concise (one line each, no repetition of Status/Next context)

## Companion file
See `learnings.md` in this directory for the detailed session-by-session notes behind these rules.
