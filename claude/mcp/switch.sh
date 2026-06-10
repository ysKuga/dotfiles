#!/bin/bash
set -euo pipefail

SETTINGS="${HOME}/.claude/settings.json"

usage() {
  echo "Usage: $(basename "$0") <instance.json>"
  echo "       $(basename "$0") --off"
  exit 1
}

if [[ $# -ne 1 ]]; then usage; fi

if [[ "$1" == "--off" ]]; then
  python3 - "$SETTINGS" <<'EOF'
import json, sys
path = sys.argv[1]
with open(path) as f:
    settings = json.load(f)
settings.setdefault("mcpServers", {}).pop("atlassian", None)
if not settings["mcpServers"]:
    del settings["mcpServers"]
with open(path, "w") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")
EOF
  echo "atlassian MCP: disabled"
  exit 0
fi

INSTANCE_JSON="$1"
if [[ ! -f "$INSTANCE_JSON" ]]; then
  echo "Error: file not found: $INSTANCE_JSON" >&2
  exit 1
fi

python3 - "$SETTINGS" "$INSTANCE_JSON" <<'EOF'
import json, sys, base64

settings_path = sys.argv[1]
instance_path = sys.argv[2]

with open(instance_path) as f:
    inst = json.load(f)

name = inst.get("name", "unknown")
url = inst.get("url", "https://mcp.atlassian.com/v1/mcp")
auth = inst.get("auth", "basic").lower()
credential = inst.get("credential", "")

if auth == "basic":
    # credential は base64(email:token) をそのまま渡す想定
    # 未エンコードの場合は自動エンコード
    try:
        base64.b64decode(credential)
        auth_value = f"Basic {credential}"
    except Exception:
        encoded = base64.b64encode(credential.encode()).decode()
        auth_value = f"Basic {encoded}"
elif auth == "bearer":
    auth_value = f"Bearer {credential}"
else:
    print(f"Error: unknown auth type '{auth}'", file=sys.stderr)
    sys.exit(1)

mcp_entry = {
    "type": "streamable-http",
    "url": url,
    "headers": {
        "Authorization": auth_value
    }
}

with open(settings_path) as f:
    settings = json.load(f)

settings.setdefault("mcpServers", {})["atlassian"] = mcp_entry

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")

print(f"atlassian MCP: switched to '{name}'")
EOF
