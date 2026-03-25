#!/bin/bash
# detect-project.sh — 检测目录是否为有效工程目录及其类型
# 用法: detect-project.sh [目录路径]
# 输出:
#   第一行: "none" | "single" | "monorepo-root" | "monorepo-pkg"
#   monorepo-root 时后续行输出子包绝对路径

DIR="${1:-.}"
DIR="$(cd "$DIR" 2>/dev/null && pwd)" || { echo "none"; exit 0; }

if [ "$DIR" = "$HOME" ] || [ "$DIR" = "/" ] || [ "$DIR" = "/tmp" ]; then
  echo "none"
  exit 0
fi

has_project_marker() {
  local d="$1"
  [ -f "$d/package.json" ] || [ -f "$d/go.mod" ] || [ -f "$d/Cargo.toml" ] || \
  [ -f "$d/requirements.txt" ] || [ -f "$d/pyproject.toml" ] || [ -f "$d/setup.py" ] || \
  [ -f "$d/pom.xml" ] || [ -f "$d/build.gradle" ] || [ -f "$d/build.gradle.kts" ] || \
  [ -f "$d/Gemfile" ] || [ -f "$d/composer.json" ] || [ -f "$d/pubspec.yaml" ] || \
  compgen -G "$d/*.csproj" > /dev/null 2>&1 || \
  compgen -G "$d/*.sln" > /dev/null 2>&1 || \
  { [ -f "$d/CMakeLists.txt" ] && [ -d "$d/src" ]; } || \
  { [ -f "$d/Makefile" ] && [ -d "$d/src" ]; }
}

is_monorepo_root() {
  local d="$1"
  [ -f "$d/pnpm-workspace.yaml" ] && return 0
  [ -f "$d/lerna.json" ] && return 0
  [ -f "$d/nx.json" ] && return 0
  [ -f "$d/turbo.json" ] && return 0
  [ -f "$d/package.json" ] && grep -q '"workspaces"' "$d/package.json" 2>/dev/null && return 0
  [ -f "$d/go.work" ] && return 0
  [ -f "$d/Cargo.toml" ] && grep -q '\[workspace\]' "$d/Cargo.toml" 2>/dev/null && return 0
  return 1
}

list_monorepo_packages() {
  local d="$1"

  if [ -f "$d/pnpm-workspace.yaml" ]; then
    grep -E "^\s*-\s*" "$d/pnpm-workspace.yaml" 2>/dev/null | sed 's/.*-[[:space:]]*//' | tr -d "'" | tr -d '"' | while IFS= read -r pattern; do
      pattern=$(echo "$pattern" | xargs)
      [ -z "$pattern" ] && continue
      for match in $d/$pattern; do
        [ -d "$match" ] && has_project_marker "$match" && echo "$match"
      done
    done
    return
  fi

  if [ -f "$d/package.json" ] && grep -q '"workspaces"' "$d/package.json" 2>/dev/null; then
    if command -v node > /dev/null 2>&1; then
      node -e "
        try {
          const pkg = require('$d/package.json');
          let ws = pkg.workspaces;
          if (ws && !Array.isArray(ws)) ws = ws.packages || [];
          if (Array.isArray(ws)) ws.forEach(p => console.log(p));
        } catch(e) {}
      " 2>/dev/null | while IFS= read -r pattern; do
        [ -z "$pattern" ] && continue
        for match in $d/$pattern; do
          [ -d "$match" ] && has_project_marker "$match" && echo "$match"
        done
      done
    fi
    return
  fi

  if [ -f "$d/go.work" ]; then
    grep -E "^\s+\." "$d/go.work" 2>/dev/null | while IFS= read -r mod_path; do
      mod_path=$(echo "$mod_path" | xargs)
      local full="$d/$mod_path"
      [ -d "$full" ] && has_project_marker "$full" && echo "$full"
    done
    return
  fi

  if [ -f "$d/Cargo.toml" ] && grep -q '\[workspace\]' "$d/Cargo.toml" 2>/dev/null; then
    grep -A 100 '^\[workspace\]' "$d/Cargo.toml" 2>/dev/null | grep -E '^\s*"' | tr -d '", ' | while IFS= read -r member; do
      [ -z "$member" ] && continue
      for match in $d/$member; do
        [ -d "$match" ] && has_project_marker "$match" && echo "$match"
      done
    done
    return
  fi
}

if ! has_project_marker "$DIR"; then
  echo "none"
  exit 0
fi

if is_monorepo_root "$DIR"; then
  echo "monorepo-root"
  list_monorepo_packages "$DIR"
  exit 0
fi

PARENT="$DIR"
while true; do
  PARENT=$(dirname "$PARENT")
  if is_monorepo_root "$PARENT"; then
    echo "monorepo-pkg"
    exit 0
  fi
  [ "$PARENT" = "/" ] && break
done

echo "single"
