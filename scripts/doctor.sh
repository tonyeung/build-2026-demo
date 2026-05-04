#!/usr/bin/env bash
# Pre-demo health check. Run as the first slide.
# One screen of output. Green = ready, red = stop and fix.

set -uo pipefail

GREEN=$'\033[32m'
RED=$'\033[31m'
DIM=$'\033[2m'
RST=$'\033[0m'

ok()   { printf "  %sOK  %s  %s%s\n" "$GREEN" "$RST" "$1" "${2:+ $DIM($2)$RST}"; }
bad()  { printf "  %sNO  %s  %s%s\n" "$RED"   "$RST" "$1" "${2:+ $DIM— $2$RST}"; }
info() { printf "  %s..  %s  %s\n" "$DIM" "$RST" "$1"; }

echo "BUILD 2026 demo — pre-demo doctor"
echo

# ---------- Token ----------
if [ -n "${GITHUB_TOKEN:-}" ]; then
  ok "GITHUB_TOKEN present" "len=${#GITHUB_TOKEN}"
else
  bad "GITHUB_TOKEN missing" "edit .devcontainer/.env then Rebuild Container"
fi

# ---------- Network: DNS ----------
if getent hosts models.github.ai >/dev/null 2>&1; then
  ok "DNS resolves models.github.ai"
else
  bad "DNS fails for models.github.ai" "venue WiFi may be NAT'd; switch network"
fi

# ---------- Network: Models endpoint ----------
if [ -n "${GITHUB_TOKEN:-}" ]; then
  http=$(curl -sS -o /dev/null -w "%{http_code}" \
    -X POST https://models.github.ai/inference/chat/completions \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"model":"openai/gpt-4.1","messages":[{"role":"user","content":"ping"}]}' \
    --max-time 8 2>/dev/null || echo "000")
  case "$http" in
    200) ok "Models endpoint reachable + auth OK" ;;
    401) bad "Models 401 unauthorized" "PAT is classic, not fine-grained" ;;
    403) bad "Models 403 forbidden" "PAT missing Models:Read permission" ;;
    000) bad "Models endpoint unreachable" "no response — network down or blocked" ;;
    *)   bad "Models returned HTTP $http" "unexpected — investigate before stage" ;;
  esac
else
  info "Models endpoint check skipped (no token)"
fi

# ---------- gh auth (Path A) ----------
if gh auth status >/dev/null 2>&1; then
  ok "gh authenticated" "$(gh auth status 2>&1 | awk '/Logged in to/{print $0; exit}' | sed 's/^[ ]*//')"
else
  bad "gh not authenticated" "run: gh auth login (Path A demos will fail)"
fi

# ---------- Copilot CLI alive ----------
if command -v copilot >/dev/null 2>&1; then
  ok "copilot CLI installed" "$(copilot --version 2>/dev/null | head -n1)"
else
  bad "copilot CLI missing" "feature didn't install — Rebuild Container"
fi

# ---------- Container resources ----------
mem_avail_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
mem_avail_mb=$((mem_avail_kb / 1024))
if [ "$mem_avail_mb" -gt 1024 ]; then
  ok "Memory available" "${mem_avail_mb} MB"
else
  bad "Memory low" "${mem_avail_mb} MB available — close other apps"
fi

disk_avail=$(df -P /workspaces 2>/dev/null | awk 'NR==2 {print $4}')
if [ -n "$disk_avail" ] && [ "$disk_avail" -gt 1048576 ]; then
  ok "Disk available" "$((disk_avail / 1024)) MB on /workspaces"
else
  bad "Disk space low" "<1GB free — clean up before stage"
fi

# ---------- Offline fallback present ----------
if [ -f examples/models_api_fixture.json ]; then
  ok "Offline fixture present" "MODELS_OFFLINE=1 will work"
else
  bad "Offline fixture missing" "no fallback if WiFi dies"
fi

echo
echo "Done. If any line is red, fix before going on stage."
