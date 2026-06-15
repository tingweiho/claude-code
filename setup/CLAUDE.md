# Personal Claude Config — Template

Adapt this file to `~/.claude/CLAUDE.md` for your own setup.

## Who I Am
[Your role and domain — e.g. "Senior data scientist. Work spans analytics engineering, app building, ad-hoc analysis, and admin/productivity tasks."]

## Communication
- Concise and direct — no filler, no trailing summaries of what you just did
- Lead with the answer or action, not the reasoning
- Markdown only when it genuinely aids readability

## Coding
- SQL: snake_case, clear aliases, no unnecessary subqueries
- Python: minimal — no docstrings, type hints, or comments for code I didn't ask you to change
- Prefer editing existing files over creating new ones
- No error handling for scenarios that can't realistically happen

## Environment
- macOS, zsh (Powerlevel10k), tmux
- Statusline: `~/.claude/statusline-command.sh` (model / context / git)
- All custom files live in `~/.claude/` (hidden by default in Finder — `Cmd+Shift+.` to show)

## Skills (load on demand)
**Productivity & ops**
- `canvas-tracker` — Slack project tracker canvas ops (full-replace rule, backup sync)
- `scheduled-triggers` — CCR/cron agents: create, update, diagnose, restore prompts
- `gitlab-cli` — `glab` CLI: MRs, CI/CD pipelines, repos, issues; fallback when GitLab MCP/OAuth fails

**Output & analysis**
- `slides` — 16:9 HTML decks (frontend-slides engine): company brand + creative template pack
- `codebase-to-course` — Interactive single-page HTML course from a codebase
- `data-viz` — Chart selection + brand-styled Python notebook visuals
- `data-analysis` — Rigor for diagnostic / exploratory / descriptive / experimental / predictive work
- `pdf` — Read / extract / merge / split / rotate / watermark / fill / OCR PDF files
- `hex` — Hex notebook / CLI API

**Meta**
- `prompt-authoring` — Writing / debugging prompts for agents & triggers
- `skill-creator` — Create, edit, optimize, and eval / benchmark skills
- `regression-guard` — Baseline → change → re-verify for Slack apps, AI agents, dbt

## Reference files
- `~/.claude/reference.md` — Key IDs, local files, scheduled agents, cron jobs
- `~/.claude/known_issues.md` — Historical fixes log
- `~/.claude/canvas_backup.md` — Canvas content restore source
