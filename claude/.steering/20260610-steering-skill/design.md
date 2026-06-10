# steering-skill

## 目的

複雑な作業開始時に `claude/.steering/YYYYMMDD-[title]/` を作成し、設計・計画を一元管理する仕組みを dotfiles に追加する。

## 背景・制約

- Claude Code の skill は `~/.claude/commands/*.md` に配置
- dotfiles で管理 → `install.sh` でシンボリックリンク
- `jira.md` が既存 skill として同じ構成で存在

## 実装計画

- [x] `claude/commands/steering.md` 作成
- [x] `install.sh` に link 追記（jira は手動除外）
- [x] `~/.claude/commands/steering.md` シンボリックリンク作成
- [x] コミット

## 決定事項

- ファイル名: `design.md`（`plan.md` から変更）
- テンプレート項目: 目的 / 背景・制約 / 実装計画 / 決定事項 / 懸念・リスク
- `allowed-tools`: `Bash(mkdir:*)`, `Bash(date:*)`, `Write`
- 配置: `dotfiles/claude/commands/steering.md` → symlink

## 懸念・リスク

- `claude/.steering/` は `.gitignore` 対象にするか未決定（センシティブな設計情報が入る可能性）
