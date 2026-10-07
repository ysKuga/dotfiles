# dotfiles

WSL (Ubuntu) 環境と Claude Code の設定を管理するリポジトリ。

## セットアップ

Ubuntu インストール直後に以下を実行する。sudo は不要。

```sh
curl https://mise.run | sh
~/.local/bin/mise run setup
exec bash
```

`mise run setup` は以下のタスクを順に実行する（`mise.toml`）。何度実行してもよい。

1. `install` — 設定ファイルの symlink（`~/.claude/`, `~/.config/git/config`, `~/.config/mise/config.toml`, `~/.bashrc.d/`）
2. `tools` — [mise/global.toml](mise/global.toml) のツール（Claude Code, gh, fzf, eza, bat, node）をインストール
3. `gh-auth` — GitHub CLI 認証（未認証時のみブラウザ認証）

タスク一覧は `mise tasks`（または `make help`）。VSCode は `code .` 実行時に自動でインストールされるため作業不要。

### node

`.nvmrc` / `.node-version` のあるディレクトリでは自動でそのバージョンに切り替わる。未インストールのバージョンは警告が出るため、そのディレクトリで `mise install` を実行する。

## その他

- Claude Code のプラグイン・MCP など: [claude/notes/setup.md](claude/notes/setup.md)
- 各種ツールのインストール候補: [setup/tools.md](setup/tools.md)
