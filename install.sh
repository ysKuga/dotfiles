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
link "claude/commands/steering.md" "$HOME/.claude/commands/steering.md"
