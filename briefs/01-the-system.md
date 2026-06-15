# Module 1: The System — `~/.claude/` as an operating layer

Module bg: ODD module → use `style="background: var(--color-bg-warm)"`. id = `module-1`, number `01`.
Audience: colleagues/peers curious how a senior data scientist actually runs Claude Code. Smart but not necessarily familiar with hooks/MCP/cron. Tooltip jargon aggressively. **NO QUIZZES anywhere in this course.**

### Teaching Arc
- **Metaphor:** A workshop pegboard — every tool has a painted outline on the wall, so you see at a glance what's there and what's missing. `~/.claude/` is that pegboard: a fixed place for every kind of instruction, loaded before you say a word.
- **Opening hook:** "Every time I open Claude Code, it reads a handful of files before I type anything. Those files are why it already knows how I work."
- **Key insight:** Claude Code isn't configured by one big settings screen — it's a small *file system* you own. A lean index file, a skills folder, two permission files, some hooks, and a memory folder. Treat it like a codebase.
- **Why care:** Once you see the layout, you know where to put a new instruction — and you stop re-explaining yourself every session.

### Screens (5)

**Screen 1 — Hook + the idea.** 2-3 sentences: config is a persistent *operating layer* that loads before every session. Not a one-off prompt — a standing setup you version and improve. One `.callout callout-accent` ("Aha!"): the config is read top-to-bottom at startup, so order and brevity matter.

**Screen 2 — The pegboard (hero: visual file tree).** Use a `.file-tree` of `~/.claude/`. Annotate each entry in plain English:
- `CLAUDE.md` — who I am + how to talk to me + an index of my skills (48 lines)
- `skills/` — 16 folders of on-demand expertise
- `settings.json` — global guardrails, hooks, and data connections
- `settings.local.json` — the "yes, you may run this" allow-list
- `hooks/` — small scripts that fire on events
- `reference.md` — IDs, file paths, schedules I look up often
- `known_issues.md` — a running fixes log
- `*.sh` scripts — `statusline-command.sh`, `log_usage.sh`, `ci-watch.sh`, `auto_rebase.sh`
- `memory/` — durable facts Claude has learned about me

**Screen 3 — `CLAUDE.md` is a directory, not a manual.** Code↔English translation block. LEFT (real, anonymized excerpt — keep exactly as given):
```
## Communication
- Concise and direct — no filler, no trailing summaries
- Lead with the answer or action, not the reasoning

## Skills (load on demand)
- aircall-data-stack — Redshift / dbt / Looker / LookML
- canvas-tracker — Slack project tracker canvas ops
- data-analysis — rigor for diagnostic / exploratory work
```
RIGHT (plain English, line-grouped): "First it tells Claude *how* to talk to me — short, answer-first." / "Then it lists my skills with one line each on when they fire." / "It doesn't explain the skills — it just points to them. The detail lives inside each skill folder." 
Follow with a `.callout callout-accent`: **"My whole `CLAUDE.md` is 48 lines."** It works as a table of contents that points outward, not a manual that holds everything. (We'll come back to why in the last module.) Wrap identifiers like `CLAUDE.md`, `aircall-data-stack` in `<code>`.

**Screen 4 — Two permission files, one job each.** Use `.icon-rows` (2 rows): 
- `settings.json` (🛡️) — *global* guardrails: a deny-list of destructive commands, the hooks, and the data connections. Shared default.
- `settings.local.json` (✅) — the *allow-list*: ~322 specific commands I've pre-approved so I'm not clicking "allow" all day.
Then a `.badge-list` of a few real deny patterns (these are guardrails, safe to show):
- `Bash(rm -rf*)` — never bulk-delete files
- `Bash(git push --force*)` — never rewrite shared history
- `Bash(sudo*)` — never run as administrator
One `.callout callout-info`: separating *deny* (global, rarely changes) from *allow* (local, grows over time) keeps the dangerous list short and auditable.

**Screen 5 — Data connections (MCP).** 2 sentences: MCP is how Claude reaches my real tools — the data warehouse, the BI tool — instead of just chatting. Use `.icon-rows` for the 4 connections: dbt, Looker, Redshift, Redshift (superuser). Then a code↔English block. LEFT (**redacted** MCP config — use exactly this, secrets already masked):
```
"redshift": {
  "command": "uvx",
  "args": ["awslabs.redshift-mcp-server@latest"],
  "env": {
    "AWS_PROFILE": "<aws-account>_DataRedshift",
    "AWS_REGION": "us-west-2"
  }
}
```
RIGHT: "Names a connection called `redshift`." / "`uvx` downloads and runs a tiny server on the fly." / "The env vars tell it *which* account and region — the actual secrets live outside this file, never in plain text." End screen with `.callout callout-warning`: real configs hold live credentials (connection strings, client secrets, tokens). **Everything shown in this course is redacted** — that discipline is itself part of the setup (more in the last module).

### Interactive Elements
- [x] **Visual file tree** (hero, screen 2)
- [x] **Code↔English** ×2 — `CLAUDE.md` excerpt (screen 3), MCP config (screen 5)
- [x] **Icon rows** — settings split (screen 4), MCP connections (screen 5)
- [x] **Permission badges** — deny patterns (screen 4)
- [x] **Callouts** — accent (screens 1, 3), info (4), warning (5)
- [ ] NO quiz

### Reference sections to read
- `interactive-elements.md` → Visual File Tree, Code↔English Translation Blocks, Icon-Label Rows, Permission/Config Badges, Callout Boxes, Glossary Tooltips
- `content-philosophy.md` (all) · `gotchas.md` (all) · `design-system.md` → Color Palette, Module Structure

### Tooltips to define (first use)
config, `CLAUDE.md`, skill, hook, MCP (Model Context Protocol), server, environment variable / env var, deny-list, allow-list, `uvx`, data warehouse, Redshift, dbt, Looker, credential.

### Connections
- **Previous:** none (this is the opener).
- **Next:** Module 2 zooms into the `skills/` folder — what a skill is and how the right one loads itself.
- **Tone:** terracotta accent; warm, first-person ("I"), confident, not salesy. Identifiers always in `<code>`.
