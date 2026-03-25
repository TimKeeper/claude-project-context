#!/bin/bash
# check-project-context.sh — SessionStart hook
# 检查当前项目是否需要初始化或同步 CLAUDE.md

DETECT_SCRIPT="$HOME/.claude/scripts/detect-project.sh"

[ ! -x "$DETECT_SCRIPT" ] && exit 0

PROJECT_TYPE=$("$DETECT_SCRIPT" "$(pwd)" | head -1)

[ "$PROJECT_TYPE" = "none" ] && exit 0

if [ ! -f "CLAUDE.md" ]; then
  echo "[project-context] 当前是有效工程目录（类型: $PROJECT_TYPE）但缺少 CLAUDE.md。输入 /project-init 可生成项目上下文文档。"
  exit 0
fi

if command -v git > /dev/null 2>&1 && git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  if [ "$(uname)" = "Darwin" ]; then
    CLAUDE_MD_MTIME=$(stat -f %m CLAUDE.md 2>/dev/null || echo 0)
  else
    CLAUDE_MD_MTIME=$(stat -c %Y CLAUDE.md 2>/dev/null || echo 0)
  fi
  NOW=$(date +%s)
  CLAUDE_MD_AGE=$(( (NOW - CLAUDE_MD_MTIME) / 86400 ))

  if [ "$CLAUDE_MD_AGE" -gt 30 ]; then
    RECENT_COMMITS=$(git rev-list --count --since="30 days ago" HEAD 2>/dev/null || echo 0)
    if [ "$RECENT_COMMITS" -gt 20 ]; then
      echo "[project-context] CLAUDE.md 已 ${CLAUDE_MD_AGE} 天未更新，期间有 ${RECENT_COMMITS} 次提交。输入 /project-sync 可同步更新。"
    fi
  fi
fi
