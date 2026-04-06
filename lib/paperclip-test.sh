#!/usr/bin/env bash
# paperclip-test.sh — dry-run self-test for paperclip.sh
# Run: bash lib/paperclip-test.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/paperclip.sh"

# Force dry-run regardless of config
_PC_DRY_RUN="true"
_PC_LOADED="1"
_PC_API_URL="http://localhost:3100/api"
_PC_COMPANY_ID="test-company"
_PC_AGENT_CEO="test-ceo"
_PC_AGENT_CLAUDE="test-claude"
_PC_API_KEY=""

PASS=0
FAIL=0

assert_ok() {
  local name="$1"
  shift
  if "$@" 2>/dev/null; then
    echo "  PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $name (exit $?)"
    FAIL=$((FAIL + 1))
  fi
}

assert_stderr_contains() {
  local name="$1" pattern="$2"
  shift 2
  local tmpf
  tmpf=$(mktemp)
  "$@" 2>"$tmpf" >/dev/null || true
  if grep -q "$pattern" "$tmpf"; then
    echo "  PASS: $name"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $name — expected '$pattern' in stderr"
    echo "        got: $(cat "$tmpf")"
    FAIL=$((FAIL + 1))
  fi
  rm -f "$tmpf"
}

echo "=== paperclip.sh dry-run tests ==="
echo ""

assert_ok "heartbeat no crash" paperclip_heartbeat
assert_stderr_contains "heartbeat logs DRY-RUN" "DRY-RUN heartbeat" paperclip_heartbeat

assert_ok "approval request no crash" paperclip_request_approval "REQ-01" "HIGH" "test summary" "ALL_GO"
assert_stderr_contains "approval logs DRY-RUN" "DRY-RUN approval" paperclip_request_approval "REQ-01" "HIGH" "test" "ALL_GO"

assert_ok "check approval no crash" paperclip_check_approval "approval-123"
assert_stderr_contains "check approval logs DRY-RUN" "DRY-RUN check approval" paperclip_check_approval "approval-123"

assert_ok "budget check no crash" paperclip_check_budget
assert_stderr_contains "budget check logs DRY-RUN" "DRY-RUN budget" paperclip_check_budget

assert_ok "cost event no crash" paperclip_cost_event "claude-sonnet-4-20250514" 1000 500
assert_stderr_contains "cost event logs DRY-RUN" "DRY-RUN cost event" paperclip_cost_event "claude-sonnet-4-20250514" 1000 500

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
