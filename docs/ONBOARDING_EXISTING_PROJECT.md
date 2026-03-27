# Onboarding an Existing Project

## Prerequisites
1. avner-stack cloned and `./setup` run (skills installed globally).
2. Claude Code CLI available.

## Steps

### 1. Run onboarding

```bash
./init/avner-init --project /path/to/your-project
```

Or from within the project:
```bash
/path/to/avner-stack/init/avner-init --project .
```

You'll be prompted for stack and goal. Stack is auto-detected if `package.json`, `pyproject.toml`, `Cargo.toml`, or `go.mod` exists.

### 2. What happens

avner-init is **additive only** — it never overwrites existing files.

- Files that don't exist → created from templates with your project name, stack, and goal.
- Files that already exist → skipped with a message.
- Council agents → copied to `.claude/agents/` (only if not already there).

### 3. Review skipped files

If you already have a `CLAUDE.md`, avner-init won't touch it. Consider merging AVNER sections manually:

**Key sections to add to an existing CLAUDE.md:**
- Identity (Project, Stack, Goal)
- Council Protocol (G0-G7 gates)
- Modes DSL (the `/mode` commands)
- DNA Safety Rule
- Commit Evidence Lock
- Model routing

**Key sections to add to an existing settings.json:**
- `"autoMemory": false`
- SessionStart hooks (load STATE + MEMORY)
- PreToolUse hooks (commit evidence lock)
- Permissions deny list (rm -rf, git push, etc.)

### 4. Fill in AVNER documents

Even for existing projects, these need human input:

| File | What to write | Why it matters |
|------|--------------|----------------|
| `.avner/MEMORY.md` | Identity, non-goals, sensitive areas | Loaded every session; prevents scope creep |
| `.avner/1_vision/VISION.md` | Target user, problem, metrics | Council checks features against this |
| `.avner/1_vision/REQUIREMENTS.md` | R-id table for current features | Features without R-ids get HALTed |
| `.avner/2_architecture/TECHSTACK.md` | Build/test/lint commands | Hooks and agents use these |

### 5. Gradual migration

You don't need to fill everything at once. Recommended order:

1. **Day 1**: MEMORY.md + VISION.md + REQUIREMENTS.md (minimum viable governance)
2. **Week 1**: ARCHITECTURE.md + TECHSTACK.md (enables verify-spec and verify-ops)
3. **As needed**: API_CONTRACTS.md, DB_SCHEMA.md (when you touch APIs or schema)
4. **For UI work**: UI_SPEC.md via `/ui` (when building frontend)

### 6. Settings.json for non-Node stacks

The default `settings.json` uses npm commands. For other stacks, replace:

| npm command | Python equivalent | Go equivalent | Rust equivalent |
|-------------|-------------------|---------------|-----------------|
| `npm test` | `pytest` | `go test ./...` | `cargo test` |
| `npm run build` | — | `go build ./...` | `cargo build` |
| `npm run lint` | `ruff check .` | `golangci-lint run` | `cargo clippy` |
| `tsc --noEmit` | `mypy .` | — | — |

### 7. Start using

```
/avner          # See governance status and pick a mode
/one-flow       # Full feature delivery workflow
/ui             # Create UI design contract
/ui-review      # Audit implemented UI
```
