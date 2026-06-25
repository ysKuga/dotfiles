# map-setup-command

## 目的

dotfiles の構成・設定を参照するための `/map-setup` コマンドと、構造質問時の自動参照ルールを追加する。

## 背景・制約

- `setup.md` は常時ロードではなく、構造について質問した時だけ参照したい
- スラッシュコマンドはユーザー起動のみ → Claude が自発実行不可
- CLAUDE.md のルールで「構造質問時に Read する」指示が代替手段として有効

## 実装計画

- [x] `claude/commands/map-setup.md` 作成（`/map-setup` 手動実行用）
- [x] `claude/CLAUDE.md` に Structure Reference ルール追記（自動参照）

## 決定事項

- コマンド名: `/map-setup`（`/setup` はセットアップと混同、`/map` は汎用すぎる）
- 自動参照トリガー: 構造・設定・ツール・MCP に関する質問
- 参照先: `claude/notes/setup.md`
- CLAUDE.md への追記は `claude/CLAUDE.md`（プロジェクトローカル）
