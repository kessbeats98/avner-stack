# Onboarding a New Project

## Prerequisites
1. avner-stack cloned and `./setup` run (skills installed globally).
2. Claude Code CLI available.

## Steps

### 1. Create the project

```bash
./init/avner-init --new my-app
```

You'll be prompted for:
- **Stack**: e.g., "Next.js 15, Supabase, Vercel"
- **Goal**: e.g., "Ship a working SaaS with auth, billing, and dashboard"

Or pass them inline:
```bash
./init/avner-init --new my-app --stack "Next.js 15, Supabase" --goal "SaaS MVP with auth and billing"
```

### 2. What gets created

```
my-app/
├── CLAUDE.md                    ← Project constitution
├── .gitignore
├── .claude/
│   ├── settings.json            ← Hooks, permissions, model routing
│   └── agents/                  ← 5 Council verification agents
└── .avner/
    ├── MEMORY.md                ← Fill this first
    ├── LESSONS_*.md             ← Empty, grows over time
    ├── 1_vision/                ← Fill VISION.md and REQUIREMENTS.md
    ├── 2_architecture/          ← Fill after first /core
    ├── 3_contracts/             ← Fill as APIs/DB/UI emerge
    └── 4_operations/            ← STATE.md tracks progress
```

### 3. Fill in the essentials

Open in Claude Code and fill these three files:

**`.avner/MEMORY.md`** — Identity, non-goals, sensitive areas. This loads at every session start.

**`.avner/1_vision/VISION.md`** — Target user, core problem, value prop, metrics. The Council checks everything against this.

**`.avner/1_vision/REQUIREMENTS.md`** — R-id table. Every feature must trace to an R-id or the Council will HALT it.

### 4. Start building

```
/one-flow
```

This walks you through: feature scoping → plan review (CEO/design/eng) → UI contract (if applicable) → implementation → QA → ship.

Or use individual modes:
- `/new` for a single feature
- `/fix` for a bug
- `/avner` for governance overview and task selection

### 5. Settings.json

The generated `settings.json` defaults to npm commands. If your stack isn't Node/TypeScript, edit the permissions allow list to match your build/test/lint commands.

The hooks (session start, commit lock, auto-lint) use Bash. On Windows, use Git Bash or WSL.
