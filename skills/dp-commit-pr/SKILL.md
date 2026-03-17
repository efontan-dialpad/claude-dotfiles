---
name: dp-commit-pr
description: Commit, push, and open a new PR
argument-hint: "[branch-name]"
allowed-tools: Bash
---

## Context

- Current branch: !`git branch --show-current`
- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`

## Your task

You have the capability to call multiple tools in a single response. You MUST do all of the above in a single message. Do not use any other tools or do anything else. Do not send any other text or messages besides these tool calls.

Based on the above changes:

1. Create a new branch if on main, named "$ARGUMENTS"
2. Activate venv (if exists) by running bash script, ignore all errors:
```bash
set -e
if [ -z "$VIRTUAL_ENV" ]; then
    source .venv/bin/activate 2>/dev/null || true
fi
```
3. Run bazel-deps by running bash command `make bazel-deps`
4. Create a single commit with an appropriate message derived from the staged diff shown above
5. Push the branch to origin
6. Create a pull request using `gh pr create`, against base branch "$ARGUMENTS"

Use the staged diff changes to write the commit message in call 4 and the PR title/body in call 6. Do not ask any questions or send any explanations.
