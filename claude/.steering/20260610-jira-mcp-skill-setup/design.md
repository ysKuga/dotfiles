# jira-mcp-skill-setup

## 目的

Atlassian Remote MCP で Jira チケット Claude 取得。
`/jira <チケット番号>` → プレフィクスでインスタンス自動切替。

## 背景・制約

- Atlassian Remote MCP → OAuth 認証必須。Basic auth (API token) 不可
- 正規 URL: `https://mcp.atlassian.com/v1/sse`（`/v1/mcp` 非推奨）
- 接続方法: `npx mcp-remote` プロキシ経由（OAuth フロー処理）
- 利用可能ツール: `getTeamworkGraphContext` / `getTeamworkGraphObject`（Teamwork Graph API）
- ツール使用時 `cloudId` パラメータ必須（Atlassian Cloud インスタンス ID）
- OAuth トークンキャッシュ → `~/.mcp-auth` に自動保存（mcp-remote 管理）
- インスタンス複数管理構造維持（会社・プロジェクト単位）

## 実装計画

- [x] `claude/mcp/jira/<インスタンス名>/instance.json` 構造作成
- [x] `claude/mcp/jira/<インスタンス名>/prefixes.txt` でプレフィクス管理
- [x] `claude/commands/jira.md` スキル定義作成
- [x] `install.sh` に `~/.claude/commands/jira.md` symlink 追加
- [x] `switch.sh` base64 エンコードバグ修正（Basic auth 用）
- [x] settings.json を `mcp-remote` + OAuth 方式に変更
- [ ] 新セッションで `/jira JPSS-3` 動作確認（OAuth 認証完了後）
- [ ] `switch.sh` を mcp-remote 対応に更新（複数インスタンス → URL 切替）
- [ ] 複数インスタンス時の選択フロー確認

## 決定事項

- 認証: `npx -y mcp-remote <SSE URL>` → OAuth ブラウザフロー（初回のみ）
- settings.json 形式: `{"command":"npx","args":["-y","mcp-remote","<SSE URL>"]}`
- プレフィクス管理: `prefixes.txt`（1行1プレフィクス）→ grep 検索
- インスタンス選択: 1件自動、複数対話
- アクティブインスタンス: `~/.claude/jira-current` に instance.json パス保持
- 新規プレフィクス: `prefixes.txt` 自動追記

## 調査結果（2026-06-10）

- `streamable-http` + Basic auth: curl/Node.js 接続OK → Claude Code MCP ロード失敗
- Cloudflare error 1010: Python urllib ブロック（curl/Node.js は通過）
- `/v1/mcp` エンドポイント: initialize/tools/list は動作するが Claude Code で不採用
- 正解: `mcp-remote` + `/v1/sse` → OAuth 認証が正しい方式（Zenn 記事確認）

## 懸念・リスク

- `instance.json` credential フィールド → OAuth 移行で不要化。ただし残存（削除検討）
- MCP はセッション開始時接続 → `switch.sh` 実行後は再起動必要
- `switch.sh` 現状: mcp-remote URL 切替未対応（複数インスタンス時要修正）
- cloudId 取得方法未確認 → Atlassian 管理画面から取得要
