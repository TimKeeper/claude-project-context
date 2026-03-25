---
description: "Incrementally update CLAUDE.md, sync project changes and team conventions"
allowed-tools: ["Bash", "Read", "Edit", "Glob", "Grep"]
argument-hint: "[Optional: describe conventions to add or issues found]"
---

## Pre-checks

1. Detect current directory type:
   !`bash ~/.claude/scripts/detect-project.sh "$(pwd)"`

2. If output is "none", inform the user that the current directory is not a valid project directory, then stop
3. If CLAUDE.md does not exist, prompt the user to run `/project-init` first, then stop
4. Read current CLAUDE.md content

## Two Update Modes

### Mode A: User specified a specific issue ($ARGUMENTS is non-empty)

User described changes or conventions to add/fix via arguments, e.g.:
- `/project-sync project uses winston for logging, not console.log`
- `/project-sync API layer migrated from REST to tRPC`
- `/project-sync added middleware directory for authentication`

Steps:
1. Understand the change or convention described by the user
2. Verify accuracy in the codebase (grep/read relevant files to confirm)
3. Determine which section of CLAUDE.md should be updated
4. Precisely update the corresponding section

### Mode B: Auto-scan for changes ($ARGUMENTS is empty)

Scan current project state, compare with CLAUDE.md descriptions, find inconsistencies.

#### Information Gathering

Git history (since CLAUDE.md was last modified):
!`git log --oneline --since="$(stat -f %Sm -t '%Y-%m-%d' CLAUDE.md 2>/dev/null || stat -c %y CLAUDE.md 2>/dev/null | cut -d' ' -f1)" HEAD 2>/dev/null || git log --oneline -20`

Current project state:
!`git diff --stat HEAD~5 HEAD 2>/dev/null`

Dependency change detection:
!`git diff HEAD~5 HEAD -- package.json go.mod Cargo.toml requirements.txt pyproject.toml pom.xml build.gradle composer.json pubspec.yaml 2>/dev/null | head -50`

#### Deep Comparison Check

Beyond git diff, actively verify each CLAUDE.md section against actual state:

1. **Tech Stack**: Read package manager files, compare documented dependencies and versions
2. **Architecture**: `ls` core directories, compare documented directory structure
3. **Development**: Read package.json scripts etc., compare documented commands
4. **Key Patterns**: Spot-check actual code patterns (e.g., import statements, error handling), compare with documented descriptions

## Update Decision Rules

| Change Type | Affected Section | Update Method |
|---------|---------|---------|
| Core dependency added/removed | Tech Stack | Update dependency list |
| Core directory added/deleted/renamed | Architecture | Update directory structure and module descriptions |
| Build/run script changes | Development | Update commands |
| Tech stack migration (e.g., JS→TS, REST→GraphQL) | Role + Tech Stack | Update role definition and tech stack |
| New important design patterns or team conventions | Key Patterns | Add pattern descriptions |
| Project description/positioning changed | Project Overview | Update description |
| Undocumented code conventions discovered | Key Patterns | Add convention records |

## Execution Principles

1. **Precise updates**: Use Edit tool to modify only affected sections, keep other parts unchanged
2. **No bloat**: Total line count should not exceed 120 after update. If adding new content, trim other outdated content
3. **Verify before writing**: Confirm all updates against actual code, never write based on assumptions
4. **Preserve customizations**: If user manually added custom content (not template-generated), keep it
5. **Monorepo-aware**: Only update the CLAUDE.md for the current CWD, do not update across sub-packages

## After Update

- Briefly summarize which sections were updated and why
- If no updates are needed, inform the user that CLAUDE.md is already up to date
