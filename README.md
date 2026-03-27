# avner-stack

Reusable developer workflow package for Claude Code. Ships AVNER v7 governance
(gates, Council agents, DNA safety), structured plan reviews, 6-pillar UI contracts,
and an end-to-end feature delivery skill — all as drop-in Claude Code skills and templates.

## What's Included

| Component | Description |
|-----------|-------------|
| `/one-flow` | End-to-end feature delivery: plan → review → build → QA → ship |
| `/avner` | Governance overview, session management, task scoring |
| `/ui` | UI design contract creation (6-pillar spec) |
| `/ui-review` | Retroactive 6-pillar UI audit |
| 5 Council agents | Vision, Spec, Integration, Ops, Security verification |
| 19 templates | Full `.avner/` document scaffolding for any project |
| `setup` | Global installer — symlinks skills to `~/.claude/skills/` |
| `avner-init` | Project onboarding CLI — `--new` or `--project` modes |

## Quick Start

```bash
# 1. Clone
git clone https://github.com/youruser/avner-stack.git
cd avner-stack
git submodule update --init

# 2. Install skills globally
./setup

# 3. Create a new project
./init/avner-init --new my-app

# 4. Open in Claude Code
cd my-app
claude

# 5. Start building
# Type: /one-flow
```

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI
- Git
- Bash (on Windows: Git Bash or WSL)

## Onboarding an Existing Project

```bash
./init/avner-init --project /path/to/existing-project
```

Adds AVNER scaffolding without overwriting existing files. See [docs/ONBOARDING_EXISTING_PROJECT.md](docs/ONBOARDING_EXISTING_PROJECT.md).

## Architecture

```
avner-stack (this repo)
├── skills/          → Claude Code skills (installed globally)
├── agents/          → Council verification agents (copied into projects)
├── templates/       → .avner/ document templates
├── init/            → Project onboarding CLI
└── vendor/          → Reference materials (read-only submodules)
    ├── avner/       → AVNER v7 spec
    ├── gstack/      → GStack plan review + QA workflows
    ├── gsd/         → GSD UI contract patterns
    └── ecc/         → ECC hooks + tooling patterns
```

**Governance layer**: AVNER v7 (gates, Council, DNA safety, commit evidence lock)
**Plan review**: Adapted from GStack (CEO/design/eng review passes)
**UI contracts**: Adapted from GSD (6-pillar spec and audit)
**Hooks/tooling**: Inspired by ECC (session hooks, pre-commit guards)

See [docs/OVERVIEW.md](docs/OVERVIEW.md) for details.

## Documentation

- [docs/OVERVIEW.md](docs/OVERVIEW.md) — Architecture and how components relate
- [docs/ONBOARDING_NEW_PROJECT.md](docs/ONBOARDING_NEW_PROJECT.md) — New project walkthrough
- [docs/ONBOARDING_EXISTING_PROJECT.md](docs/ONBOARDING_EXISTING_PROJECT.md) — Existing project migration

## License

MIT
