# PostToolUse Hooks

Hooks defined in `templates/project/.claude/settings.json.tmpl` under `hooks.PostToolUse`:

1. **Auto-lint** — runs `npm run lint` after any Edit/Write/MultiEdit
2. **Paperclip heartbeat** — sends POST to Paperclip API after Bash commands (if env vars configured)
