#!/bin/bash
# Claude Code status line, e.g.
#
#   app:dev   +12/-3   Opus 5   ctx 45.2k   session 12% 1h23m   week 34% 2d5h   user@example.com
#
# Every segment is optional: whatever the input JSON or the repo does not
# supply is left out, along with its separator. Reads the status JSON on stdin.
#
# Two processes beyond bash itself in the steady state: one jq pass for the
# JSON, and one git diff for the line counts. The branch is read out of
# .git/HEAD, the account email and the usage reset stamps come out of small
# cache files, and everything else is builtins, so a repaint costs the same no
# matter how many fields show. Refilling the email cache is the exception, and
# costs one more jq pass over ~/.claude.json the first repaint after a login.

DIM='\033[2m'
GREY='\033[38;5;245m'
CYAN='\033[36m'
YELLOW='\033[33m'
GREEN='\033[32m'
RED='\033[31m'
MAGENTA='\033[35m'
BLUE='\033[34m'
WHITE='\033[2;37m'
RESET='\033[0m'

SEP="   "

# What a repaint reads instead of asking the CLI's own files. Paths, not
# lookups: a helper that had to derive one would need somewhere to put it, and
# the only scratch space these helpers have is the $REPLY they answer in.
CACHE_EMAIL="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline-email"
CACHE_RESETS="${XDG_CACHE_HOME:-$HOME/.cache}/claude-statusline-resets"

# The helpers below answer in $REPLY rather than on stdout: a command
# substitution would fork a subshell per call, which is the cost this script
# is trying to avoid. None of them calls another mid-answer, which is what
# keeps that one shared name safe.

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

# The signed-in account's email, in $REPLY. The session JSON has no field for
# it, so the value comes from the file the CLI keeps it in — cached between
# logins, because that file is ~100 KB of project history the address sits at
# the end of, and it only changes when the account does.
#
# Stored credentials are what the cache is judged against: they are rewritten
# on a login, an account switch and a token refresh, and left alone by the
# unrelated writes ~/.claude.json takes on every prompt. Under API-key, Bedrock
# or Vertex auth there are no stored credentials, so the account file itself
# becomes the stamp — invalidated far more often, still correct.
account_email() {
  local creds=$HOME/.claude/.credentials.json
  [ -r "$creds" ] || creds=$HOME/.claude.json

  if [ -r "$CACHE_EMAIL" ] && [ "$CACHE_EMAIL" -nt "$creds" ]; then
    read -r REPLY <"$CACHE_EMAIL"
    return
  fi

  REPLY=$(jq -r '.oauthAccount.emailAddress // empty' "$HOME/.claude.json" 2>/dev/null)
  [ -n "$REPLY" ] || REPLY=$(git config user.email 2>/dev/null)
  printf '%s\n' "$REPLY" >"$CACHE_EMAIL" 2>/dev/null
}

# The reset stamps last recorded for account $1, in $REPLY_SESSION and
# $REPLY_WEEK, empty where nothing usable is cached.
#
# Only the stamps are ever cached, never the percentages: the same account
# spends its windows from Claude Chat, the desktop app and other machines, so a
# percentage this box last saw can understate the real figure without limit. A
# stamp cannot go stale that way — other clients spend a window, they do not
# move when it ends — so it is exact until the window elapses, which is the one
# way it does expire and is checked here. Cached stamps belong to the account
# that saw them, and are refused to any other.
load_reset_stamps() {
  local account=$1 cached_account session week
  REPLY_SESSION=""
  REPLY_WEEK=""
  [ -r "$CACHE_RESETS" ] || return
  IFS=$'\t' read -r cached_account session week <"$CACHE_RESETS"
  [ "$cached_account" = "$account" ] || return
  [[ $session =~ ^[0-9]+$ ]] && ((session > EPOCHSECONDS)) && REPLY_SESSION=$session
  [[ $week =~ ^[0-9]+$ ]] && ((week > EPOCHSECONDS)) && REPLY_WEEK=$week
}

# Records $2 and $3 as account $1's reset stamps, so the next session can show
# the countdowns on its first paint rather than waiting for an API response to
# supply them. Writes nothing when the stamps have not moved — a repaint should
# not touch the disk — and nothing at all when there is no stamp to record.
save_reset_stamps() {
  local account=$1 session=$2 week=$3 line current tmp
  # Only what load_reset_stamps would accept back is worth writing down.
  [[ $session =~ ^[0-9]+$ ]] || session=""
  [[ $week =~ ^[0-9]+$ ]] || week=""
  [ -n "$session" ] || [ -n "$week" ] || return
  line="${account}"$'\t'"${session}"$'\t'"${week}"
  if [ -r "$CACHE_RESETS" ]; then
    IFS= read -r current <"$CACHE_RESETS"
    [ "$current" = "$line" ] && return
  fi
  # Two panes can repaint at once, each with its own idea of the stamps. A
  # direct `>` write lets their bytes interleave, so the next read gets a line
  # that is neither one's — write to a private temp file and rename it in,
  # which lands whole or not at all.
  tmp="${CACHE_RESETS}.$$" &&
    printf '%s\n' "$line" >"$tmp" 2>/dev/null &&
    mv -f "$tmp" "$CACHE_RESETS" 2>/dev/null
  rm -f "$tmp" 2>/dev/null
}

# Appends one usage segment: "label NN%" in yellow, then the grey time left
# until $3, an epoch reset stamp rendered by the formatter named in $4. Either
# half may be missing; with both missing nothing is appended.
#
# The label goes with whichever half survives, never with the percentage alone —
# a first paint has the stamps and not yet the percentages, and two bare
# durations sitting on the line say nothing about which window each one ends.
add_usage_segment() {
  local label=$1 pct=$2 resets_at=$3 formatter=$4 pct_txt="" left="" sec
  if [ -n "$pct" ]; then
    printf -v pct_txt '%.0f' "$pct"
    pct_txt=" ${pct_txt}%"
  fi
  if [[ $resets_at =~ ^[0-9]+$ ]] && ((sec = resets_at - EPOCHSECONDS, sec > 0)); then
    "$formatter" "$sec"
    left=" ${GREY}${REPLY}${RESET}"
  fi
  [ -n "$pct_txt" ] || [ -n "$left" ] || return
  segments+=("${YELLOW}${label}${pct_txt}${RESET}${left}")
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
  week_resets_at: (.rate_limits.seven_day.resets_at // ""),
  email: (.account.email // .user.email // .email // "")
} | to_entries[] | "\(.key)\t\(.value)"')

git_branch "${f[cwd]}"
branch=$REPLY

segments=()

root_dir=${f[project_dir]:-${f[cwd]}}
where="${CYAN}${root_dir##*/}${RESET}"
[ -n "$branch" ] && where+="${DIM}:${RESET}${MAGENTA}${branch}${RESET}"
segments+=("$where")

# The line counts are the one field that needs git itself, and they are read
# only when a branch is showing: outside a work tree, or on a detached HEAD,
# the segment they feed is dropped anyway. They exist for nothing else, so the
# fork and the segment it pays for stay in the same place.
if [ -n "$branch" ]; then
  added=0
  removed=0
  shortstat=$(git -C "${f[cwd]}" --no-optional-locks diff HEAD --shortstat 2>/dev/null)
  [[ $shortstat =~ ([0-9]+)\ insertion ]] && added=${BASH_REMATCH[1]}
  [[ $shortstat =~ ([0-9]+)\ deletion ]] && removed=${BASH_REMATCH[1]}
  if ((added != 0)) || ((removed != 0)); then
    segments+=("${GREEN}+${added}${RESET}/${RED}-${removed}${RESET}")
  fi
fi

# Display names carry a parenthetical for variants — "Opus 5 (1M context)" —
# which is wider than the rest of the line. Keep the name, drop the aside.
[ -n "${f[model]}" ] && segments+=("${WHITE}${f[model]%% (*}${RESET}")

# The first paint of a session reports zero tokens, nothing having been sent
# yet, and "ctx 0" says less than no segment at all — so this one waits until
# there is a count worth reading.
if [[ ${f[ctx_used]} =~ ^[1-9][0-9]*$ ]]; then
  fmt_tokens "${f[ctx_used]}"
  segments+=("${BLUE}ctx ${REPLY}${RESET}")
fi

# Resolved here rather than where it is displayed, because the reset stamps
# below are cached per account and need to know which one is showing.
email=${f[email]}
if [ -z "$email" ]; then
  account_email
  email=$REPLY
fi

# The first paint of a session lands before any API response has supplied the
# rate limits, so the stamps fall back to the last pair this account was seen
# with — exact, since a window's end does not move. The percentages have no
# such fallback and appear once the response does.
session_resets_at=${f[session_resets_at]}
week_resets_at=${f[week_resets_at]}
load_reset_stamps "$email"
: "${session_resets_at:=$REPLY_SESSION}"
: "${week_resets_at:=$REPLY_WEEK}"
save_reset_stamps "$email" "$session_resets_at" "$week_resets_at"

add_usage_segment session "${f[session_pct]}" "$session_resets_at" fmt_hm
add_usage_segment week "${f[week_pct]}" "$week_resets_at" fmt_dh

[ -n "$email" ] && segments+=("${DIM}${email}${RESET}")

line=""
for segment in "${segments[@]}"; do
  line+="${line:+$SEP}${segment}"
done

printf '%b' "$line"
