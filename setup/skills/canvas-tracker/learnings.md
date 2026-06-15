# Canvas Management — Learnings & Known Behaviours

## MCP Proxy Size Limit

**Symptom:** `Anthropic Proxy: Invalid content from server` error on `slack_update_canvas`
**Cause:** The MCP proxy has a byte-size limit on canvas update payloads. The exact threshold is unknown but is easy to hit with ~10 active/completed projects.
**Why emojis make it worse:** Emoji characters are 3–4 bytes each in UTF-8 vs 1 byte for ASCII. Section headers like `## 🔴 P1 — Do First` cost significantly more than `## P1 - Do First`.
**Fix:** Keep log entries concise. When a size error occurs:
1. Trim verbose log text (shorten old entries, remove redundant context)
2. Retry — the same content sometimes succeeds on retry (intermittent proxy flakiness)
3. If still failing, temporarily strip emoji headers as a last resort

**Rule going forward:** Keep log entries short. One line per entry, no repetition of context already in Status/Next fields.

---

## Channel Mention Rendering

**What works:** `<#CHANNEL_ID>` — renders as a clickable channel link in Slack canvas IF the MCP token has access to that channel.
**What doesn't work:**
- `<#CHANNEL_ID|name>` — renders as literal text `<#ID|name>` (canvas API does not process the pipe-name format)
- `#CHANNEL_ID` — renders as plain text, not a link
- `#channel-name` — renders as plain text, not a link
- `#ID` format — causes a hard proxy error (rejected entirely)

**Why `<#ID>` works for some channels and not others:** The Slack API resolves the ID to a channel name at render time. If the MCP token is not a member of the channel (e.g. private channel), the ID cannot be resolved and renders as raw text.

**For private channels:** Either invite the Claude bot to the channel, or accept that the channel field will show the raw ID.

---

## Canvas Title vs. Body H1 Duplication

**Symptom:** Canvas renders multiple duplicate H1s at the top.
**Cause:** The canvas has its own persistent title (shown in the tab bar and as the first element at the top of the rendered canvas) that is separate from the markdown content. If the markdown payload *also* starts with an H1 matching that title, it renders as an additional in-body header. Over multiple replaces, stray `#` H1s at the top of the content stack up visibly.
**Fix:** Do NOT include an H1 matching the canvas title at the top of the markdown payload. Start the body with the first distinct section header (e.g. `# Project Tracker — [Your Name]`). The canvas's own title handles display of the emoji-prefixed name.
**Detection:** The `slack_read_canvas` response reveals the dupes — look for two or more identical entries in `section_id_mapping` with the same `# …` value. The first one (with the stable ID) is the canvas's own title; any others are in-body duplicates that should be stripped on the next replace.

---

## Canvas Full Replace — Always Required

**Rule:** Always use `action=replace` without `section_id`. Section-level edits corrupt the canvas and truncate content.
**Why:** The Slack canvas API processes section-level edits unreliably via MCP — content after the targeted section gets dropped.

---

## Channel ID → Name Lookup

Use `slack_read_channel` with `limit=1` to resolve a channel ID to its display name (name appears in the response header `Channel: #name (ID)`). This is more reliable than `slack_search_channels` which often returns no results for private or less-common channels.

---

## Backup

- Backup file: `~/.claude/canvas_backup.md`
- **Must be updated after every canvas change**
- To restore: read the backup and do a full `action=replace` on your canvas
