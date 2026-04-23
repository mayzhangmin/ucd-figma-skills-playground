#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_MCP="/Users/maymayHoliday/Figma-Skills/.vscode/mcp.json"
USER_MCP="$HOME/Library/Application Support/Code/User/mcp.json"
ENDPOINT="https://mcp.figma.com/mcp"

ok() { printf "[OK] %s\n" "$1"; }
warn() { printf "[WARN] %s\n" "$1"; }
fail() { printf "[FAIL] %s\n" "$1"; }

printf "=== Figma MCP Health Check ===\n"

if [[ -f "$WORKSPACE_MCP" ]] && grep -q '"url"[[:space:]]*:[[:space:]]*"https://mcp.figma.com/mcp"' "$WORKSPACE_MCP"; then
  ok "Workspace MCP config is present: $WORKSPACE_MCP"
else
  fail "Workspace MCP config is missing or endpoint not set: $WORKSPACE_MCP"
fi

if [[ -f "$USER_MCP" ]] && grep -q '"url"[[:space:]]*:[[:space:]]*"https://mcp.figma.com/mcp"' "$USER_MCP"; then
  ok "User MCP config is present: $USER_MCP"
else
  warn "User MCP config is missing or endpoint not set: $USER_MCP"
fi

HTTP_CODE="$(curl -sS -o /tmp/figma_mcp_probe.out -w "%{http_code}" -I "$ENDPOINT" || true)"

if [[ "$HTTP_CODE" == "405" || "$HTTP_CODE" == "401" || "$HTTP_CODE" == "403" || "$HTTP_CODE" == "200" ]]; then
  ok "Endpoint reachable over TLS. HTTP status: $HTTP_CODE"
else
  fail "Endpoint probe unexpected. HTTP status: $HTTP_CODE"
fi

if grep -qi "strict-transport-security" /tmp/figma_mcp_probe.out 2>/dev/null; then
  ok "TLS/security headers detected"
else
  warn "No strict-transport-security header observed in probe output"
fi

rm -f /tmp/figma_mcp_probe.out

printf "\nNext if VS Code still shows disconnected:\n"
printf "1) Run MCP: List Servers -> figma -> Restart\n"
printf "2) If needed, run MCP: Reset Trust, then Start figma again\n"
printf "3) If still stuck, run Developer: Reload Window\n"
