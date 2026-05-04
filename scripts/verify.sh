#!/usr/bin/env bash
# Verify the dev container has everything a BUILD 2026 demo needs.
# Run inside the container after `Reopen in Container` finishes.

set -uo pipefail
fail=0

pass() { printf "  PASS  %-32s %s\n" "$1" "${2:-}"; }
warn() { printf "  WARN  %-32s %s\n" "$1" "${2:-}"; }
err()  { printf "  FAIL  %-32s %s\n" "$1" "${2:-}"; fail=$((fail + 1)); }

ver() {
  local label=$1 cmd=$2
  if out=$(eval "$cmd" 2>&1); then
    pass "$label" "$(printf '%s' "$out" | head -n1)"
  else
    err "$label" "(cmd: $cmd)"
  fi
}

echo "== Tool versions =="
ver "node"        "node --version"
ver "python"      "python3 --version"
ver "go"          "go version"
ver "dotnet"      "dotnet --version"
ver "java"        "java -version 2>&1"
ver "gh"          "gh --version"
ver "copilot CLI" "copilot --version"
ver "git lfs"     "git lfs version"
ver "docker"      "docker --version"

echo
echo "== SDKs / extensions =="
if npm list -g --depth=0 2>/dev/null | grep -q '@github/copilot-sdk'; then
  pass "@github/copilot-sdk (global)"
else
  err "@github/copilot-sdk (global)" "npm list -g shows nothing"
fi
if pip3 show github-copilot-sdk >/dev/null 2>&1; then
  pass "github-copilot-sdk (pip)" "$(pip3 show github-copilot-sdk | awk '/^Version:/{print $2}')"
else
  err "github-copilot-sdk (pip)" "not installed"
fi
if gh extension list 2>/dev/null | grep -q gh-codeql; then
  pass "gh-codeql extension"
else
  err "gh-codeql extension" "(run: gh extension install github/gh-codeql)"
fi

echo
echo "== Environment =="
if [ -n "${GITHUB_TOKEN:-}" ]; then
  pass "GITHUB_TOKEN set" "(length=${#GITHUB_TOKEN})"
else
  warn "GITHUB_TOKEN not set" "edit .devcontainer/.env, then reopen-in-container"
fi

echo
echo "== Docker-in-Docker =="
if docker ps >/dev/null 2>&1; then
  pass "docker daemon reachable"
else
  err "docker daemon" "(docker ps failed — is dockerd running inside the container?)"
fi

echo
echo "== Path B: GitHub Models REST =="
if [ -n "${GITHUB_TOKEN:-}" ]; then
  if out=$(python3 examples/models_api.py 2>&1); then
    snippet=$(printf '%s' "$out" | tr -d '\n' | head -c 80)
    pass "models_api.py" "${snippet}..."
  else
    if printf '%s' "$out" | grep -q "401"; then
      err "models_api.py" "401 — token rejected. Likely a classic PAT; Models needs a fine-grained PAT. See README → Troubleshooting."
    elif printf '%s' "$out" | grep -q "403"; then
      err "models_api.py" "403 — token type is right but missing the Models:Read permission. Regenerate the fine-grained PAT with that box checked."
    elif printf '%s' "$out" | grep -qiE "name resolution|connection refused|timed out"; then
      err "models_api.py" "network error — corporate firewall blocking models.github.ai? Try Codespaces."
    else
      err "models_api.py" "$(printf '%s' "$out" | tr -d '\n' | head -c 160)"
    fi
  fi
else
  warn "models_api.py" "skipped — fill in GITHUB_TOKEN in .env, then reopen-in-container"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "All automated checks passed."
  echo "Now walk scripts/verify-manual.md for the VS Code / MCP / Path A checks."
  exit 0
else
  echo "$fail check(s) failed."
  exit 1
fi
