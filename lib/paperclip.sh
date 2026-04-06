#!/usr/bin/env bash
# paperclip.sh — lightweight Paperclip API client for AVNER
# Source this file, then call functions. Respects dry_run and missing env vars.

PAPERCLIP_CONFIG="${PAPERCLIP_CONFIG:-.paperclip/config.yaml}"
_PC_LOADED=""

# --- Config loader (simple grep/sed, no deps) ---

paperclip_load_config() {
  [ -n "$_PC_LOADED" ] && return 0
  if [ ! -f "$PAPERCLIP_CONFIG" ]; then
    echo "[paperclip] WARN: config not found at $PAPERCLIP_CONFIG" >&2
    _PC_DRY_RUN="true"
    return 1
  fi

  _pc_val() { grep "^${1}:" "$PAPERCLIP_CONFIG" 2>/dev/null | head -1 | sed "s/^${1}:[[:space:]]*//" | tr -d '"' ; }

  _PC_API_URL="$(_pc_val api_url)"
  _PC_COMPANY_ID="$(_pc_val company_id)"
  _PC_DRY_RUN="$(_pc_val dry_run)"
  _PC_HEARTBEATS="$(_pc_val "  enabled" || echo "true")"
  _PC_API_KEY_VAR="$(_pc_val api_key_env_var)"
  _PC_API_KEY="${!_PC_API_KEY_VAR:-}"

  # Agent IDs from nested YAML (simple extraction)
  _PC_AGENT_CEO="$(grep "ceo_codex:" "$PAPERCLIP_CONFIG" 2>/dev/null | head -1 | sed 's/.*:[[:space:]]*//' | tr -d '"')"
  _PC_AGENT_CLAUDE="$(grep "claude_code:" "$PAPERCLIP_CONFIG" 2>/dev/null | head -1 | sed 's/.*:[[:space:]]*//' | tr -d '"')"
  _PC_AGENT_REVIEW="$(grep "codex_review:" "$PAPERCLIP_CONFIG" 2>/dev/null | head -1 | sed 's/.*:[[:space:]]*//' | tr -d '"')"

  # Override from env if set (Paperclip process adapter injects these)
  [ -n "${PAPERCLIP_API_URL:-}" ] && _PC_API_URL="$PAPERCLIP_API_URL"
  [ -n "${PAPERCLIP_AGENT_ID:-}" ] && _PC_AGENT_CLAUDE="$PAPERCLIP_AGENT_ID"
  [ -n "${PAPERCLIP_COMPANY_ID:-}" ] && _PC_COMPANY_ID="$PAPERCLIP_COMPANY_ID"
  [ -n "${PAPERCLIP_API_KEY:-}" ] && _PC_API_KEY="$PAPERCLIP_API_KEY"

  _PC_LOADED="1"
}

# --- Internal helpers ---

_pc_can_call() {
  paperclip_load_config || true
  if [ "$_PC_DRY_RUN" = "true" ]; then
    return 1
  fi
  if [ -z "$_PC_API_URL" ] || [ -z "$_PC_API_KEY" ]; then
    echo "[paperclip] WARN: missing API URL or key — skipping call" >&2
    return 1
  fi
  return 0
}

_pc_post() {
  local url="$1"
  local body="${2:-}"
  if [ -n "$body" ]; then
    curl -sf -X POST "$url" \
      -H "Authorization: Bearer $_PC_API_KEY" \
      -H "Content-Type: application/json" \
      -d "$body" 2>/dev/null
  else
    curl -sf -X POST "$url" \
      -H "Authorization: Bearer $_PC_API_KEY" \
      -H "Content-Type: application/json" 2>/dev/null
  fi
}

_pc_get() {
  local url="$1"
  curl -sf "$url" \
    -H "Authorization: Bearer $_PC_API_KEY" \
    -H "Content-Type: application/json" 2>/dev/null
}

# --- Public API ---

# Heartbeat — POST /api/agents/{agentId}/heartbeat/invoke
# Usage: paperclip_heartbeat [agent_id]
paperclip_heartbeat() {
  local agent_id="${1:-$_PC_AGENT_CLAUDE}"
  paperclip_load_config || true

  if ! _pc_can_call; then
    echo "[paperclip] DRY-RUN heartbeat agent=$agent_id" >&2
    return 0
  fi

  [ -z "$agent_id" ] && { echo "[paperclip] WARN: no agent ID for heartbeat" >&2; return 0; }
  _pc_post "${_PC_API_URL}/agents/${agent_id}/heartbeat/invoke" || true
}

# Approval request — POST /api/companies/{companyId}/approvals
# Usage: paperclip_request_approval <task_id> <risk> <summary> <council_status>
# Returns: approval ID (or empty on failure)
paperclip_request_approval() {
  local task_id="$1" risk="$2" summary="$3" council_status="${4:-ALL_GO}"
  local agent_id="${_PC_AGENT_CEO:-}"
  paperclip_load_config || true

  local body
  body=$(cat <<EOJSON
{
  "type": "task_gate",
  "requestedByAgentId": "${agent_id}",
  "payload": {
    "taskId": "${task_id}",
    "risk": "${risk}",
    "summary": "${summary}",
    "council_status": "${council_status}"
  }
}
EOJSON
  )

  if ! _pc_can_call; then
    echo "[paperclip] DRY-RUN approval request:" >&2
    echo "$body" >&2
    return 0
  fi

  [ -z "$_PC_COMPANY_ID" ] && { echo "[paperclip] WARN: no company ID" >&2; return 1; }
  _pc_post "${_PC_API_URL}/companies/${_PC_COMPANY_ID}/approvals" "$body"
}

# Check approval status — GET /api/approvals/{approvalId}
# Usage: paperclip_check_approval <approval_id>
paperclip_check_approval() {
  local approval_id="$1"
  paperclip_load_config || true

  if ! _pc_can_call; then
    echo "[paperclip] DRY-RUN check approval=$approval_id" >&2
    return 0
  fi

  _pc_get "${_PC_API_URL}/approvals/${approval_id}"
}

# Budget check — GET /api/companies/{companyId}/costs/summary
# Usage: paperclip_check_budget
# Returns: JSON summary (caller parses)
paperclip_check_budget() {
  paperclip_load_config || true

  if ! _pc_can_call; then
    echo "[paperclip] DRY-RUN budget check company=$_PC_COMPANY_ID" >&2
    return 0
  fi

  [ -z "$_PC_COMPANY_ID" ] && { echo "[paperclip] WARN: no company ID" >&2; return 1; }
  _pc_get "${_PC_API_URL}/companies/${_PC_COMPANY_ID}/costs/summary"
}

# Cost event — POST /api/companies/{companyId}/cost-events
# Usage: paperclip_cost_event <model> <input_tokens> <output_tokens>
paperclip_cost_event() {
  local model="$1" input_tokens="$2" output_tokens="$3"
  paperclip_load_config || true

  local body
  body=$(cat <<EOJSON
{
  "provider": "anthropic",
  "model": "${model}",
  "tokenUsage": { "input": ${input_tokens}, "output": ${output_tokens} }
}
EOJSON
  )

  if ! _pc_can_call; then
    echo "[paperclip] DRY-RUN cost event:" >&2
    echo "$body" >&2
    return 0
  fi

  [ -z "$_PC_COMPANY_ID" ] && { echo "[paperclip] WARN: no company ID" >&2; return 1; }
  _pc_post "${_PC_API_URL}/companies/${_PC_COMPANY_ID}/cost-events" "$body"
}
