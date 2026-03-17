---
name: rebase-main
description: Rebase all commits from main branch into current branch
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git fetch:*), Bash(git rebase:*)
disable-model-invocation: true
---

## Context
- Current branch: !`git branch --show-current`
- Current git status: !`git status`

## Your task
Run the following Bash commands un a single call:
```bash
git fetch origin main:main && git rebase main --autostash
```
