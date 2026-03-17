---
name: rebase-on
description: Rebase all commits from a branch into current branch
argument-hint: "[branch-name]"
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git fetch:*), Bash(git rebase:*)
disable-model-invocation: true
---

## Context
- Current branch: !`git branch --show-current`
- Current git status: !`git status`

## Your task
Run the following Bash commands un a single call:
```bash
git fetch origin "$ARGUMENTS":"$ARGUMENTS" && git rebase "$ARGUMENTS" --autostash
```
