---
name: dp-commit-push
description: Commit and push current branch
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

1. Activate venv (if exists) by running bash script, ignore all errors:
```bash
set -e
if [ -z "$VIRTUAL_ENV" ]; then
    source .venv/bin/activate 2>/dev/null || true
fi
```
2. Run bazel-deps by running bash command `make bazel-deps`
3. Create a single commit with an appropriate message derived from the staged diff shown above
4. Push the current branch to origin

Use the staged diff changes to write the commit message in call 3. Do not ask any questions or send any explanations.