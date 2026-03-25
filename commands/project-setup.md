---
description: "One-click deploy project-context plugin scripts and SessionStart hook"
allowed-tools: ["Bash", "Read", "Write", "Edit"]
---

## Install project-context Plugin

Follow these steps to complete deployment:

### 1. Deploy Detection Scripts

Copy shell scripts from the plugin to `~/.claude/scripts/` and set executable permissions.

Script source: Find the scripts directory of this plugin in the plugin cache directory.

```bash
# Find plugin installation path
PLUGIN_DIR=$(find "$HOME/.claude/plugins/cache" -path "*/project-context/*/scripts/detect-project.sh" -exec dirname {} \; 2>/dev/null | head -1)

if [ -z "$PLUGIN_DIR" ]; then
  echo "ERROR: project-context plugin scripts directory not found"
  exit 1
fi

mkdir -p "$HOME/.claude/scripts"
cp "$PLUGIN_DIR/detect-project.sh" "$HOME/.claude/scripts/detect-project.sh"
cp "$PLUGIN_DIR/check-project-context.sh" "$HOME/.claude/scripts/check-project-context.sh"
chmod +x "$HOME/.claude/scripts/detect-project.sh"
chmod +x "$HOME/.claude/scripts/check-project-context.sh"
echo "✓ Scripts deployed to ~/.claude/scripts/"
```

### 2. Configure SessionStart Hook

Read current `~/.claude/settings.json`, check if a SessionStart hook already exists.

If no hooks field exists, add:
```json
"hooks": {
  "SessionStart": [
    {
      "hooks": [
        {
          "type": "command",
          "command": "bash $HOME/.claude/scripts/check-project-context.sh",
          "timeout": 10,
          "statusMessage": "Checking project context..."
        }
      ]
    }
  ]
}
```

If hooks field exists but no SessionStart, add the SessionStart section.
If SessionStart already exists and contains check-project-context.sh, skip (already configured).

Use Read tool to read settings.json, then use Edit tool to precisely add hook configuration.

### 3. Verify

Run detection script to verify installation:
```bash
bash ~/.claude/scripts/detect-project.sh "$(pwd)"
```

### 4. Inform the User

After installation, inform the user:
- `/project-init` — Generate CLAUDE.md for the project
- `/project-sync` — Incrementally update CLAUDE.md (supports arguments: `/project-sync project uses winston for logging`)
- `/project-review` — Review and optimize CLAUDE.md
- SessionStart hook is configured, will auto-detect and prompt when entering a project directory
