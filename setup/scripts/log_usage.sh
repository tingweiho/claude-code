#!/bin/bash
# Logs daily Claude usage stats to ~/.claude/daily_usage.csv
# Reads session JSON from stdin (Stop hook)

# /opt/homebrew/bin first so bare `claude` resolves to the stable homebrew binary.
export PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/local/bin:/Applications/cmux.app/Contents/Resources/bin:$PATH"
export USER="${USER:-$(id -un)}"
export LOGNAME="${LOGNAME:-$USER}"

# Long-lived token from `claude setup-token` bypasses the macOS Keychain, which
# headless/non-login contexts can't unlock → "Not logged in".
TOKEN_FILE="$HOME/.claude/.oauth_token"
if [ -f "$TOKEN_FILE" ]; then
  export CLAUDE_CODE_OAUTH_TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"
fi

# Prevent recursion when this hook spawns a claude -p subprocess.
# Lockfile is auto-considered stale after 5 minutes (any legitimate run finishes in <30s);
# this prevents permanent breakage if a previous run crashed without cleaning up.
LOCKFILE="$HOME/.claude/.hook_running"
if [ -f "$LOCKFILE" ]; then
  LOCK_AGE_SECONDS=$(( $(date +%s) - $(stat -f %m "$LOCKFILE" 2>/dev/null || echo 0) ))
  if [ "$LOCK_AGE_SECONDS" -lt 300 ]; then
    exit 0
  fi
  # Stale — fall through and overwrite
fi
touch "$LOCKFILE"
trap "rm -f '$LOCKFILE'" EXIT INT TERM

INPUT=$(cat)
# Cap debug log at ~256KB — trim to last 128KB when it overflows so it can't grow unbounded
DEBUG_LOG="/Users/tingwei/.claude/stop_hook_debug.log"
if [ -f "$DEBUG_LOG" ] && [ "$(stat -f %z "$DEBUG_LOG" 2>/dev/null || echo 0)" -gt 262144 ]; then
  tail -c 131072 "$DEBUG_LOG" > "$DEBUG_LOG.tmp" && mv "$DEBUG_LOG.tmp" "$DEBUG_LOG"
fi
echo "$INPUT" >> "$DEBUG_LOG"

DATE=$(date '+%Y-%m-%d')
LOG="$HOME/.claude/daily_usage.csv"
STATE="$HOME/.claude/usage_state.json"

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // ""')

# Parse token usage from transcript JSONL — only new lines since last run for this session
if [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  read INPUT_TOKENS OUTPUT_TOKENS COST <<< $(python3 - "$TRANSCRIPT" "$STATE" "$SESSION_ID" <<'PYEOF'
import sys, json, os

PRICING = {
    "input":        3.00 / 1_000_000,
    "cache_write":  3.75 / 1_000_000,
    "cache_read":   0.30 / 1_000_000,
    "output":      15.00 / 1_000_000,
}

transcript_path, state_path, session_id = sys.argv[1], sys.argv[2], sys.argv[3]

# Load state: maps session_id -> lines already processed
state = {}
if os.path.exists(state_path):
    try:
        state = json.loads(open(state_path).read())
    except Exception:
        state = {}

last_line = state.get(session_id, 0)

inp = cache_w = cache_r = out = 0
line_count = 0

with open(transcript_path) as f:
    for line in f:
        line_count += 1
        if line_count <= last_line:
            continue
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except Exception:
            continue
        if obj.get("type") != "assistant":
            continue
        usage = obj.get("message", {}).get("usage", {})
        inp    += usage.get("input_tokens", 0)
        cache_w += usage.get("cache_creation_input_tokens", 0)
        cache_r += usage.get("cache_read_input_tokens", 0)
        out    += usage.get("output_tokens", 0)

# Update state with new line count
state[session_id] = line_count
with open(state_path, "w") as f:
    json.dump(state, f)

cost = (inp * PRICING["input"] +
        cache_w * PRICING["cache_write"] +
        cache_r * PRICING["cache_read"] +
        out * PRICING["output"])

print(f"{inp + cache_w + cache_r} {out} {cost:.6f}")
PYEOF
)
else
  INPUT_TOKENS=0
  OUTPUT_TOKENS=0
  COST=0
fi

# Git lines added/removed in cwd (if inside a git repo)
LINES_ADDED=0
LINES_REMOVED=0
if git -C "$PWD" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  STAT=$(git -C "$PWD" diff --shortstat HEAD 2>/dev/null)
  if [ -n "$STAT" ]; then
    LINES_ADDED=$(echo "$STAT" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo 0)
    LINES_REMOVED=$(echo "$STAT" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo 0)
    LINES_ADDED=${LINES_ADDED:-0}
    LINES_REMOVED=${LINES_REMOVED:-0}
  fi
fi

# Create CSV with header if it doesn't exist
if [ ! -f "$LOG" ]; then
  echo "date,cost_usd,input_tokens,output_tokens,lines_added,lines_removed" > "$LOG"
fi

# Check if a row for today already exists
if grep -q "^$DATE," "$LOG"; then
  # Increment existing row
  awk -F',' -v date="$DATE" \
      -v cost="$COST" \
      -v inp="$INPUT_TOKENS" \
      -v out="$OUTPUT_TOKENS" \
      -v add="$LINES_ADDED" \
      -v del="$LINES_REMOVED" \
  'BEGIN{OFS=","}
   $1==date { $2=sprintf("%.6f",$2+cost); $3=$3+inp; $4=$4+out; $5=$5+add; $6=$6+del }
   { print }' "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
else
  printf "%s,%.6f,%s,%s,%s,%s\n" "$DATE" "$COST" "$INPUT_TOKENS" "$OUTPUT_TOKENS" "$LINES_ADDED" "$LINES_REMOVED" >> "$LOG"
fi

# Session description log — updated on every stop hook fire
SESSION_LOG="$HOME/.claude/session_log.csv"
if [ ! -f "$SESSION_LOG" ]; then
  echo "date,session_id,description" > "$SESSION_LOG"
fi

if [ -n "$SESSION_ID" ] && [ -n "$TRANSCRIPT" ] && [ -f "$TRANSCRIPT" ]; then
  # Extract key messages: first user message + last 4 exchanges (user+assistant)
  CONTEXT=$(python3 - "$TRANSCRIPT" <<'PYEOF'
import sys, json

messages = []
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except Exception:
            continue
        if obj.get("type") not in ("user", "assistant"):
            continue
        content = obj.get("message", {}).get("content", "")
        text = ""
        if isinstance(content, list):
            for block in content:
                if isinstance(block, dict) and block.get("type") == "text":
                    text = block["text"].strip()
                    break
        elif isinstance(content, str):
            text = content.strip()
        if text:
            messages.append((obj["type"], text))

if not messages:
    sys.exit(0)

# First user message + last 4 messages
selected = [messages[0]] + messages[-4:] if len(messages) > 4 else messages
parts = []
for role, text in selected:
    label = "User" if role == "user" else "Claude"
    parts.append(f"{label}: {text[:200]}")

print("\n".join(parts))
PYEOF
)
  if [ -n "$CONTEXT" ]; then
    PROMPT="You are summarizing a Claude Code session for a personal session log. Based on the conversation excerpts below, write a 2-3 sentence description of what was accomplished. Be specific and concrete — mention the actual files, tools, bugs, or features involved. No intro phrases, just the description.

$CONTEXT"
    DESCRIPTION=$(claude --dangerously-skip-permissions -p "$PROMPT" 2>/dev/null | tr '"' "'" | tr '\n' ' ' | cut -c1-400)
    if [ -n "$DESCRIPTION" ]; then
      if grep -q ",$SESSION_ID," "$SESSION_LOG"; then
        # Update existing row
        awk -F',' -v sid=",$SESSION_ID," -v desc="\"$DESCRIPTION\"" \
          'index($0, sid) { $0 = substr($0, 1, index($0, sid)-1) sid desc } { print }' \
          "$SESSION_LOG" > "$SESSION_LOG.tmp" && mv "$SESSION_LOG.tmp" "$SESSION_LOG"
      else
        printf "%s,%s,\"%s\"\n" "$DATE" "$SESSION_ID" "$DESCRIPTION" >> "$SESSION_LOG"
      fi
    fi
  fi
fi
