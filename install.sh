#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

link() {
  local src="$DOTFILES/$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst"
  echo "linked: $dst -> $src"
}

link "claude/settings.json" "$HOME/.claude/settings.json"
link "claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "claude/rules/karpathy-guidelines.md" "$HOME/.claude/rules/karpathy-guidelines.md"
link "claude/commands/jira.md" "$HOME/.claude/commands/jira.md"
link "claude/commands/steering.md" "$HOME/.claude/commands/steering.md"
link "claude/hooks/statusline.sh" "$HOME/.claude/hooks/statusline.sh"
link "claude/hooks/audit-repo.sh" "$HOME/.claude/hooks/audit-repo.sh"
link "claude/commands/audit-repo.md" "$HOME/.claude/commands/audit-repo.md"
