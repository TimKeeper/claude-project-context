---
description: "Initialize project context document, generate project-level CLAUDE.md for Claude"
allowed-tools: ["Bash", "Read", "Write", "Edit", "Glob", "Grep", "Agent"]
---

## Pre-checks

1. Run detection script to determine current directory type:
   !`bash ~/.claude/scripts/detect-project.sh "$(pwd)"`

2. If output is "none", inform the user that **the current directory is not a valid project directory, no need to generate CLAUDE.md**, then stop
3. If CLAUDE.md already exists, ask the user whether to regenerate (overwrite)
4. Record the first line as directory type (single / monorepo-root / monorepo-pkg), subsequent lines are monorepo sub-package paths

## Scan Strategy

Use Glob, Grep, Read tools to scan the following (do not use Agent, scan directly):

### Required Scans
- **Package manager files** (package.json / go.mod / Cargo.toml / requirements.txt / pyproject.toml / pom.xml / build.gradle etc.) → Extract project name, version, tech stack, dependency list, script commands
- **Directory structure**: `ls` to list first and second level directories, identify core directories (src/, lib/, app/, pages/, components/, services/ etc.)
- **README.md** (if exists) → Extract project description

### Optional Scans
- **Config files** (tsconfig.json, .eslintrc*, vite.config*, webpack.config*, next.config*, docker-compose*, .env.example etc.) → Extract build tools, code style configuration
- **CI/CD** (.github/workflows/, Jenkinsfile, .gitlab-ci.yml etc.) → Extract deployment workflow
- **Entry files** (src/index.*, src/main.*, src/app.*, cmd/main.go etc.) → Understand application startup

## Generation Rules

### Target Length
- Standalone project / monorepo sub-package: **80-120 lines**
- Monorepo root: **60-80 lines** (focus on overall architecture, don't dive into sub-package details)

### Language Requirements
- Section headings in English
- Content generated based on user's language environment (e.g., Chinese content for Chinese-speaking users, English for English-speaking users)
- Code and commands stay in English
- Language detection based on: user's system locale, existing CLAUDE.md content language, or language used in conversation

### Standalone / Monorepo Sub-package — CLAUDE.md Template

```markdown
# Role

[Generate role description based on user's language. Example (Chinese): "你是一位资深的前端开发专家，精通 React + TypeScript..."; Example (English): "You are a senior frontend expert, proficient in React + TypeScript..."]

# Project Overview

[Describe core features, business scenarios, and target users based on user's language. Extract from README and package.json description, infer from code structure if unavailable]

# Tech Stack

- **Language**: TypeScript 5.x
- **Framework**: React 18 + Next.js 14
- **State Management**: Zustand
- **Styling**: Tailwind CSS + shadcn/ui
- **Build**: Vite / Turbopack
- **Testing**: Vitest + Testing Library
- **Lint**: ESLint + Prettier

# Architecture

## Directory Structure
- `src/app/` — Next.js App Router pages
- `src/components/` — Reusable UI components
- `src/lib/` — Utility functions and business logic
- `src/hooks/` — Custom React Hooks
- `src/services/` — API call layer
- `src/types/` — TypeScript type definitions

## Core Modules
- **Auth** (`src/lib/auth/`) — User login and permission verification
- **Data Layer** (`src/services/`) — REST/GraphQL request wrapper
- [Fill based on actual project]

## Data Flow
[Describe data flow based on user's language, e.g., "User action → Component → Hook → Service → API → Store update → UI re-render"]

# Development

- **Install**: `npm install` / `pnpm install`
- **Dev**: `npm run dev`
- **Build**: `npm run build`
- **Test**: `npm run test`
- **Lint**: `npm run lint`
- **Format**: `npm run format`

# Key Patterns

- **API Calls**: [fetch/axios/tRPC] + [SWR/React Query]
- **Routing**: [File-system routing / react-router / custom]
- **Error Handling**: [Error Boundary / try-catch / global interceptor]
- **Env Variables**: managed via `.env.local`, prefixed with `NEXT_PUBLIC_`

# Self-Check

[Generate in user's language. Key points:]
- Undocumented team conventions found in code (e.g., logging library, error handling, naming style)
- Patterns described here don't match actual code (e.g., doc says Redux but code uses Zustand)
- New core dependencies introduced or module structure refactored
- Recurring review comments suggest undocumented conventions
```

### Monorepo Root — CLAUDE.md Template

```markdown
# Role

[Generate role description based on user's language. Example (Chinese): "你是一位资深的全栈开发专家，负责维护本 monorepo 工程..."; Example (English): "You are a senior full-stack expert, responsible for maintaining this monorepo..."]

# Project Overview

[Describe based on user's language]

# Monorepo Structure

| Package | Path | Tech Stack | Description |
|---------|------|------------|-------------|
| web | packages/web | React/TypeScript | Frontend web app |
| api | packages/api | Node.js/Express | Backend API service |
| shared | packages/shared | TypeScript | Shared types and utilities |

# Package Manager & Tooling

- **Package Manager**: pnpm workspace / npm workspaces / yarn workspaces
- **Build Orchestration**: Turborepo / Nx / Lerna
- **Versioning**: Changesets / Lerna

# Shared Conventions

- **Code Style**: Root-level ESLint + Prettier config, inherited by sub-packages
- **Commit Convention**: Conventional Commits
- **CI/CD**: [brief description]

# Development

- **Install All**: `pnpm install`
- **Dev All**: `pnpm dev`
- **Build All**: `pnpm build`
- **Run Single Package**: `pnpm --filter <package-name> dev`

# Self-Check

[Generate in user's language. Key points:]
- Undocumented team conventions found in code
- Patterns described here don't match actual code
- New core dependencies introduced or module structure refactored
- Recurring review comments suggest undocumented conventions
```

## Execution Flow

### Standalone / Monorepo Sub-package
1. Collect information using the scan strategy above
2. Select the most appropriate role definition based on detected tech stack
3. Fill in each template section, remove inapplicable parts
4. Write to CLAUDE.md using the Write tool
5. Verify line count is within 80-120 lines, trim descriptive text if exceeded

### Monorepo Root
1. Generate root-level CLAUDE.md first
2. Check sub-package paths from detection script output, verify each for missing CLAUDE.md
3. For each valid sub-package missing CLAUDE.md, enter that directory, scan, and generate an independent CLAUDE.md
4. Inform the user which files were generated

## Role Definition Mapping

Auto-infer role based on detected tech stack:

| Primary Tech | Role Description (generated in user's language) |
|---------|---------|
| React/Vue/Angular/Svelte + HTML/CSS/JS | Senior Frontend Expert |
| Node.js/Express/Koa/NestJS/Fastify | Senior Node.js Backend Expert |
| Go/Gin/Echo | Senior Go Backend Expert |
| Rust/Actix/Axum | Senior Rust Systems Expert |
| Python/Django/Flask/FastAPI | Senior Python Expert |
| Java/Spring/Kotlin | Senior Java/Kotlin Backend Expert |
| React Native/Flutter | Senior Mobile Expert |
| Terraform/Kubernetes/Docker | Senior DevOps/Cloud-Native Expert |
| Frontend + Backend mixed | Senior Full-Stack Expert |
| PyTorch/TensorFlow/ML related | Senior AI/ML Expert |

If multiple tech stacks are detected and cannot be categorized, use "Senior Full-Stack Expert".

## Notes

- Do not list all dependencies, only list core ones (top 10-15 most important)
- Directory structure should only list core directories (typically 6-10), not every subdirectory
- If README already has a good description, reference it directly instead of rewriting
- After generation, prompt the user to verify accuracy and fine-tune manually if needed
