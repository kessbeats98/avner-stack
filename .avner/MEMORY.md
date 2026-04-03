# MEMORY.md — avner-stack framework

## Key Design Decisions

1. **File-based, no DB**: all coordination via .avner/ files + git. Reason: must work offline, no infra deps, git gives free audit trail.
2. **3 roles, not 2 or 4**: CEO (what) + Builder (how) + Reviewer (quality). Reviewer is separate from CEO to avoid rubber-stamping own decisions.
3. **Council is optional**: 5 agents only fire for HIGH risk or on demand. Most tasks use 0-1 Council agents.
4. **Paperclip optional with dry-run default**: framework must work without external control plane. Paperclip adds visibility, not control.
5. **Anti-loop hard caps**: planning max 3 rounds, fix max 2 attempts, debug max 3 per subtask. Prevents infinite revision loops.
6. **One entry point**: /one-flow is the only execution path. No competing workflows.
7. **DNA Safety**: CLAUDE.md is the constitution. Never auto-modified. Human-only changes with visible diffs.

## Non-Goals (explicit)
- Team collaboration / multi-user
- Cloud-hosted state (stays file-based)
- Auto-merge on HIGH risk (always human gate)
