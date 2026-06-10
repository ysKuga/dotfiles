# Claude Code Setup

## Files

- `claude/settings.json` — main config
- `install.sh` — symlink to `~/.claude/settings.json`

## Install

```bash
./install.sh
```

Creates: `~/.claude/settings.json -> ~/dotfiles/claude/settings.json`

## Settings

- `language`: japanese
- `theme`: dark
- `extraKnownMarketplaces`: genshijin plugin source (GitHub: `InterfaceX-co-jp/genshijin`)
- `enabledPlugins`: `genshijin@genshijin` enabled

## Plugins

### caveman

Token compression skill (~65% output reduction). Brain big. Mouth small.

Install:
```bash
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash
```

Trigger: `/caveman` or "talk like caveman". Stop: "normal mode".

Levels: `lite` / `full` (default) / `ultra` / `wenyan`

Skills:
- `/caveman [level]` — compress replies
- `/caveman-commit` — Conventional Commits, ≤50 char subject
- `/caveman-review` — one-line PR comments
- `/caveman-stats` — token usage + savings
- `/caveman-compress <file>` — compress memory files (~46% input token cut)

Source: https://github.com/juliusbrussee/caveman

---

### genshijin

Ultra-compressed communication mode. Reduce token usage ~75%. Three levels: polite / normal (default) / extreme.

Activate: `/genshijin` or say "短く" / "簡潔に"
Deactivate: "原始人やめて" / "通常モード"

Skills included:
- `genshijin-commit` — compressed commit messages (Conventional Commits)
- `genshijin-compress` — compress memory/config files
- `genshijin-review` — compressed PR review comments
- `genshijin-crew` — subagent delegation guide
- `genshijin-stats` — token usage stats

## Other Environment Setup

No `install.sh`? Copy manually:

```bash
mkdir -p ~/.claude
cp claude/settings.json ~/.claude/settings.json
```

Then install genshijin plugin inside Claude Code:

```
/install genshijin
```
