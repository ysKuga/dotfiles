---
allowed-tools: Bash(find:*), Bash(grep:*), Bash(cat:*), Bash(python3:*), Bash(curl:*)
description: Jira チケット取得（プレフィクスでインスタンス自動切替）
---

## 引数

`$ARGUMENTS`: チケット番号（例: `JPSS-123`）

## 手順

### 1. プレフィクス抽出

引数からハイフン前の文字列をプレフィクスとして抽出する。
- `JPSS-123` → `JPSS`
- 数字のみ（例: `123`）→ プレフィクスなし

### 2. インスタンス選択

**プレフィクスあり:**
```bash
grep -rl "<PREFIX>" ~/dotfiles/claude/mcp/jira/*/prefixes.txt
```
マッチしたファイルの親ディレクトリが対象インスタンスディレクトリ。

**プレフィクスなし / マッチなし:**
```bash
find ~/dotfiles/claude/mcp/jira -name "instance.json"
```
- 1件 → 自動選択
- 複数 → ユーザーに `name` フィールドを表示して選択を求める

### 3. チケット取得

インスタンスの `instance.json` から `base_url` と `credential` を読み取り、Jira REST API を呼び出す:

```python
import json, subprocess, sys, base64

inst = json.load(open('<instance.json のパス>'))
base_url = inst['base_url']
cred = inst['credential']
auth = 'Basic ' + base64.b64encode(cred.encode()).decode()
ticket = '<チケットID>'

result = subprocess.run([
    'curl', '-s',
    f'{base_url}/rest/api/3/issue/{ticket}',
    '-H', f'Authorization: {auth}',
    '-H', 'Accept: application/json'
], capture_output=True, text=True)

d = json.loads(result.stdout)
if 'errorMessages' in d:
    print('Error:', d['errorMessages'])
    sys.exit(1)

f = d['fields']
print(f"キー: {d['key']}")
print(f"サマリー: {f['summary']}")
print(f"ステータス: {f['status']['name']}")
print(f"優先度: {f.get('priority', {}).get('name', 'なし')}")
assignee = f.get('assignee')
print(f"担当者: {assignee['displayName'] if assignee else '未割当'}")
print()
desc = f.get('description')
if desc and desc.get('content'):
    for block in desc['content']:
        for c in block.get('content', []):
            if c.get('type') == 'text':
                print(c['text'])
print()
print('--- コメント ---')
comments = f.get('comment', {}).get('comments', [])
for cm in reversed(comments[-3:]):
    author = cm['author']['displayName']
    body = cm.get('body', {})
    text = ''
    for block in body.get('content', []):
        for c in block.get('content', []):
            if c.get('type') == 'text':
                text += c['text']
    print(f"[{author}] {text[:200]}")
```

### 4. プレフィクス追記（新規プレフィクス検出時）

引数のプレフィクスが選択インスタンスの `prefixes.txt` に存在しない場合、末尾に追記する:
```bash
echo "<PREFIX>" >> <インスタンスdir>/prefixes.txt
```
