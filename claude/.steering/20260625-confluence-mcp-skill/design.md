# confluence-mcp-skill

## 目的

Atlassian Remote MCP で Confluence ページの読み書きを Claude から実行。
`/confluence <サブコマンド>` で get / search / spaces / pages / create / update を操作。

## 現在の状態（2026-06-25）

### 完了

- `claude/commands/confluence.md` を旧 Basic auth 方式から MCP ツール方式に書き換え
- jira.md と同じ OAuth フロー（credentials.json から動的読み取り + PKCE）を組み込み
- 利用可能 MCP ツールを確認・マッピング済み

### 未確認・未実装

- 実際の動作確認未実施（認証・cloudId 取得・各サブコマンド）
- `create` / `update` の body フォーマット（markdown / storage format の扱い）
- `update` 時のバージョン番号取得フロー

## サブコマンド対応 MCP ツール

| サブコマンド | MCP ツール |
|-------------|-----------|
| `get <pageId>` | `getConfluencePage` |
| `search <CQL>` | `searchConfluenceUsingCql` |
| `spaces` | `getConfluenceSpaces` |
| `pages <spaceKey>` | `getPagesInConfluenceSpace` |
| `create <spaceKey> <title>` | `createConfluencePage` |
| `update <pageId>` | `updateConfluencePage` |

## 次回確認事項

1. `/confluence spaces` で動作確認
2. `/confluence get <pageId>` でページ取得確認
3. `createConfluencePage` の body パラメータ形式確認（markdown 受付か？）
4. `updateConfluencePage` の version フィールド取得方法確認
5. CQL の基本パターン確認（例: `space = "~myspace" AND title = "xxx"`）

## 認証

jira.md と共通の Atlassian MCP OAuth。
詳細は `claude/.steering/20260610-jira-mcp-skill-setup/design.md` 参照。

## 将来課題

### jira.md / confluence.md の認証コード共通化

現状: 両ファイルに同一の OAuth フロー Python コードが重複。

共通化の選択肢:
- `~/.claude/scripts/atlassian-auth.sh` などの外部スクリプトに切り出し、各 .md から呼び出す
- スキル側で `allowed-tools: Bash(bash:*)` として共通スクリプトを実行

実現可能性・メリット・デメリットは後程検討。
