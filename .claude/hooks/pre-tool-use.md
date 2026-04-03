# PreToolUse Hooks

Hooks defined in `templates/project/.claude/settings.json.tmpl` under `hooks.PreToolUse`:

1. **Lint + typecheck before commit** — runs `npm run lint` and `tsc --noEmit` before any `git commit`
2. **Vision evidence lock** — blocks `git commit` unless `last_vision_check.txt` has APPROVE or FIX-BYPASS
3. **Merge gate lock** — blocks `git merge` unless `gate_pass.txt` has GATE_PASS token
4. **File protection** — blocks writes to operations-owned files (DISPATCH.md, COUNCIL_LOG.md, gate_pass.txt) except by designated roles
5. **DNA Safety warning** — warns when touching CLAUDE.md, MEMORY.md, or LESSONS_*.md (requires human approval)
6. **File-touch tracking** — tracks files touched by Executor, warns when exceeding mode limits
