# dotfiles

Claude Code のユーザー設定を管理するリポジトリ。`install.sh` が `claude/` 配下のファイルを `~/.claude/` へシンボリックリンクする。

## 構造

- `claude/` — `~/.claude/` へ symlink される実体（settings.json, CLAUDE.md, rules, commands, hooks）。実際の `~/.claude/` を直接編集せず、必ずこちら側を編集する。
- `install.sh` — symlink 作成スクリプト。新しいファイルを追加したら必ずここにも `link` 行を追加する。
- `claude/notes/setup.md` — plugins・MCP・uv/graphify など、symlink だけでは完結しないセットアップ手順のドキュメント。

## 新しい環境への適用手順

1. `./install.sh` を実行（symlink作成のみ、追加ツールのインストールは含まれない）
2. `claude/notes/setup.md` を参照して以下を個別に実施:
   - Atlassian MCP: `claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp/authv2 -s user`
   - uv: `curl -LsSf https://astral.sh/uv/install.sh | sh`
   - graphify: `uv tool install graphifyy`
   - genshijin/caveman プラグイン: `settings.json` に `enabledPlugins`/`extraKnownMarketplaces` を書くだけでは自動解決されないため、`claude plugin marketplace add <repo>` → `claude plugin install <name>@<name>` を明示的に実行する

## 注意

- `.gitignore` で `claude/mcp/*/` と `tmp/` は除外されている
- `claude/.steering/` は各機能追加時の設計メモ（`/steering` コマンドで生成）
