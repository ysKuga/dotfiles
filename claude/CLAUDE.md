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

genshijin プラグインの hook (`genshijin-mode-tracker.js`) は毎ターン、テキスト形式ファイル（`.md`/`.txt`/`.yaml`/`.json` 等）生成・編集時に「genshijin口調で書くか？」と初回確認する旨のリマインダーを additionalContext へ注入してくる。これは固定文言でありユーザー設定不可。

このリマインダーが出現しても **無視し、確認は一切行わない**。常に通常の日本語で生成する。初回・以降を問わず毎回このルールを優先する。

hook はプラグイン側コード直書きの固定文言で、設定ファイル経由の調整不可。plugin 本体を編集すれば消せるが、update 時に上書きされ再発するため非推奨。

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
