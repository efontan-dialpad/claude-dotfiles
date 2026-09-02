#!/bin/bash
# Claude Code status line
# Shows: <dir> (<git-branch>[*] [+added/-removed]) | <model> | Ctx: <used%>

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
dir_name="${cwd/#$HOME/~}"

model=$(echo "$input" | jq -r '.model.display_name')
effort=$(echo "$input" | jq -r '.effort.level // empty')

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

RESET=$'\033[0m'
ADD_COLOR=$'\033[32m'    # green
REMOVE_COLOR=$'\033[31m' # red

git_info=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
  if [ -n "$branch" ]; then
    dirty=""
    if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
      dirty="*"
    fi

    branch_color=$'\033[38;5;250m' # light grey (clean)
    if [ -n "$dirty" ]; then
      branch_color=$'\033[33m' # yellow (dirty)
    fi

    # Total lines added/removed introduced by this branch vs its base
    # (default branch), plus any uncommitted working-tree changes.
    diff_info=""
    default_branch=$(git -C "$cwd" --no-optional-locks symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [ -z "$default_branch" ]; then
      if git -C "$cwd" --no-optional-locks show-ref --verify --quiet refs/heads/main; then
        default_branch="main"
      elif git -C "$cwd" --no-optional-locks show-ref --verify --quiet refs/heads/master; then
        default_branch="master"
      fi
    fi

    added=0
    removed=0
    if [ -n "$default_branch" ] && [ "$branch" != "$default_branch" ]; then
      merge_base=$(git -C "$cwd" --no-optional-locks merge-base "$default_branch" HEAD 2>/dev/null)
    else
      merge_base="HEAD"
    fi
    if [ -n "$merge_base" ]; then
      # diff against merge_base compares it to the working tree directly,
      # so this already includes both committed and uncommitted changes.
      numstat=$(git -C "$cwd" --no-optional-locks diff --numstat "$merge_base" 2>/dev/null)
      while IFS=$'\t' read -r add rem _path; do
        [ "$add" = "-" ] && add=0
        [ "$rem" = "-" ] && rem=0
        case "$add" in ''|*[!0-9]*) add=0;; esac
        case "$rem" in ''|*[!0-9]*) rem=0;; esac
        added=$((added + add))
        removed=$((removed + rem))
      done <<< "$numstat"
    fi
    if [ "$added" -gt 0 ] || [ "$removed" -gt 0 ]; then
      diff_info=" ${ADD_COLOR}+${added}${RESET}${branch_color}/${REMOVE_COLOR}-${removed}${RESET}${branch_color}"
    fi

    git_info=" (${branch}${dirty}${diff_info})"
  fi
fi

context_info=""
context_sep=""
ctx_color=$'\033[32m' # green
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  context_info=$(printf "Ctx: %.0f%%" "$used_pct")
  context_sep=" | "
  ctx_int=$(printf "%.0f" "$used_pct")
  if [ "$ctx_int" -ge 80 ]; then
    ctx_color=$'\033[31m' # red
  elif [ "$ctx_int" -ge 50 ]; then
    ctx_color=$'\033[33m' # yellow
  fi
fi

DIR_COLOR=$'\033[36m'   # cyan
MODEL_COLOR=$'\033[35m' # magenta
SEP_COLOR=$'\033[2m'    # dim separator

effort_info=""
if [ -n "$effort" ] && [ "$effort" != "null" ]; then
  effort_info=" ${SEP_COLOR}(${effort})${RESET}"
fi

printf "${DIR_COLOR}%s${RESET}${branch_color}%s${RESET}${SEP_COLOR} | ${RESET}${MODEL_COLOR}%s${RESET}%s${SEP_COLOR}%s${RESET}${ctx_color}%s${RESET}" "$dir_name" "$git_info" "$model" "$effort_info" "$context_sep" "$context_info"
