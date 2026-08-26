#!/bin/bash
# Claude Code status line, e.g.
#
#   app:dev   +12/-3   Opus 5   ctx 45.2k   session 12% 1h23m   week 34% 2d5h
#
# Every segment is optional: whatever the input JSON or the repo does not
# supply is left out, along with its separator. Reads the status JSON on stdin.
#
# Two processes beyond bash itself: one jq pass for the JSON, and one git diff
# for the line counts. The branch is read out of .git/HEAD and everything else
# is builtins, so a repaint costs the same no matter how many fields show.

DIM='\033[2m'
CYAN='\033[2;36m'
YELLOW='\033[2;33m'
GREEN='\033[2;32m'
RED='\033[2;31m'
MAGENTA='\033[2;35m'
BLUE='\033[2;34m'
WHITE='\033[2;37m'
RESET='\033[0m'

SEP="   "

# The helpers below answer in $REPLY rather than on stdout: a command
# substitution would fork a subshell per call, which is the cost this script
# is trying to avoid.

# Token count, ccstatusline-style: 45231 -> "45.2k", 46000 -> "46k",
# 999 -> "999". Integer math, rounding half up.
fmt_tokens() {
  local n=$1 tenths
  if ((n < 1000)); then
    REPLY=$n
    return
  fi
  tenths=$(((n + 50) / 100))
  if ((tenths % 10 == 0)); then
    REPLY="$((tenths / 10))k"
  else
    REPLY="$((tenths / 10)).$((tenths % 10))k"
  fi
}

# Seconds as hours+minutes, e.g. "1h23m" or "45m". For the 5-hour window.
fmt_hm() {
  local h=$(($1 / 3600)) m=$((($1 % 3600) / 60))
  if ((h > 0)); then REPLY="${h}h${m}m"; else REPLY="${m}m"; fi
}

# Seconds as days+hours, e.g. "2d5h", falling back to "5h" under a day and
# "~45m" under an hour. For the 7-day window.
fmt_dh() {
  local d=$(($1 / 86400)) h=$((($1 % 86400) / 3600)) m=$((($1 % 3600) / 60))
  if ((d >= 1)); then REPLY="${d}d${h}h"
  elif ((h >= 1)); then REPLY="${h}h"
  else REPLY="~${m}m"; fi
}

# Locates the git directory for $1 by walking up, no fork. A linked worktree
# or a submodule leaves a .git file holding "gitdir: <path>" instead.
git_dir() {
  local dir=$1 _key path
  REPLY=""
  [ -d "$dir" ] || return
  while [ -n "$dir" ]; do
    if [ -d "$dir/.git" ]; then
      REPLY="$dir/.git"
      return
    fi
    if [ -f "$dir/.git" ]; then
      read -r _key path <"$dir/.git"
      case $path in
        /*) REPLY=$path ;;
        *) REPLY="$dir/$path" ;;
      esac
      return
    fi
    dir=${dir%/*}
  done
}

# Branch checked out in the work tree at $1, empty when there is no repo or
# HEAD is detached — what git branch --show-current reports, without the fork.
git_branch() {
  local head
  git_dir "$1"
  [ -n "$REPLY" ] && [ -r "$REPLY/HEAD" ] || { REPLY=""; return; }
  read -r head <"$REPLY/HEAD"
  REPLY=""
  [[ $head == ref:*refs/heads/* ]] && REPLY=${head##*refs/heads/}
}

# Appends one usage segment: "label NN%" in yellow, then the dim time left
# until $3, an epoch reset stamp rendered by the formatter named in $4. Either
# half may be missing; with both missing nothing is appended.
add_usage_segment() {
  local label=$1 pct=$2 resets_at=$3 formatter=$4 segment="" pct_txt sec
  if [ -n "$pct" ]; then
    printf -v pct_txt '%.0f' "$pct"
    segment="${YELLOW}${label} ${pct_txt}%${RESET}"
  fi
  if [ -n "$resets_at" ] && ((sec = resets_at - EPOCHSECONDS, sec > 0)); then
    "$formatter" "$sec"
    segment="${segment:+$segment }${DIM}${REPLY}${RESET}"
  fi
  [ -n "$segment" ] && segments+=("$segment")
}

# One jq pass over stdin for every field read, as name/value lines. Adding a
# field means adding it here and reading f[name] below — nothing is positional.
declare -A f
while IFS=$'\t' read -r key value; do
  f[$key]=$value
done < <(jq -r '{
  cwd: (.workspace.current_dir // .cwd),
  project_dir: (.workspace.project_dir // ""),
  model: (.model.display_name // ""),
  ctx_used: (.context_window.total_input_tokens // ""),
  session_pct: (.rate_limits.five_hour.used_percentage // ""),
  session_resets_at: (.rate_limits.five_hour.resets_at // ""),
  week_pct: (.rate_limits.seven_day.used_percentage // ""),
  week_resets_at: (.rate_limits.seven_day.resets_at // "")
} | to_entries[] | "\(.key)\t\(.value)"')

git_branch "${f[cwd]}"
branch=$REPLY

# Only the line counts need git itself, and only when a branch is showing —
# outside a work tree, or on a detached HEAD, the segment is dropped anyway.
added=0
removed=0
if [ -n "$branch" ]; then
  shortstat=$(git -C "${f[cwd]}" --no-optional-locks diff HEAD --shortstat 2>/dev/null)
  [[ $shortstat =~ ([0-9]+)\ insertion ]] && added=${BASH_REMATCH[1]}
  [[ $shortstat =~ ([0-9]+)\ deletion ]] && removed=${BASH_REMATCH[1]}
fi

root_dir=${f[project_dir]:-${f[cwd]}}
where="${CYAN}${root_dir##*/}${RESET}"
[ -n "$branch" ] && where+="${DIM}:${RESET}${MAGENTA}${branch}${RESET}"
segments=("$where")

if [ -n "$branch" ] && { ((added != 0)) || ((removed != 0)); }; then
  segments+=("${GREEN}+${added}${RESET}/${RED}-${removed}${RESET}")
fi

# Display names carry a parenthetical for variants — "Opus 5 (1M context)" —
# which is wider than the rest of the line. Keep the name, drop the aside.
[ -n "${f[model]}" ] && segments+=("${WHITE}${f[model]%% (*}${RESET}")

if [ -n "${f[ctx_used]}" ]; then
  fmt_tokens "${f[ctx_used]}"
  segments+=("${BLUE}ctx ${REPLY}${RESET}")
fi

add_usage_segment session "${f[session_pct]}" "${f[session_resets_at]}" fmt_hm
add_usage_segment week "${f[week_pct]}" "${f[week_resets_at]}" fmt_dh

line=""
for segment in "${segments[@]}"; do
  line+="${line:+$SEP}${segment}"
done

printf '%b' "$line"
