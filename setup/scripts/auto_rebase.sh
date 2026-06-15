#!/bin/bash
# auto_rebase.sh — stash, fetch, merge origin/main, stash pop for all repos
# (merge, not rebase — see merge-not-force-push rule; avoids false rebase conflicts)
# Notifies via local macOS banner + conflicts log on a real merge conflict

# /opt/homebrew/bin first so bare `claude` resolves to the stable homebrew binary.
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/local/bin:/Applications/cmux.app/Contents/Resources/bin:$HOME/.pyenv/shims:$PATH"

# USER must be exported — cron strips it, and `claude` keys its OAuth
# credential lookup on USER. Without this, claude logs "Not logged in".
export USER="${USER:-$(id -un)}"
export LOGNAME="${LOGNAME:-$USER}"

# Cap this log at ~512KB (cron appends via >>). cat-in-place trims to the last
# 256KB while keeping the same inode, so cron's open append fd stays valid.
RBLOG="$HOME/.claude/auto_rebase.log"
if [ -f "$RBLOG" ] && [ "$(stat -f%z "$RBLOG" 2>/dev/null || echo 0)" -gt 524288 ]; then
  tail -c 262144 "$RBLOG" > "$RBLOG.tmp" && cat "$RBLOG.tmp" > "$RBLOG" && /bin/rm -f "$RBLOG.tmp"
fi

# claude-code stores subscription creds only in the macOS login Keychain, which
# cron jobs outside the login session can't unlock → "Not logged in".
# A long-lived token from `claude setup-token` (saved below) bypasses the keychain.
TOKEN_FILE="$HOME/.claude/.oauth_token"
if [ -f "$TOKEN_FILE" ]; then
  export CLAUDE_CODE_OAUTH_TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"
fi

SLACK_USER="U04J1PP5GCB"
REPOS_BASE="$HOME/workspace"

CONFLICTS=()
UPDATED=()

# Discover all git repos
REPOS=()
while IFS= read -r gitdir; do
  REPOS+=("${gitdir%/.git}")
done < <(find "$REPOS_BASE" -maxdepth 5 -name ".git" -type d 2>/dev/null)

IFS=$'\n' REPOS=($(printf '%s\n' "${REPOS[@]}" | sort -u))

for REPO in "${REPOS[@]}"; do
  [ -d "$REPO/.git" ] || continue

  REPO_NAME=$(basename "$REPO")
  BRANCH=$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Determine default branch (main or master)
  MAIN=$(git -C "$REPO" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
  [ -z "$MAIN" ] && MAIN="main"

  # Skip if branch IS main (nothing to rebase onto)
  [ "$BRANCH" = "$MAIN" ] && continue

  # Fetch
  git -C "$REPO" fetch origin --quiet 2>/dev/null || continue

  # Check if behind origin/main
  BEHIND=$(git -C "$REPO" rev-list HEAD..origin/$MAIN --count 2>/dev/null || echo 0)
  [ "$BEHIND" -eq 0 ] && continue

  # Stash uncommitted changes if any
  STASHED=0
  if ! git -C "$REPO" diff --quiet 2>/dev/null || ! git -C "$REPO" diff --cached --quiet 2>/dev/null; then
    git -C "$REPO" stash push -m "auto-rebase $(date '+%Y-%m-%d %H:%M')" --quiet 2>/dev/null
    STASHED=1
  fi

  # Merge origin/main into the branch — NOT rebase. A sequential rebase conflicts
  # on add/add or overlapping commits that a single 3-way merge ('ort') resolves
  # cleanly, and merge never rewrites history so a later plain push just works
  # (matches the merge-not-force-push rule). Only flags a real, unresolvable conflict.
  if ! git -C "$REPO" merge origin/$MAIN --no-edit --quiet 2>/dev/null; then
    git -C "$REPO" merge --abort 2>/dev/null
    # Restore stash before notifying
    [ "$STASHED" -eq 1 ] && git -C "$REPO" stash pop --quiet 2>/dev/null
    CONFLICTS+=("$REPO_NAME ($BRANCH ← $MAIN): merge conflict")
    continue
  fi

  # Stash pop
  if [ "$STASHED" -eq 1 ]; then
    if ! git -C "$REPO" stash pop --quiet 2>/dev/null; then
      # Conflict on stash pop — leave it for manual resolution
      CONFLICTS+=("$REPO_NAME ($BRANCH): stash pop conflict after rebase — run 'git stash pop' manually")
      continue
    fi
  fi

  UPDATED+=("$REPO_NAME ($BRANCH +${BEHIND} from $MAIN)")
done

# Notify via Slack DM only on conflicts
# Notify locally on conflicts. Slack via `claude -p` is not usable here — the
# claude.ai Slack connector doesn't load in headless cron runs — so surface a
# macOS banner and append to a log instead. auto_rebase runs on this Mac while
# Ting-Wei is working, so a banner is immediate enough.
if [ ${#CONFLICTS[@]} -gt 0 ]; then
  CONFLICTS_LOG="$HOME/.claude/auto_rebase_conflicts.log"
  TS=$(date '+%Y-%m-%d %H:%M:%S')
  {
    echo "[$TS] auto-rebase conflicts — manual resolution needed:"
    for r in "${CONFLICTS[@]}"; do echo "  • $r"; done
    echo "---"
  } >> "$CONFLICTS_LOG"

  SUMMARY=$(printf '%s; ' "${CONFLICTS[@]}")
  /usr/bin/osascript -e "display notification \"${SUMMARY}\" with title \"⚠️ auto-rebase conflict\" subtitle \"see ~/.claude/auto_rebase_conflicts.log\" sound name \"Sosumi\"" 2>/dev/null
fi
