# Setup — Portable Claude Code Config

My personal Claude Code configuration, stripped of company-specific data. Drop these into a new machine and you're 80% back to full power in minutes.

## What's here

```
CLAUDE.md           ← global config template (~/.claude/CLAUDE.md)
settings.json       ← permissions + hooks (~/.claude/settings.json)
agents/
  regression-reviewer.md   ← adversarial pre-done code reviewer
scripts/
  statusline-command.sh    ← 2-row status line (model / context / git)
  auto_rebase.sh           ← stash → merge origin/main → pop for all repos
  log_usage.sh             ← daily usage stats logger (Stop hook)
skills/
  canvas-tracker/          ← Slack canvas project tracker (P1–P4, full-replace rule)
  codebase-to-course/      ← turn any codebase into an interactive HTML course
  data-analysis/           ← rigor for diagnostic / exploratory / predictive work
  data-viz/                ← chart selection + brand-styled Python visuals
  gitlab-cli/              ← glab CLI: MRs, CI/CD, pipelines, repos
  hex/                     ← Hex analytics platform CLI
  pdf/                     ← read / extract / merge / split / OCR PDFs
  prompt-authoring/        ← write and debug prompts for agents & triggers
  regression-guard/        ← baseline → change → re-verify protocol
  scheduled-triggers/      ← CCR cron agents: create, update, diagnose, restore
  skill-creator/           ← create, edit, optimize, and eval skills
  slides/                  ← 16:9 HTML decks (frontend-slides engine)
```

## Installation

```bash
# 1. Clone this repo (or copy the setup/ folder)
git clone https://github.com/tingweiho/claude-code.git

# 2. Copy config files
cp setup/CLAUDE.md ~/.claude/CLAUDE.md          # edit with your own details
cp setup/settings.json ~/.claude/settings.json  # tweak permissions as needed

# 3. Copy skills
cp -r setup/skills/* ~/.claude/skills/

# 4. Copy agents
cp -r setup/agents/* ~/.claude/agents/

# 5. Copy scripts
cp setup/scripts/statusline-command.sh ~/.claude/statusline-command.sh
cp setup/scripts/auto_rebase.sh ~/.claude/auto_rebase.sh
cp setup/scripts/log_usage.sh ~/.claude/log_usage.sh
chmod +x ~/.claude/*.sh
```

## What to customize

- **`CLAUDE.md`** — fill in your role, preferred skills, and reference file paths
- **`settings.json`** — adjust the `canvas_backup_sync.sh` hook path, or remove if not using canvas tracker
- **`skills/canvas-tracker/SKILL.md`** — replace `[YOUR_CANVAS_ID]` with your actual Slack canvas ID
- **`skills/scheduled-triggers/SKILL.md`** — replace `[YOUR_ENV_ID]` with your CCR environment ID
- **`skills/scheduled-triggers/prompt-templates.md`** — fill in `[YOUR_SLACK_USER_ID]` in the templates

## Notes

- Skills live in `~/.claude/skills/<skill-name>/SKILL.md` — Claude Code loads them on demand via the `Skill` tool
- The statusline script requires `jq` (`brew install jq`)
- `auto_rebase.sh` is designed for a multi-repo setup — edit the repo list at the top of the script
