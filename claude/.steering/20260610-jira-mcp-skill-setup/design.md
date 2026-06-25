# jira-mcp-skill-setup

## 目的

Atlassian Remote MCP で Jira チケットを Claude から取得。
`/jira <チケット番号>` で即時取得、未認証時は自動で OAuth フロー実行。

## 最終的な設定手順（2026-06-25 確定）

### 1. MCP サーバー登録（初回のみ）

```bash
claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp/authv2 -s user
```

- `-s user`: `~/.claude.json` に保存
- `mcp-remote` 不要

### 2. 初回 OAuth 認証

Claude Code CLI (`claude`) 起動後、Jira に言及すると OAuth フロー起動。
以降のセッションでは `/jira` スキルが自動処理。

### 3. 動作確認

```bash
claude mcp list
# atlassian: https://mcp.atlassian.com/v1/mcp/authv2 (HTTP) - ✔ Connected
```

## OAuth トークンの仕組み（2026-06-25 調査）

### 保存場所

`~/.claude/.credentials.json` → `mcpOAuth["{serverName}|{URLハッシュ}"]`

例: キー = `atlassian|60c89fc9e49f37c7`

### フィールド

```json
{
  "serverName": "atlassian",
  "serverUrl": "https://mcp.atlassian.com/v1/mcp/authv2",
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "expiresAt": 1782424027389,
  "scope": "offline_access read:jira-work ...",
  "clientId": "rSyssLmkmJUS1vwesec4r7g3rNnpK83c",
  "clientSecret": "ATOAp...",
  "redirectUri": "http://localhost:3118/callback",
  "discoveryState": { ... }
}
```

### OAuth エンドポイント

- 認可 URL: `https://auth.atlassian.com/authorize`
- トークン URL: `https://auth.atlassian.com/oauth/token`
- リソースメタデータ: `https://mcp.atlassian.com/.well-known/oauth-protected-resource/v1/mcp/authv2`
- 認可サーバーベース: `https://auth.atlassian.com/VCeDsk8ZHncYF1g234fKtc4lNipbBhu3`

### 重要な制約

- **PKCE 必須** (S256)。`code_challenge` なしでは「強化されたセキュリティが必要」エラー
- `audience=api.atlassian.com` パラメータ必須
- `prompt=consent` で確認画面を強制（省略可だが再認証時に必要）
- `mcp-needs-auth-cache.json` に atlassian エントリがあると同セッション内で OAuth 再試行しない → 削除で解除

### client_id / client_secret について

Claude Code の Atlassian MCP 用 OAuth アプリ資格情報。
全ユーザー・全 Atlassian インスタンスで共通（Anthropic 登録アプリ）。
`~/.claude/.credentials.json` に保存されるため、スキルは credentials から動的読み取り（git にハードコードしない）。

### MCP_KEY のフォーマット

`{claude mcp add 時の名前}|{URL のハッシュ}` 形式。
スキルでは `serverName == 'atlassian'` で検索して動的に特定する。

## 利用可能な MCP ツール

- `mcp__atlassian__getAccessibleAtlassianResources` → cloudId 取得（全インスタンス共通）
- `mcp__atlassian__getJiraIssue` → チケット詳細
- `mcp__atlassian__searchJiraIssuesUsingJql` → JQL 検索
- `mcp__atlassian__createJiraIssue` / `editJiraIssue` → 作成・編集
- Confluence / Compass / Bitbucket 系多数

## 廃止した方針

| 方針 | 廃止理由 |
|------|----------|
| `instance.json` / `prefixes.txt` | MCP が cloudId を直接提供するため不要 |
| `mcp-remote` stdio プロキシ | `--transport http` で代替 |
| `settings.json mcpServers` キー | MCP は `~/.claude.json` で管理 |
| `~/.mcp-auth` トークン読み取り | `~/.claude/.credentials.json` に移行 |
| `accessible-resources` REST 直呼び出し | MCP ツール `getAccessibleAtlassianResources` で代替 |

## 残課題

- 複数 Atlassian インスタンス時の選択フロー未確認
- refresh_token を使ったトークン自動更新未実装（現状は期限切れで再認証）
- `switch.sh` 残存 → 不要（削除検討）
