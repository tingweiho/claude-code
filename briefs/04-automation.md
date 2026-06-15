# Module 4: The Automation Layer — the always-on system

Module bg: EVEN module → `style="background: var(--color-bg)"`. id = `module-4`, number `04`.
**NO QUIZZES.** This module owns a mandatory **data-flow animation** (the EOD → canvas loop). Biggest module — keep each screen tight (2-3 sentences, then a visual).

### Teaching Arc
- **Metaphor:** A smart home. Three kinds of automation, each with a different trigger: motion-sensor lights (fire on an *event*), a sprinkler timer (fire on a *clock*, locally), and a house-sitter (runs in the cloud, and can actually answer the door and use the phone). Knowing which is which is the whole skill.
- **Opening hook:** "A lot of my Claude Code work happens when I'm not at the keyboard."
- **Key insight:** There are three distinct mechanisms — **hooks** (event-driven, local), **cron** (clock-driven, local, *headless*), and **cloud scheduled triggers** (clock-driven, cloud, can reach Slack/Gmail/Calendar). They differ in *what they can touch*, and that difference dictates the whole design.
- **Why care:** Most people only know one of these. Knowing all three — and their limits — is what lets you offload real recurring work safely.

### Screens (6)

**Screen 1 — Three mechanisms.** `.pattern-cards` (3):
- 💡 **Hooks** — motion-sensor lights. Fire on an *event* (a session ends, a file is saved). Local, instant.
- ⏰ **Local cron** — sprinkler timer. Fire on a *clock*. Local and *headless* — no login session, so no connected apps.
- ☁️ **Cloud triggers (CCR)** — house-sitter. Fire on a clock *in the cloud*, and *can* use connected apps (Slack, Gmail, Calendar).

**Screen 2 — Hooks (event-driven).** 2 sentences + `.badge-list` of my live hooks:
- `Stop` → `log_usage.sh` — logs tokens + cost when a session ends
- `slack_update_canvas` → `canvas_backup_sync.sh` — mirrors the project canvas to a local file
- `statusLine` → `statusline-command.sh` — the model / context% / git info line in my terminal
Code↔English of the hook wiring (real, safe):
```
"Stop": [{ "hooks": [{
  "type": "command",
  "command": "bash ~/.claude/log_usage.sh",
  "timeout": 10
}]}]
```
RIGHT: "When a session ends (the `Stop` event)..." / "...run this script..." / "...and give it 10 seconds. It reads how many tokens I burned and appends the cost to a CSV."

**Screen 3 — Local cron (clock-driven, local).** 2 sentences: a timed job on my own machine. My one active cron: `auto_rebase.sh`. Code↔English:
```
0 6,8,10,12,14,16 * * 1-5   ~/.claude/auto_rebase.sh
```
RIGHT: "At minute 0 of 6am, 8, 10, 12, 2pm, 4pm..." / "...Monday–Friday..." / "...pull the main branch into my working branches so I never drift far behind." `.callout callout-accent`: it **merges**, it never **rebases** — merging avoids the false conflicts that history-rewriting creates. (A hard-won rule, saved to memory.)

**Screen 4 — Cloud triggers (the daily rhythm).** Use `.step-cards` as a timeline of the 4 cloud agents (times in my timezone, generic):
1. **daily-digest** (morning) — reads my project canvas, unread Slack, calendar, and email, then DMs me a briefing.
2. **daily-progress-check / EOD** (evening) — reconstructs what I shipped today and proposes updates to my tracker.
3. **canvas-updater** (night) — applies the approved updates to the project canvas.
4. **gmail-auto-label** (every 2 hours) — a silent inbox janitor: labels and files mail by sender, archives noise.

**Screen 5 — The EOD → canvas loop (hero: data-flow animation).** `.flow-animation`, `data-steps` (⚠️ no apostrophes in labels). Actors `flow-actor-1..5`: **EOD agent**, **My DM**, **Me**, **canvas-updater**, **Tracker canvas**.
```
[
 {"highlight":"flow-actor-1","label":"Evening: the EOD agent drafts what I shipped today"},
 {"highlight":"flow-actor-2","label":"It sends that draft to my Slack DM","packet":true,"from":"actor-1","to":"actor-2"},
 {"highlight":"flow-actor-3","label":"I reply with tweaks — or say nothing","packet":true,"from":"actor-2","to":"actor-3"},
 {"highlight":"flow-actor-4","label":"At night, canvas-updater reads that thread","packet":true,"from":"actor-3","to":"actor-4"},
 {"highlight":"flow-actor-5","label":"It rewrites the project tracker — default-approve if I stayed quiet","packet":true,"from":"actor-4","to":"actor-5"}
]
```
One sentence: a human-in-the-loop that defaults to *yes* — silence ships the proposal, so the tracker stays current even on busy days.

**Screen 6 — The lesson + the receipts.** Two parts.
(a) `.callout callout-warning`: **headless ≠ connected.** A local `claude -p` cron run has *no* login session, so it can't open Slack, Gmail, or Calendar. I learned this the hard way — two cron scripts that tried to DM me (`post_git_log.sh`, `post_usage.sh`) were *retired*, and that work moved to cloud triggers (which can connect) or got reconstructed from notification emails. This is exactly the "which mechanism can touch what" point from screen 1.
(b) Usage tracking — the `Stop` hook quietly builds a cost ledger. Code↔English of the cost formula (real):
```
cost = input_tokens      x $3.00 / 1M
     + cache_write_tokens x $3.75 / 1M
     + cache_read_tokens  x $0.30 / 1M
     + output_tokens      x $15.00 / 1M
```
RIGHT: "Different token types cost different amounts." / "Cached reads are 10x cheaper than fresh input — which is why reusing context is worth it." / "Every session appends a row to `daily_usage.csv`, so I always know my burn." Use `<span class="calc">` for any inline arithmetic.

### Interactive Elements
- [x] **Data-flow animation** (hero, screen 5) — EOD → canvas
- [x] **Code↔English** ×3 — hook wiring (2), cron line (3), cost formula (6)
- [x] **Pattern cards** — 3 mechanisms (1)
- [x] **Step cards** — daily rhythm timeline (4)
- [x] **Badge list** — hooks (2)
- [x] **Callouts** — accent (3), warning (6)
- [ ] NO quiz

### Reference sections to read
- `interactive-elements.md` → Message Flow / Data Flow Animation (single-quote warning!), Code↔English, Pattern/Feature Cards, Numbered Step Cards, Permission/Config Badges, Callout Boxes, Glossary Tooltips
- `content-philosophy.md` (all) · `gotchas.md` (all) · `design-system.md` → Color Palette, Code Block Globals

### Tooltips to define
hook, event-driven, cron, headless, login session, connector / connected app, CCR (cloud scheduled trigger), DM, rebase vs merge, branch, token, prompt caching / cache read, CSV, `claude -p`.

### Connections
- **Previous:** Module 3 ended on the repetitive admin lane and promised the robots that run it.
- **Next:** Module 5 — how Claude *remembers* corrections (like "merge, never rebase") so I only say them once.
- **Tone:** terracotta accent; identifiers in `<code>`; keep prose tight, this module is dense.
