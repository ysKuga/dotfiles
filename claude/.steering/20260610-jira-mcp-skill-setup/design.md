# jira-mcp-skill-setup

## 目的

Atlassian Remote MCP で Jira チケットを Claude から取得。
`/jira <チケット番号>` で即時取得。

## 最終的な設定手順（2026-06-25 確定）

### 1. MCP サーバー登録

```bash
claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp/authv2 -s user
```

- `-s user`: ユーザーレベル設定（`~/.claude.json` に保存）
- `mcp-remote` は不要（Claude Code の HTTP transport を使用）

### 2. OAuth 認証

- Claude Code CLI (`claude`) 起動後、Jira に言及すると OAuth フロー起動
- ブラウザ（WSL では手動コピー）でログイン → 認証完了
- 以降はトークン自動使用

### 3. 確認

```bash
claude mcp list
# atlassian: https://mcp.atlassian.com/v1/mcp/authv2 (HTTP) - ✔ Connected
```

## 利用可能なツール（接続後）

- `mcp__atlassian__getAccessibleAtlassianResources` → cloudId 取得
- `mcp__atlassian__getJiraIssue` → チケット詳細
- `mcp__atlassian__searchJiraIssuesUsingJql` → JQL 検索
- `mcp__atlassian__createJiraIssue` / `editJiraIssue` → 作成・編集
- Confluence / Compass / Bitbucket 系も多数

## 廃止した方針

| 方針 | 廃止理由 |
|------|----------|
| `instance.json` / `prefixes.txt` 構造 | MCP が cloudId を直接提供するため不要 |
| `~/.config/claude/atlassian/*.json` | 同上 |
| `mcp-remote` (`npx -y mcp-remote ...`) | `--transport http` で代替可能 |
| `~/.mcp-auth` からトークン読み取り | HTTP MCP は Claude Code が管理 |
| `accessible-resources` REST API 呼び出し | `getAccessibleAtlassianResources` MCP ツールで代替 |
| `settings.json` の `mcpServers` / `servers` キー | MCP は `~/.claude.json` (`claude mcp add`) で管理 |

## 調査結果

- URL: `/v1/sse` → 旧式。正式は `/v1/mcp/authv2`
- `mcp-remote` + `settings.json mcpServers`: VSCode 拡張では MCP プロセス未起動
- `claude mcp add --transport http`: Claude Code 組み込み HTTP transport で動作
- OAuth は起動時ではなく Jira 言及時にトリガー
- WSL: OAuth URL は Terminal に表示されるが自動でブラウザは開かない（手動コピー要）
- `mcp-needs-auth-cache.json`: auth 済み判定をキャッシュ。認証が通らない場合は削除で再試行

## 懸念・残課題

- 複数インスタンス時の選択フロー未確認（現在シングルインスタンス）
- `switch.sh` は mcp-remote 前提で作成 → HTTP MCP 方式では意味なし（削除検討）
- `~/.claude/jira-current` ファイル残存 → 不要（削除可）
- `claude/mcp/jira/` ディレクトリ残存 → 不要（削除検討）
