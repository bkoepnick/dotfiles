#!/bin/bash
input=$(cat)

COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

# Absolute token usage
INPUT_TOK=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
WIN_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
USED_TOK=$((INPUT_TOK + CACHE_CREATE + CACHE_READ))

fmt_tokens() {
  local n=$1
  if [ "$n" -ge 1000000 ]; then
    local whole=$((n / 1000000))
    local frac=$(((n % 1000000) / 100000))
    if [ "$frac" -eq 0 ]; then echo "${whole}M"
    else echo "${whole}.${frac}M"
    fi
  elif [ "$n" -ge 1000 ]; then echo "$((n / 1000))k"
  else echo "$n"
  fi
}
TOK_FMT="$(fmt_tokens "$USED_TOK")/$(fmt_tokens "$WIN_SIZE")"

# Cache hit rate on last API call
CACHE_DENOM=$((CACHE_READ + CACHE_CREATE + INPUT_TOK))
CACHE_PCT=0
if [ "$CACHE_DENOM" -gt 0 ]; then
  CACHE_PCT=$((100 * CACHE_READ / CACHE_DENOM))
fi

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

# Cache color: high read fraction is good (green); low is bad (red)
if [ "$CACHE_PCT" -ge 80 ]; then CACHE_COLOR="$GREEN"
elif [ "$CACHE_PCT" -ge 50 ]; then CACHE_COLOR="$YELLOW"
else CACHE_COLOR="$RED"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

MINS=$((DURATION_MS / 60000)); SECS=$(((DURATION_MS % 60000) / 1000))

BRANCH=""
git rev-parse --git-dir > /dev/null 2>&1 && BRANCH="$(git branch --show-current 2>/dev/null)"

COST_FMT=$(printf '$%.2f' "$COST")

# Time since last Stop (proxy for prompt-cache age — TTL resets on each API call)
SINCE=""
LAST_STOP_FILE="$HOME/.claude/.last_stop_timestamp"
if [ -f "$LAST_STOP_FILE" ]; then
  LAST=$(cat "$LAST_STOP_FILE")
  NOW=$(date +%s)
  ELAPSED=$((NOW - LAST))
  E_MINS=$((ELAPSED / 60))
  E_SECS=$((ELAPSED % 60))
  if [ "$ELAPSED" -ge 3600 ]; then SINCE_COLOR="$RED"
  elif [ "$ELAPSED" -ge 300 ]; then SINCE_COLOR="$YELLOW"
  else SINCE_COLOR="$GREEN"; fi
  SINCE=" | ${SINCE_COLOR}↻ ${E_MINS}m${E_SECS}s${RESET}"
fi

echo -e "$BRANCH | ${BAR_COLOR}${BAR}${RESET} ${PCT}% (${TOK_FMT}) | ${YELLOW}${COST_FMT}${RESET} | ${CACHE_COLOR}cache ${CACHE_PCT}%${RESET} | ⏱️ ${MINS}m ${SECS}s${SINCE}"
