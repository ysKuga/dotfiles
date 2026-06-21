#!/bin/bash
CLAUDE_DIR="$HOME/.claude"

if [ -f "$CLAUDE_DIR/.genshijin-active" ]; then
  bash "$CLAUDE_DIR/plugins/cache/genshijin/genshijin/1.4.0/hooks/genshijin-statusline.sh"
elif [ -f "$CLAUDE_DIR/.caveman-active" ]; then
  bash "$CLAUDE_DIR/plugins/cache/caveman/caveman/655b7d9c5431/src/hooks/caveman-statusline.sh"
fi
