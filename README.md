# Claude Project Context

Smart project context management plugin for [Claude Code](https://claude.ai/code). Automatically detects project type, generates role-aware `CLAUDE.md` with tech stack analysis, and keeps documentation in sync as your project evolves.

## Features

- **Auto-detect project type** — Identifies tech stack from package.json, go.mod, Cargo.toml, requirements.txt, pom.xml, and 10+ other project markers
- **Role-aware CLAUDE.md generation** — Creates a tailored expert persona based on your project (e.g., "Senior React Frontend Expert" for a Next.js project)
- **Monorepo support** — Generates independent CLAUDE.md for each sub-package with cross-package relationship mapping
- **Smart self-checking** — Claude proactively detects undocumented conventions during collaboration and suggests updates
- **Review & optimize** — Audit existing CLAUDE.md for outdated, redundant, or conflicting instructions

## Installation

### Step 1: Add marketplace

```bash
claude plugin marketplace add TimKeeper/claude-project-context
```

### Step 2: Install plugin

```bash
claude plugin install project-context
```

### Step 3: Deploy scripts & hook

Restart Claude Code, then run:

```
/project-setup
```

This deploys the detection scripts to `~/.claude/scripts/` and configures a SessionStart hook that auto-checks whether your project needs a `CLAUDE.md`.

### Verify

Enter any project directory and type `/project-` then press Tab — you should see `project-init`, `project-sync`, and `project-review` as available commands.

## Usage

### `/project-init`

Scans your project and generates a comprehensive `CLAUDE.md` with:

- **Role** — Expert persona tailored to your tech stack
- **Project Overview** — Core functionality and business context
- **Tech Stack** — Languages, frameworks, key dependencies with versions
- **Architecture** — Directory structure, core modules, data flow
- **Development** — Build, run, test, lint commands
- **Key Patterns** — State management, routing, error handling conventions
- **Self-Check** — Instructions for Claude to detect undocumented conventions

### `/project-sync [description]`

Incrementally updates CLAUDE.md. Two modes:

```
/project-sync
```

Auto-scans for changes: dependency updates, new directories, config changes.

```
/project-sync Use winston for logging, never console.log
```

Directly adds or updates a specific convention.

### `/project-review`

Audits CLAUDE.md across 6 dimensions:

| Priority | Dimension         | Example                                           |
| -------- | ----------------- | ------------------------------------------------- |
| 🔴       | Factual staleness | Listed React 17 but project uses React 19         |
| 🔴       | Conflicts         | Both Redux and Zustand mentioned as state manager |
| 🟡       | Redundancy        | Same pattern described in two sections            |
| 🟡       | Missing info      | New core module not documented                    |
| 🟢       | Structure         | Sections out of standard order                    |
| 🟢       | Length            | Exceeds 120-line target                           |

## Supported Project Types

| Marker File                           | Tech Stack         |
| ------------------------------------- | ------------------ |
| `package.json`                        | Node.js / Frontend |
| `go.mod` / `go.work`                  | Go                 |
| `Cargo.toml`                          | Rust               |
| `requirements.txt` / `pyproject.toml` | Python             |
| `pom.xml` / `build.gradle`            | Java / Kotlin      |
| `Gemfile`                             | Ruby               |
| `composer.json`                       | PHP                |
| `*.csproj` / `*.sln`                  | .NET / C#          |
| `pubspec.yaml`                        | Flutter / Dart     |
| `CMakeLists.txt` + `src/`             | C / C++            |

### Monorepo Support

Detects workspace configurations:

- `pnpm-workspace.yaml`
- `package.json` with `workspaces`
- `lerna.json` / `nx.json` / `turbo.json`
- `go.work`
- `Cargo.toml` with `[workspace]`

## CLAUDE.md Target Length

- **Single project / sub-package**: 80–120 lines
- **Monorepo root**: 60–80 lines (focuses on overall architecture and package relationships)

## Uninstall

```bash
claude plugin uninstall project-context
claude plugin marketplace remove project-context-plugin
```

## License

MIT
