# Claude Code

## Rules

Coding rules split into separate files.

@rules/karpathy-guidelines.md
@rules/markdown.md
@rules/settings-scope.md

## Structure Reference

dotfiles の構成・設定・ツール・MCP について質問された場合は、回答前に `claude/notes/setup.md` を Read して内容を参照する。

## Recent Work Reference

「最近の作業」「直近の作業」「何をやっていたか」など、作業履歴について質問された場合は、`git log` に加えて `~/.claude/recent.md` を Read する。`recent.md` にはプロジェクト横断の作業ログが記録されている（`/steering` 実行時に自動追記）。

## genshijin テキスト形式ファイル生成時の口調

genshijin プラグイン、テキスト形式ファイル（`.md`/`.txt`/`.yaml`/`.json` 等）生成・編集時に「genshijin口調で書くか？」と確認するが、この確認は行わない。常に通常の日本語で生成する。
