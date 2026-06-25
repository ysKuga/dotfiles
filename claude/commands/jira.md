---
allowed-tools: mcp__atlassian__getAccessibleAtlassianResources, mcp__atlassian__getJiraIssue, Bash(python3:*)
description: Jira チケット取得（Atlassian MCP経由、OAuth 自動処理）
---

## 引数

`$ARGUMENTS`: チケット番号（例: `JPSS-123`）

## 手順

### 1. 認証確認・OAuth フロー

以下のスクリプトで認証状態を確認し、未認証の場合は OAuth フローを実行する:

```python
import json, os, time, secrets, hashlib, base64, urllib.parse, http.server, threading

CREDS_PATH = os.path.expanduser('~/.claude/.credentials.json')
SERVER_NAME = 'atlassian'
SERVER_URL = 'https://mcp.atlassian.com/v1/mcp/authv2'
REDIRECT_URI = 'http://localhost:3118/callback'
SCOPES = 'offline_access read:account read:all:twg read:comment:confluence read:component:compass read:confluence-user read:event:compass read:hierarchical-content:confluence read:jira-work read:me read:metric:compass read:page:confluence read:scorecard:compass read:space:confluence search:confluence write:all:twg write:comment:confluence write:component:compass write:jira-work write:page:confluence write:scorecard:compass'

def load_creds():
    try:
        return json.load(open(CREDS_PATH))
    except Exception:
        return {}

def find_mcp_entry(creds):
    mcp_oauth = creds.get('mcpOAuth', {})
    for key, val in mcp_oauth.items():
        if val.get('serverName') == SERVER_NAME:
            return key, val
    return None, {}

creds = load_creds()
mcp_key, entry = find_mcp_entry(creds)

def is_authenticated():
    return bool(entry.get('accessToken')) and entry.get('expiresAt', 0) > time.time() * 1000 + 60000

if is_authenticated():
    print('authenticated')
else:
    # client 情報を credentials から読み取り（Claude Code が保存済みの場合）
    client_id = entry.get('clientId')
    client_secret = entry.get('clientSecret')
    if not client_id:
        print('Error: OAuth クライアント情報が見つかりません。先に claude CLI でログインしてください。')
        exit(1)

    # PKCE 生成
    verifier = secrets.token_urlsafe(64)
    challenge = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode()).digest()).rstrip(b'=').decode()
    state = secrets.token_urlsafe(16)

    auth_url = (
        'https://auth.atlassian.com/authorize'
        f'?audience=api.atlassian.com'
        f'&client_id={client_id}'
        f'&scope={urllib.parse.quote(SCOPES)}'
        f'&redirect_uri={urllib.parse.quote(REDIRECT_URI)}'
        f'&state={state}'
        f'&response_type=code'
        f'&code_challenge={challenge}'
        f'&code_challenge_method=S256'
        f'&prompt=consent'
    )

    # コールバックサーバー起動
    received = {}
    class Handler(http.server.BaseHTTPRequestHandler):
        def do_GET(self):
            params = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
            received['code'] = params.get('code', [None])[0]
            self.send_response(200); self.end_headers()
            self.wfile.write(b'Authorization successful! You may close this window.')
            threading.Thread(target=self.server.shutdown).start()
        def log_message(self, *args): pass

    server = http.server.HTTPServer(('localhost', 3118), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()

    print(f'\n認証が必要です。以下の URL をブラウザで開いてください:\n\n{auth_url}\n')
    input('ブラウザで認証完了後、Enter を押してください...')

    code = received.get('code')
    if not code:
        print('Error: コールバックを受信できませんでした')
        exit(1)

    # トークン交換
    import urllib.request
    data = urllib.parse.urlencode({
        'grant_type': 'authorization_code',
        'client_id': client_id,
        'client_secret': client_secret,
        'code': code,
        'redirect_uri': REDIRECT_URI,
        'code_verifier': verifier,
    }).encode()
    req = urllib.request.Request('https://auth.atlassian.com/oauth/token', data=data,
        headers={'Content-Type': 'application/x-www-form-urlencoded'})
    resp = json.loads(urllib.request.urlopen(req).read())

    creds = load_creds()
    key = mcp_key or f'{SERVER_NAME}|unknown'
    creds.setdefault('mcpOAuth', {})[key] = {
        'serverName': SERVER_NAME,
        'serverUrl': SERVER_URL,
        'accessToken': resp['access_token'],
        'refreshToken': resp.get('refresh_token'),
        'expiresAt': int(time.time() * 1000) + resp.get('expires_in', 3600) * 1000,
        'scope': resp.get('scope', SCOPES),
        'clientId': client_id,
        'clientSecret': client_secret,
        'redirectUri': REDIRECT_URI,
        'discoveryState': entry.get('discoveryState', {})
    }
    json.dump(creds, open(CREDS_PATH, 'w'), indent=2)
    print('認証完了')
```

### 2. auth キャッシュクリア

```python
import json, os
path = os.path.expanduser('~/.claude/mcp-needs-auth-cache.json')
try:
    d = json.load(open(path))
    d.pop('atlassian', None)
    json.dump(d, open(path, 'w'), indent=2)
except Exception:
    pass
```

### 3. cloudId 取得

`mcp__atlassian__getAccessibleAtlassianResources` を呼び出す。複数インスタンスの場合はプレフィクス（`$ARGUMENTS` のハイフン前）でフィルタして選択する。

### 4. チケット取得

`mcp__atlassian__getJiraIssue` を呼び出す:
- `cloudId`: 上記で取得した値
- `issueIdOrKey`: `$ARGUMENTS`
- `fields`: `["summary", "description", "status", "priority", "assignee", "comment"]`
- `responseContentFormat`: `"markdown"`

取得した情報を以下の形式で表示:
- キー・サマリー・ステータス・優先度・担当者
- 説明（本文）
- 最新コメント3件
