# Overview

avner-stack layers four complementary systems into one Claude Code workflow package.

## Layer Architecture

```
┌─────────────────────────────────────────────┐
│  /one-flow  (unified skill)                 │  ← User entry point
├─────────────────────────────────────────────┤
│  AVNER v7 Governance                        │  ← Gates, Council, DNA Safety
│  Gates: G0 Delete First → G1 Finish First   │
│  Council: Elazar, Eliezer, Yehoshua,        │
│           Yossi, Shimon                      │
│  Lifecycle: Decisions → Plan → Execute →    │
│             Verify                           │
├─────────────────────────────────────────────┤
│  GStack-style Plan Review                   │  ← CEO / Design / Eng passes
│  CEO: scope/ambition (4 modes)              │
│  Design: 7 dimensions rated 0-10            │
│  Eng: architecture + test coverage diagram  │
├─────────────────────────────────────────────┤
│  GSD-style UI Contracts                     │  ← 6-pillar spec + audit
│  /ui: create UI_SPEC.md before building     │
│  /ui-review: audit + score after building   │
│  Pillars: Copy, Visuals, Color, Type,       │
│           Spacing, Experience Design         │
├─────────────────────────────────────────────┤
│  ECC-inspired Hooks & Tooling               │  ← Session, commit, lint hooks
│  SessionStart: restore STATE + MEMORY       │
│  PreToolUse: commit evidence lock           │
│  PostToolUse: auto-lint                     │
└─────────────────────────────────────────────┘
```

## AVNER v7 — Governance

The core governance framework. Defines:

- **Four Worlds (A.B.I.A.)**: Vision (WHY), Architecture (WHAT), Contracts (HOW), Operations (DO). Each has a directory under `.avner/` with specific documents.
- **Council Protocol**: 5 verification agents that gate different modes. Most tasks trigger 0-1 agents. All 5 firing means something significant is happening.
- **Gates (G0-G7)**: Priority-ordered checks before any mode runs. G0 asks "can we delete instead?" G1 blocks new work if something's in progress.
- **DNA Safety Rule**: Constitutional protection for CLAUDE.md, MEMORY.md, STATE.md, and LESSONS files — never auto-modified.
- **Commit Evidence Lock**: PreToolUse hook blocks `git commit` unless `last_vision_check.txt` contains valid APPROVE or FIX-BYPASS evidence.

## GStack — Plan Review

Structured plan review adapted from GStack's sprint workflow skills. Three review passes run during `/one-flow`:

- **CEO Review**: Challenges scope and ambition. Four modes — scope expansion, selective expansion, hold scope, scope reduction.
- **Design Review**: Rates 7 UX dimensions 0-10 (info architecture, interaction states, edge cases, user journey, AI slop risk, empty states, responsive/a11y). Fixes the plan until each is ≥7.
- **Eng Review**: Architecture, code quality, and test coverage analysis. Flags complexity smells (>8 files), traces codepaths, outputs coverage diagram.

## GSD — UI Contracts

UI design contract system adapted from GSD's 6-pillar framework:

- **`/ui` skill**: Creates `UI_SPEC.md` before UI work. Defines design system, spacing scale (8pt grid), typography roles, color system (60/30/10), copywriting contract, and per-screen states.
- **`/ui-review` skill**: Audits implemented UI after work. Scores 6 pillars 1-4, identifies top 3 fixes, records in `UI_REVIEW.md`.
- **6 Pillars**: Copywriting, Visuals, Color, Typography, Spacing, Experience Design.

## ECC — Hooks & Tooling

Session and workflow hooks inspired by ECC patterns:

- **SessionStart**: Auto-loads STATE.md and MEMORY.md into context.
- **PreCompact**: Backs up STATE.md before context compaction.
- **PreToolUse**: Runs lint/typecheck before `git commit`; blocks commit without vision evidence.
- **PostToolUse**: Auto-lints after file edits.
- **SessionEnd**: Reminds to update STATE.md.

## File Structure in Target Projects

After onboarding, a project has:

```
project/
├── CLAUDE.md                        ← Constitution (AVNER v7)
├── .claude/
│   ├── settings.json                ← Hooks, permissions, model routing
│   └── agents/
│       ├── verify-vision.md         ← Elazar
│       ├── verify-spec.md           ← Eliezer
│       ├── verify-integration.md    ← Yehoshua
│       ├── verify-ops.md            ← Yossi
│       └── verify-security.md       ← Shimon
└── .avner/
    ├── MEMORY.md                    ← Project seed, non-goals, decisions
    ├── LESSONS_*.md                 ← Per-world lessons learned
    ├── 1_vision/
    │   ├── VISION.md                ← Target user, value prop, metrics
    │   ├── REQUIREMENTS.md          ← R-id table with traceability
    │   └── GAP_ANALYSIS.md          ← Current vs missing
    ├── 2_architecture/
    │   ├── ARCHITECTURE.md          ← System design, boundaries
    │   └── TECHSTACK.md             ← Stack, commands, skill registry
    ├── 3_contracts/
    │   ├── API_CONTRACTS.md         ← Endpoints, error shapes
    │   ├── DB_SCHEMA.md             ← Tables, migrations
    │   └── UI_SPEC.md               ← 6-pillar design contract
    └── 4_operations/
        ├── STATE.md                 ← Tasks, session continuity
        ├── RUNBOOK.md               ← Deploy checklist, rollback
        └── UI_REVIEW.md             ← 6-pillar audit log
```
