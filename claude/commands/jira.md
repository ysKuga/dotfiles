---
allowed-tools: mcp__atlassian__getAccessibleAtlassianResources, mcp__atlassian__getJiraIssue
description: Jira チケット取得（Atlassian MCP経由）
---

## 引数

`$ARGUMENTS`: チケット番号（例: `JPSS-123`）

## 前提

Atlassian MCP が接続済みであること。未接続の場合は Jira について言及すると OAuth フローが起動する。
セットアップ: `claude mcp add --transport http atlassian https://mcp.atlassian.com/v1/mcp/authv2 -s user`

## 手順

### 1. cloudId 取得

`mcp__atlassian__getAccessibleAtlassianResources` を呼び出す。

複数インスタンスが返った場合は、プレフィクス（`$ARGUMENTS` のハイフン前）でフィルタして選択する。

### 2. チケット取得

`mcp__atlassian__getJiraIssue` を呼び出す:
- `cloudId`: 上記で取得した値
- `issueIdOrKey`: `$ARGUMENTS`
- `fields`: `["summary", "description", "status", "priority", "assignee", "comment"]`
- `responseContentFormat`: `"markdown"`

取得した情報を以下の形式で表示:
- キー・サマリー・ステータス・優先度・担当者
- 説明（本文）
- 最新コメント3件
