---
description: "Review and optimize CLAUDE.md, clean up outdated, redundant or conflicting content"
allowed-tools: ["Bash", "Read", "Edit", "Glob", "Grep"]
---

## Pre-checks

1. Confirm CLAUDE.md exists in the current directory; if not, prompt the user to run `/project-init` first
2. Read the full content of current CLAUDE.md
3. Record current line count

## Review Dimensions

Check the following issues one by one, marking each with severity level:

### 1. Factual Staleness (must fix)

Compare CLAUDE.md declarations against actual project state:
- **Tech stack versions**: Check actual versions in package.json / go.mod etc., verify consistency with documentation
- **Dependency list**: Check if documented dependencies still exist, check for missing new core dependencies
- **Directory structure**: Check if documented directories still exist, check for unrecorded new core directories
- **Development commands**: Check if documented script commands match actual scripts in package.json etc.
- **Role definition**: Check if tech stack described in Role matches actual tech stack

### 2. Content Conflicts (must fix)

- Check if the same concept has contradictory descriptions across different sections
- Check if old and new patterns coexist (e.g., both Redux and Zustand mentioned as state management)
- Check if convention rules have logical conflicts

### 3. Redundant Content (recommended fix)

- Check for paragraphs that describe the same thing repeatedly
- Check for information directly inferable from code (doesn't need to be in CLAUDE.md)
- Check for overly verbose descriptions that can be condensed

### 4. Missing Information (recommended fix)

- Check if important architectural decisions are undocumented
- Check if key development conventions are missing
- For monorepos, check if inter-package dependency relationships are missing

### 5. Structure and Readability (optional fix)

- Check if section organization is reasonable
- Check compliance with standard template structure (Role / Project Overview / Tech Stack / Architecture / Development / Key Patterns)
- Check format consistency (heading levels, list styles, code block annotations)

### 6. Length Control (optional fix)

- Check if current line count exceeds the 120-line limit
- Check for low-value content that can be trimmed

## Execution Flow

1. **Scan actual project state**:
   - Read package manager files to get actual dependencies and scripts
   - `ls` core directory structure
   - Check if key configuration files exist

2. **Compare and review item by item**: Check against all 6 dimensions above

3. **Generate review report**:
   - List all issues found, sorted by severity
   - Provide specific fix suggestions for each issue
   - Summary: x must-fix / x recommended / x optional

4. **Ask the user**: After presenting the report, ask the user:
   - "Fix all" — automatically apply all suggestions
   - "Fix critical only" — only fix must-fix items
   - "Confirm each" — ask for approval on each item
   - "View report only" — make no changes

5. **Apply changes**: Based on user selection, use Edit tool to precisely modify CLAUDE.md

6. **Post-change verification**:
   - Confirm line count is within 80-120 lines after changes
   - Confirm no new conflicts were introduced
   - Output before/after line count comparison and change summary
