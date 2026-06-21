#!/usr/bin/env bash
# Supply chain security audit for cloned repositories
# Checks lifecycle scripts, .npmrc, and code patterns before package install

set -euo pipefail

REPO_ROOT="${1:-$(pwd)}"
WARN=0
FINDINGS=()

add_finding() {
  local severity="$1"
  local message="$2"
  FINDINGS+=("[$severity] $message")
  if [[ "$severity" == "HIGH" || "$severity" == "CRITICAL" ]]; then
    WARN=1
  fi
}

check_package_json() {
  local pkg_file="$1"
  [[ ! -f "$pkg_file" ]] && return

  local dangerous_patterns=(
    'curl ' 'wget ' '/dev/tcp'
    'bash -c' 'sh -c' 'exec(' 'eval('
    'base64 -d' 'base64 --decode' 'base64 -D'
    'python -c' 'python3 -c' 'perl -e' 'ruby -e'
    'node -e' 'node --eval'
    'powershell' 'cmd.exe'
    'rm -rf' 'chmod +x'
    '> /' '>> /'
    '.ssh/' 'id_rsa' '.aws/' 'credentials'
    'HOME/' 'USERPROFILE'
  )

  local lifecycle_scripts=('preinstall' 'install' 'postinstall' 'prepare' 'prepublish' 'prepack')

  for script_name in "${lifecycle_scripts[@]}"; do
    local script_content
    script_content=$(python3 -c "
import json, sys
try:
    with open('$pkg_file') as f:
        data = json.load(f)
    scripts = data.get('scripts', {})
    print(scripts.get('$script_name', ''))
except:
    pass
" 2>/dev/null)

    if [[ -n "$script_content" ]]; then
      add_finding "INFO" "$(basename $(dirname $pkg_file))/package.json: '$script_name' = $script_content"

      for pattern in "${dangerous_patterns[@]}"; do
        if echo "$script_content" | grep -qiF "$pattern"; then
          add_finding "HIGH" "$(basename $(dirname $pkg_file))/package.json: '$script_name' contains '$pattern'"
        fi
      done
    fi
  done
}

check_npmrc() {
  local npmrc_file="$1"
  [[ ! -f "$npmrc_file" ]] && return

  while IFS= read -r line; do
    if echo "$line" | grep -qiE '^registry\s*='; then
      local registry
      registry=$(echo "$line" | sed 's/.*=\s*//' | tr -d '"'"'"' ')
      if ! echo "$registry" | grep -qE '^https://registry\.npmjs\.org'; then
        add_finding "HIGH" ".npmrc: custom registry: $registry"
      fi
    fi
    if echo "$line" | grep -qE '^//.*:_authToken'; then
      local host
      host=$(echo "$line" | cut -d: -f1 | tr -d '/')
      if ! echo "$host" | grep -qE 'registry\.npmjs\.org|npm\.pkg\.github\.com'; then
        add_finding "CRITICAL" ".npmrc: auth token for unknown host: $host"
      fi
    fi
  done < "$npmrc_file"
}

check_js_files() {
  local dir="$1"
  local found_files=()

  # Collect files matching suspicious patterns
  while IFS= read -r f; do
    [[ -n "$f" ]] && found_files+=("$f")
  done < <(grep -rEl \
    'eval\s*\(|new\s+Function\s*\(|execSync|spawnSync' \
    "$dir" \
    --include="*.js" --include="*.mjs" --include="*.cjs" \
    --exclude-dir=node_modules --exclude-dir=.git \
    --exclude-dir=dist --exclude-dir=build \
    2>/dev/null | head -10)

  for f in "${found_files[@]}"; do
    add_finding "MEDIUM" "Suspicious pattern (eval/exec/Function): ${f#$dir/}"
  done

  # Large base64 strings
  while IFS= read -r f; do
    [[ -n "$f" ]] && add_finding "MEDIUM" "Large base64 string: ${f#$dir/}"
  done < <(grep -rEl \
    "Buffer\.from\('[A-Za-z0-9+/=]\{100,\}'" \
    "$dir" \
    --include="*.js" --include="*.mjs" \
    --exclude-dir=node_modules --exclude-dir=.git \
    2>/dev/null | head -5)
}

check_git_hooks() {
  local dir="$1"
  local hook_files=(
    "$dir/.husky/pre-commit"
    "$dir/.husky/post-merge"
    "$dir/.husky/post-checkout"
    "$dir/.git/hooks/post-checkout"
    "$dir/.git/hooks/post-merge"
  )

  for hook_file in "${hook_files[@]}"; do
    if [[ -f "$hook_file" ]] && \
       grep -qiE 'curl|wget|/dev/tcp|bash -c|eval' "$hook_file" 2>/dev/null; then
      add_finding "CRITICAL" "Suspicious hook: ${hook_file#$dir/}"
    fi
  done
}

# --- Run checks ---

check_package_json "$REPO_ROOT/package.json"
check_npmrc "$REPO_ROOT/.npmrc"
check_js_files "$REPO_ROOT"
check_git_hooks "$REPO_ROOT"

# Workspace nested package.json
while IFS= read -r nested_pkg; do
  [[ "$nested_pkg" == "$REPO_ROOT/package.json" ]] && continue
  check_package_json "$nested_pkg"
  check_npmrc "$(dirname "$nested_pkg")/.npmrc"
done < <(find "$REPO_ROOT" -name "package.json" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  2>/dev/null | head -20)

# --- Output ---

echo ""
echo "=== REPO SECURITY AUDIT ==="
echo "Target: $REPO_ROOT"
echo ""

if [[ ${#FINDINGS[@]} -eq 0 ]]; then
  echo "[PASS] No suspicious patterns found."
else
  for finding in "${FINDINGS[@]}"; do
    case "$finding" in
      "[CRITICAL]"*) echo "CRITICAL: ${finding#[CRITICAL] }" ;;
      "[HIGH]"*)     echo "HIGH:     ${finding#[HIGH] }" ;;
      "[MEDIUM]"*)   echo "MEDIUM:   ${finding#[MEDIUM] }" ;;
      "[INFO]"*)     echo "INFO:     ${finding#[INFO] }" ;;
    esac
  done
fi

echo ""

if [[ $WARN -eq 1 ]]; then
  echo "[WARNING] HIGH or CRITICAL findings detected. Review before running install."
else
  echo "[OK] No high-risk patterns detected."
fi
echo ""

# Always exit 0 (warning only, does not block)
exit 0
