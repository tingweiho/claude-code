#!/usr/bin/env bash
# Claude Code status line script
# Produces two rows matching the requested layout

input=$(cat)

# ── Model ────────────────────────────────────────────────────────────────────
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# ── Team (output style / session name) ───────────────────────────────────────
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
session_name=$(echo "$input" | jq -r '.session_name // empty')
team=""
[ -n "$output_style" ] && [ "$output_style" != "default" ] && team="$output_style"
[ -z "$team" ] && [ -n "$session_name" ] && team="$session_name"

# ── Context window ────────────────────────────────────────────────────────────
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")

  filled=$(( used_int / 10 ))
  empty_blocks=$(( 10 - filled ))

  # Color: green < 60%, yellow < 80%, orange < 95%, red >= 95%
  if [ "$used_int" -lt 60 ]; then
    bar_color="\033[32m"         # green
    icon="✓"; label="ok"
  elif [ "$used_int" -lt 80 ]; then
    bar_color="\033[33m"         # yellow
    icon="⚠"; label="/compact soon"
  elif [ "$used_int" -lt 95 ]; then
    bar_color="\033[38;5;208m"   # orange
    icon="⚠"; label="run /compact"
  else
    bar_color="\033[31m"         # red
    icon="✗"; label="/compact now!"
  fi
  reset="\033[0m"

  bar=""
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  for ((i=0; i<empty_blocks; i++)); do bar="${bar}░"; done

  context_part=$(printf "${bar_color}%s${reset} %d%%  %s %s" "$bar" "$used_int" "$icon" "$label")
else
  context_part="no context data"
fi

# ── Time (mirrors Powerlevel9k 'time' right-prompt element) ───────────────────
current_time=$(date +%H:%M:%S)

# ── Row 1 ─────────────────────────────────────────────────────────────────────
if [ -n "$team" ]; then
  row1="🧋🐰 | ${team} | ${model} | ${context_part} | ${current_time}"
else
  row1="🧋🐰 | ${model} | ${context_part} | ${current_time}"
fi

printf "%b\n" "$row1"

# ── Directory (mirrors Powerlevel9k 'dir' left-prompt element) ────────────────
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // ""')
dir_display=""
if [ -n "$cwd" ]; then
  # Collapse $HOME to ~
  dir_display="${cwd/#$HOME/~}"
fi

# ── Git branch & diff stats (mirrors Powerlevel9k 'vcs' element) ──────────────
git_info=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  # Repo name = basename of the top-level git directory
  repo_root=$(git -C "$cwd" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
  repo_name=$(basename "$repo_root")

  # Check for uncommitted changes
  if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null \
     || ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null; then
    branch="${branch}*"
  fi

  # Lines added / removed vs HEAD (staged + unstaged)
  diff_stat=$(git -C "$cwd" --no-optional-locks diff HEAD --numstat 2>/dev/null)
  if [ -n "$diff_stat" ]; then
    added=$(echo "$diff_stat" | awk '{a+=$1} END{print a+0}')
    removed=$(echo "$diff_stat" | awk '{r+=$2} END{print r+0}')
    diff_part="+${added}/-${removed}"
  else
    diff_part=""
  fi

  git_info="${repo_name} | ${branch}"
  [ -n "$diff_part" ] && git_info="${git_info} | ${diff_part}"
fi

# ── Agent name ────────────────────────────────────────────────────────────────
agent_name=$(echo "$input" | jq -r '.agent.name // empty')

# ── Row 2: dir | git | agent (left-prompt style) ──────────────────────────────
row2=""
[ -n "$dir_display" ] && row2="${dir_display}"
[ -n "$git_info" ]    && { [ -n "$row2" ] && row2="${row2} | ${git_info}" || row2="${git_info}"; }
[ -n "$agent_name" ]  && { [ -n "$row2" ] && row2="${row2} | ${agent_name}" || row2="${agent_name}"; }

[ -n "$row2" ] && printf "%s\n" "$row2"
