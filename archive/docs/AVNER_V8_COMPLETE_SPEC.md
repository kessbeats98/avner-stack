# AVNER v8 Complete Specification

> **Purpose**: Self-contained master specification. Claude Code reads this single file to implement the full AVNER v8 system end-to-end.
> **Annotations**: [CONFIRMED] = directly sourced · [INFERRED] = reasoned from multiple sources · [MISSING] = not found, proposed for v8
> **Generated**: 2026-03-29

---

## Table of Contents

1. [High-Level Architecture](#1-high-level-architecture)
2. [File and Directory Structure](#2-file-and-directory-structure)
3. [CLAUDE.md Template](#3-claudemd-template)
4. [SKILL.md Definitions](#4-skillmd-definitions)
5. [Gates and Governance Logic](#5-gates-and-governance-logic)
6. [Standard Workflows](#6-standard-workflows)
7. [ECC Integration](#7-ecc-integration)
8. [Council Agent Protocols](#8-council-agent-protocols)
9. [File Format Schemas](#9-file-format-schemas)
10. [Best Practices and Anti-Patterns](#10-best-practices-and-anti-patterns)

---

## 1. High-Level Architecture

### 1.1 System Diagram (ASCII) [CONFIRMED]

```
┌──────────────────────────────────────────────────────────────────────────┐
│  USER  ──→  /one-flow  (unified entry point)                             │
│              or individual mode: /new /fix /pol /sec /deploy /core etc.  │
└────────────────────────────┬─────────────────────────────────────────────┘
                             │
         ┌───────────────────▼──────────────────────────────────────────┐
         │  LAYER 1 — AVNER v8 Governance (Claude Code runs this)        │
         │                                                                │
         │  Gates (sequential, first match wins):                         │
         │    G0 Elon Gate → G1 Finish Before Start → Ambiguity Guard    │
         │    → Safety Interrupt → Security Override → Architect Trigger  │
         │    → Efficiency Downgrade → Execute                            │
         │                                                                │
         │  Council Agents (subagents, read-only):                        │
         │    Elazar (vision) · Eliezer (spec) · Yehoshua (integration)  │
         │    Yossi (ops/deploy) · Shimon (security/veto)                │
         │                                                                │
         │  Lifecycle: Decisions → Plan → Execute → Verify                │
         │  Four Worlds: Vision · Architecture · Contracts · Operations   │
         └───────────────────┬──────────────────────────────────────────┘
                             │
         ┌───────────────────▼──────────────────────────────────────────┐
         │  LAYER 2 — GStack Plan Review (Claude Code orchestrates)       │
         │                                                                │
         │  7-Phase Workflow:                                             │
         │    Think → Plan → Build → Review → Test → Ship → Reflect      │
         │                                                                │
         │  Review Passes (in /one-flow Step 3):                          │
         │    CEO Review (scope/ambition, 4 modes)                        │
         │    Design Review (7 UX dimensions, 0–10 each)                  │
         │    Eng Review (architecture, complexity, test coverage)         │
         │                                                                │
         │  Codex (strategic planner & second opinion):                   │
         │    /codex review   → P1/P2 diff gate                           │
         │    /codex challenge → adversarial mode                         │
         │    /codex <Q>      → consult mode                              │
         └───────────────────┬──────────────────────────────────────────┘
                             │
         ┌───────────────────▼──────────────────────────────────────────┐
         │  LAYER 3 — GSD UI Contracts (Claude Code, single-agent)        │
         │                                                                │
         │  /ui        → Design contract before building (UI_SPEC.md)     │
         │  /ui-review → 6-pillar audit after building (UI_REVIEW.md)     │
         │                                                                │
         │  Pillars: Copywriting · Visuals · Color ·                      │
         │           Typography · Spacing · Experience Design             │
         └───────────────────┬──────────────────────────────────────────┘
                             │
         ┌───────────────────▼──────────────────────────────────────────┐
         │  LAYER 4 — ECC-Inspired Hooks & Tooling (settings.json)        │
         │                                                                │
         │  SessionStart  → restore STATE.md + MEMORY.md                 │
         │  PreCompact    → backup STATE.md                               │
         │  PreToolUse    → commit evidence lock (lint + typecheck +      │
         │                   vision check before git commit)              │
         │  PostToolUse   → auto-lint after file edits                    │
         │  SessionEnd    → remind to update STATE.md                     │
         └──────────────────────────────────────────────────────────────┘
```

### 1.2 The 4 Worlds (AVNER A.B.I.A.) [CONFIRMED]

| World | Directory | Question | Contains |
|-------|-----------|----------|----------|
| **Vision** | `.avner/1_vision/` | WHY we build | VISION.md, REQUIREMENTS.md, GAP_ANALYSIS.md |
| **Architecture** | `.avner/2_architecture/` | WHAT we build | ARCHITECTURE.md, TECHSTACK.md |
| **Contracts** | `.avner/3_contracts/` | HOW we build | API_CONTRACTS.md, DB_SCHEMA.md, UI_SPEC.md |
| **Operations** | `.avner/4_operations/` | DO it safely | STATE.md, RUNBOOK.md, UI_REVIEW.md |

### 1.3 The 7-Phase GStack Workflow [CONFIRMED]

| Phase | Activity | Who Runs It |
|-------|----------|-------------|
| **Think** | `/ codex <question>` — investigate, explore, consult | Claude Code invokes Codex |
| **Plan** | Decisions + Plan sections, GStack reviews | Claude Code (with Codex optional) |
| **Build** | Implement tasks, lint, typecheck per task | Claude Code (primary executor) |
| **Review** | `/codex review`, `/review`, Council gates | Claude Code + Codex second opinion |
| **Test** | TDD, 80% coverage, verify commands | Claude Code |
| **Ship** | `/deploy`, verify-ops, verify-security | Claude Code (Council mandatory) |
| **Reflect** | Update STATE.md, LESSONS, handoff block | Claude Code (user approval required) |

### 1.4 Where ECC Hooks Fit In [CONFIRMED]

ECC hooks operate at the **infrastructure layer** (Layer 4). They fire automatically via `.claude/settings.json` — they do not require explicit invocation. Key integration points:

- **Pre-commit**: The `PreToolUse` hook intercepts every `git commit` command. It runs lint + typecheck AND checks `last_vision_check.txt` for valid `APPROVE` or `FIX-BYPASS` token. Missing token = commit blocked (exit 2).
- **Post-edit**: The `PostToolUse` hook on `Edit|Write|MultiEdit` events runs `npm run lint` automatically.
- **Session lifecycle**: `SessionStart` restores context; `SessionEnd` reminds about STATE.md; `PreCompact` backs up STATE.md.
- **block-no-verify**: Prevents `git commit --no-verify` from bypassing hooks.

### 1.5 Where GSD UI Design/Review Fits In [CONFIRMED]

GSD UI sits in Layer 3. It activates at two points inside `/one-flow`:

- **Step 4 (UI Gate)**: Before any implementation, if the plan touches UI files → run `/ui` → get `UI_SPEC.md` approved.
- **Step 6 (UI Review)**: After implementation → run `/ui-review` → score 6 pillars → append entry to `UI_REVIEW.md` with user approval.

Standalone: `/ui` and `/ui-review` can be invoked independently at any time.

### 1.6 Role Division: Claude Code vs Codex [CONFIRMED]

| System | Claude Code's Role | Codex's Role |
|--------|-------------------|--------------|
| **Primary executor** | Writes all code, manages files, runs all commands | Never writes files (read-only sandbox) |
| **Governance** | Runs all gates, invokes Council agents | No role |
| **Plan review** | Runs CEO Review, Design Review, Eng Review in-session | Runs `/codex review` as external diff gate |
| **Security** | Invokes Shimon (verify-security) | `/codex challenge` — adversarial edge-case finder |
| **Second opinion** | Claude's own `/review` sweep | Independent Codex diff review — model diversity |
| **Consult** | — | `/codex <question>` — "200 IQ autistic developer" persona |
| **Session continuity** | STATE.md + MEMORY.md | `.context/codex-session-id` |

**Key principle**: Claude Code is the single executor and governor. Codex is a read-only second opinion and strategic challenger. They complement rather than duplicate each other.

---

## 2. File and Directory Structure

### 2.1 Complete Project Tree [CONFIRMED]

```
project-root/
│
├── CLAUDE.md                                    ← Project constitution (DNA protected)
│
├── .claude/
│   ├── settings.json                            ← Hooks, permissions, model routing
│   ├── rules/
│   │   ├── 01-protocol.md                       ← Lifecycle, gates, verification artifact
│   │   └── 02-models.md                         ← Model routing table + context pressure
│   ├── skills/
│   │   ├── avner/SKILL.md                       ← /avner governance overview
│   │   ├── one-flow/SKILL.md                    ← /one-flow end-to-end delivery (7 steps)
│   │   ├── new/SKILL.md                         ← /new feature mode
│   │   ├── fix/SKILL.md                         ← /fix bug mode
│   │   ├── pol/SKILL.md                         ← /pol polish mode
│   │   ├── sec/SKILL.md                         ← /sec security mode
│   │   ├── deploy/SKILL.md                      ← /deploy ship mode
│   │   ├── core/SKILL.md                        ← /core architecture mode
│   │   ├── research/SKILL.md                    ← /research investigation mode
│   │   ├── review/SKILL.md                      ← /review handoff + sweep
│   │   ├── save/SKILL.md                        ← /save WIP mode
│   │   ├── prune/SKILL.md                       ← /prune delete-first mode
│   │   ├── ui/SKILL.md                          ← /ui design contract
│   │   └── ui-review/SKILL.md                   ← /ui-review 6-pillar audit
│   └── agents/
│       ├── verify-vision.md                     ← Elazar: Vision Gate
│       ├── verify-spec.md                       ← Eliezer: Spec Guardian
│       ├── verify-integration.md                ← Yehoshua: Integration Check
│       ├── verify-ops.md                        ← Yossi: SRE / Deploy
│       └── verify-security.md                   ← Shimon: CISO / Veto
│
├── .avner/
│   ├── MEMORY.md                                ← Project seed (DNA protected, max 200 lines)
│   ├── AGENT_CONSTITUTION.md                    ← Agent identity/constraints (v7.0+)
│   ├── LESSONS_VISION.md                        ← Lessons from vision phase (DNA protected)
│   ├── LESSONS_ARCHITECTURE.md                  ← Lessons from architecture phase (DNA protected)
│   ├── LESSONS_CONTRACTS.md                     ← Lessons from contracts phase (DNA protected)
│   ├── LESSONS_OPERATIONS.md                    ← Lessons from operations phase (DNA protected)
│   │
│   ├── 1_vision/                                ← World 1: WHY
│   │   ├── VISION.md                            ← Target user, value prop, north-star metrics
│   │   ├── REQUIREMENTS.md                      ← R-id table with owners and evidence
│   │   └── GAP_ANALYSIS.md                      ← Current capabilities vs. missing
│   │
│   ├── 2_architecture/                          ← World 2: WHAT
│   │   ├── ARCHITECTURE.md                      ← System design, component diagram, data flow
│   │   └── TECHSTACK.md                         ← Stack table, commands, skill registry
│   │
│   ├── 3_contracts/                             ← World 3: HOW
│   │   ├── API_CONTRACTS.md                     ← Endpoints, error shapes, versioning policy
│   │   ├── DB_SCHEMA.md                         ← Tables, migrations, relationships
│   │   └── UI_SPEC.md                           ← 6-pillar UI design contract (DNA protected)
│   │
│   └── 4_operations/                            ← World 4: DO
│       ├── STATE.md                             ← Tasks, session continuity (DNA protected)
│       ├── RUNBOOK.md                           ← Deploy checklist, rollback procedure
│       ├── UI_REVIEW.md                         ← 6-pillar audit log (DNA protected)
│       ├── last_vision_check.txt                ← Commit evidence lock file
│       └── STATE.md.bak                         ← Auto-backup before compaction
│
├── vendor/
│   ├── gstack/                                  ← GStack skill library (plan reviews, codex)
│   │   ├── ARCHITECTURE.md                      ← GStack system design docs
│   │   ├── ETHOS.md                             ← GStack principles
│   │   └── codex/SKILL.md                       ← /codex skill definition
│   ├── gsd/                                     ← GSD UI framework
│   │   └── get-shit-done/                       ← GSD workflows and templates
│   └── ecc/                                     ← ECC hooks library
│       ├── .claude-plugin/plugin.json           ← Claude Code plugin manifest
│       ├── .cursor/hooks/                       ← Cursor hook scripts (Node.js)
│       └── scripts/hooks/                       ← Core hook implementations
│
├── .context/
│   └── codex-session-id                         ← Codex session continuity token
│
└── src/ (or app/, lib/, etc.)                   ← Project source code
```

### 2.2 File Purpose Reference

| File | Format | Purpose | DNA Protected? |
|------|--------|---------|---------------|
| `CLAUDE.md` | Markdown | Project constitution: identity, modes, rules, protocol | YES |
| `.claude/settings.json` | JSON | Hooks, permission allow/deny lists, model default | NO |
| `.claude/rules/01-protocol.md` | Markdown | Lifecycle gates, verification artifact format | NO |
| `.claude/rules/02-models.md` | Markdown | Model routing table, context pressure thresholds | NO |
| `.claude/skills/*/SKILL.md` | Markdown with YAML frontmatter | Skill instruction sets, loaded when mode invoked | NO |
| `.claude/agents/*.md` | Markdown | Council agent constitutions (read-only subagents) | NO |
| `.avner/MEMORY.md` | Markdown | Project seed: identity, non-goals, key decisions, lessons | YES |
| `.avner/AGENT_CONSTITUTION.md` | Markdown | Agent identity, behavioral constraints | NO |
| `.avner/LESSONS_*.md` (×4) | Markdown | Domain-specific learned lessons | YES |
| `.avner/1_vision/VISION.md` | Markdown | Target user, problem, value prop, north-star metrics | NO |
| `.avner/1_vision/REQUIREMENTS.md` | Markdown | R-id table: requirement, acceptance, priority, owner, evidence | NO |
| `.avner/1_vision/GAP_ANALYSIS.md` | Markdown | Current vs. missing capabilities, sprint focus | NO |
| `.avner/2_architecture/ARCHITECTURE.md` | Markdown | System design, component diagram, data flow, key decisions | NO |
| `.avner/2_architecture/TECHSTACK.md` | Markdown | Stack table, commands table, skill registry | NO |
| `.avner/3_contracts/API_CONTRACTS.md` | Markdown | Endpoints, error shapes, versioning policy | NO |
| `.avner/3_contracts/DB_SCHEMA.md` | Markdown | Tables, columns, indexes, relationships, migration log | NO |
| `.avner/3_contracts/UI_SPEC.md` | Markdown | 6-pillar UI design contract (generated by /ui) | YES |
| `.avner/4_operations/STATE.md` | Markdown | Task list, session continuity, deploy log | YES |
| `.avner/4_operations/RUNBOOK.md` | Markdown | Deploy checklist, rollback procedure, smoke tests | NO |
| `.avner/4_operations/UI_REVIEW.md` | Markdown | Appended-only 6-pillar audit log (generated by /ui-review) | YES |
| `.avner/4_operations/last_vision_check.txt` | Plain text | One-line commit evidence: `APPROVE <ts>` or `FIX-BYPASS <ts>` | NO |
| `.avner/4_operations/STATE.md.bak` | Markdown | Auto-backup of STATE.md before context compaction | NO |

---

## 3. CLAUDE.md Template

> Complete, ready-to-use. Place at project root. Replace `{{PLACEHOLDER}}` values.

```markdown
# AVNER v8.0 — One-Dev Software House
# Stack: AVNER v7 + GStack Plan Review + GSD UI + ECC Hooks + Codex Second Opinion

## Quick Start (5 minutes)
1. Fill in Identity below.
2. Write .avner/MEMORY.md — identity, non-goals, sensitive areas.
3. Write .avner/1_vision/VISION.md — target user, core problem, north-star metrics.
4. Write .avner/1_vision/REQUIREMENTS.md — R-id table with owners and evidence.
5. Start with /one-flow for full plan-to-ship workflow, or /fix for immediate bugs.

## Identity
- Project:  {{PROJECT_NAME}}
- Stack:    {{STACK}}
- Goal:     {{GOAL — one sentence, production-ready definition}}

## Worlds (A.B.I.A)
- Vision:    .avner/1_vision/        (WHY — target user, requirements, gaps)
- Arch:      .avner/2_architecture/  (WHAT — system design, tech stack)
- Contracts: .avner/3_contracts/     (HOW — APIs, DB schema, UI spec)
- Ops:       .avner/4_operations/    (DO  — tasks, runbook, reviews)

## Skill Load Order
Skills are loaded in this priority order when a session starts:
1. CLAUDE.md (always in context)
2. .claude/rules/01-protocol.md (gates, lifecycle, verification artifact)
3. .claude/rules/02-models.md (model routing, context pressure)
4. Invoked skill SKILL.md (e.g., .claude/skills/new/SKILL.md)
5. Council agents (only when triggered by gates — subagents)
6. GStack skills (only when explicitly invoked: /codex, /plan-eng-review, etc.)

## The Council (AVNER Verification Agents)
- Elazar   (Vision Gate):        .claude/agents/verify-vision.md       100% of /new and /core
- Eliezer  (Spec Guardian):      .claude/agents/verify-spec.md         ~15% of tasks
- Yehoshua (Integration Check):  .claude/agents/verify-integration.md  invoked by Yossi
- Yossi    (SRE / Deploy):       .claude/agents/verify-ops.md          /deploy only
- Shimon   (CISO / Veto):        .claude/agents/verify-security.md     /deploy + sensitive

Most tasks trigger 0-1 Council members. All 5 firing = something big is happening.

## External Reviewers (GStack + Codex)
- /codex review       — Independent Codex diff review (P1 = FAIL, blocks shipping)
- /codex challenge    — Adversarial "200 IQ autistic developer" mode
- /codex <question>   — Consult mode with session continuity
- /plan-ceo-review    — GStack scope & ambition pass (4 modes)
- /plan-eng-review    — GStack architecture & test coverage pass
- /plan-design-review — GStack UX/UI 7-dimension pass (0-10 each)

These are OPTIONAL. Use /one-flow to get CEO/Design/Eng review inline.
Use /codex after implementation for independent second opinion.
Codex requires: npm install -g @openai/codex

## Modes (DSL — AVNER)
/prune    → Remove dead code, features, or requirements (DELETE FIRST)
/new      → New feature or file
/fix      → Bugfix or logic correction
/pol      → Polish only (zero logic changes)
/sec      → Security review or hardening
/deploy   → Ship to production
/core     → Deep schema / API / architecture work
/research → Pre-build investigation (unfamiliar tech, uncertain approach)
/review   → Reflect, sweep, health check, handoff
/save     → Save work-in-progress and push
/avner    → Governance overview, task selection, session start
/one-flow → End-to-end feature delivery (plan → review → build → QA → ship)
/ui       → Create or update UI design contract (UI_SPEC.md)
/ui-review → Retroactive 6-pillar UI audit (UI_REVIEW.md)

## GStack Modes (optional — plan review layer)
/plan-ceo-review    → Scope & ambition pass on a plan
/plan-eng-review    → Architecture, complexity, test coverage pass
/plan-design-review → UX/UI gaps pass (7 dimensions, 0-10 each)
/codex review       → Independent Codex CLI diff review (P1 = FAIL)
/codex challenge    → Adversarial Codex review
/codex <question>   → Ask Codex anything with session continuity

## Council Protocol (Meta-Priority — first match wins)
0. The Elon Gate       → Delete First? Can this be solved by removing? → /prune
1. Finish Before Start → STATE.md has IN PROGRESS task? REFUSE new TASK/FEAT.
   Say: "⛔ G1 Block: Complete [TASK-XX] before starting new work."
   Exceptions: (a) P0 bugs bypass. (b) /deploy and /sec ALWAYS bypass.
2. Ambiguity Guard     → Vague intent? HALT. Ask one clarifying question.
3. Safety Interrupt    → Unknown impact? HALT.
4. Security Override   → Sensitive areas touched? Escalate to /sec.
5. Architect Trigger   → DB / public API / global state touched? Escalate to /core.
6. Efficiency Downgrade → Overkill detected? Prefer boring, minimal change.
7. Execute             → Run the mode.

## Risk Tiers
- High:   auth, payments, secrets, DB schema, public API, global state, deploy configs
- Medium: business logic, data transforms, UI state, service integrations
- Low:    docs, tests-only, comments, formatting, config labels

High-risk paths → Council is mandatory. Medium → recommended. Low → skip.

## Lifecycle (every /new and /core must produce)
Decisions → Plan → Execute → Verify
Four mandatory output sections.

## Verification Artifact
  Commands run:    [exact commands executed]
  Expected result: [what passing looks like]
  Observed result: [what actually happened]
  Remaining risk:  [known open gaps + why accepted]

/fix and /deploy: MUST always end with this block.
/new, /sec, /core, /review: SHOULD include when non-trivial.

## Commit Format
Every commit Claude creates MUST include this trailer (last line):
  Co-Authored-By: Claude <noreply@anthropic.com>

Patterns by mode:
- /new:    feat(scope): description
- /fix:    fix(scope): description
- /core:   refactor(scope): description
- /sec:    sec(scope): mitigation description
- /deploy: chore(deploy): v[version] — what shipped
- /pol:    style(scope): what was polished
- /save:   wip(TASK-XX): progress summary

## Commit Evidence Lock
Before committing, evidence must exist in .avner/4_operations/last_vision_check.txt:
- /new and /core: APPROVE <timestamp> (written after verify-vision APPROVE)
- /fix: FIX-BYPASS <timestamp> (written before commit)
PreToolUse hook blocks git commit if file is missing or invalid.

## Models
- Opus 4.6     → /sec, vision decisions, Elazar (verify-vision), Shimon (verify-security)
- opusplan     → /core, /review (Opus for Decisions/Plan, Sonnet for Execute)
- Sonnet 4.6   → /new, /fix, /deploy, /research, /prune, /ui, /ui-review, Eliezer, Yehoshua, Yossi
- Haiku 4.5    → /pol, quick reads, searches, formatting

Codex uses its own frontier model. No override needed.

## Context Pressure
- > 70% context: minimal scope, one task at a time, consider /compact
- > 90% context: Haiku for reads; run /compact; smallest step only

## DNA Safety Rule (חוק יסוד)
Claude NEVER modifies these files without explicit user approval + visible diffs:
- CLAUDE.md (constitution)
- .avner/MEMORY.md (permanent memory)
- .avner/4_operations/STATE.md (session state)
- .avner/4_operations/UI_REVIEW.md (UI audit log)
- .avner/3_contracts/UI_SPEC.md (UI design contract)
- .avner/*/LESSONS_*.md (all four lessons files)

Auto Memory is disabled. All "learned rules" must be proposed in-chat.
Hooks may READ these files. Hooks may REMIND. Hooks NEVER WRITE.

NOTE: Hooks rely on Bash. On Windows, use Git Bash or WSL.

## Permission Deny List (enforced by settings.json)
These commands are permanently blocked:
- .env              — never read secrets
- rm -rf / rm -r   — no recursive deletion
- sudo              — no privilege escalation
- curl * | bash    — no remote code execution
- git push *       — no unauthorized pushes
- git reset --hard * — no hard resets
- git checkout -- * — no file overwrites

## Air-Gap Rule
External community skills are STRICTLY PROHIBITED (supply-chain risk).
No npx skills add url --skill find-skills or similar.
Only local ./skills/ and official avner-stack + gstack skills permitted.
TECHSTACK.md Internal Skill Registry is the authoritative list.

## Browse Binary Setup
Claude Code's browser tool (used by /qa and /design-review) requires:
- In /qa mode: `npx playwright install` (if screenshots needed)
- In /ui-review mode: screenshots from localhost:3000 / :5173 / :8080

## Test/Build/Deploy Commands
Customize to your stack in TECHSTACK.md. Defaults:
- Test:        npm test
- Build:       npm run build
- Lint:        npm run lint
- Type check:  tsc --noEmit
- Dev server:  tmux new-session -d -s dev "npm run dev"  ← ALWAYS use tmux

Non-Node.js equivalents:
- Python:  pytest / ruff check . / mypy .
- Go:      go test ./... / go build ./... / golangci-lint run
- Rust:    cargo test / cargo build / cargo clippy

## Design System Reference
Always read .avner/3_contracts/UI_SPEC.md before making any visual or UI decisions.
All font choices, colors, spacing, and aesthetic direction are defined there.
Do not deviate without explicit user approval.
In /ui-review mode, flag any code that doesn't match UI_SPEC.md.

## ECC Coding Conventions (hook-enforced)
### Code Style
- Always create new objects — never mutate existing ones (immutability is critical)
- Files: 200-400 lines typical, 800 lines max; organize by feature/domain
- Handle errors explicitly at every level; never silently swallow errors
- Validate all user input at system boundaries

### Commits
- Use conventional commit format: <type>: <description>
- Types: feat, fix, refactor, docs, test, chore, perf, ci

### Testing
- Minimum 80% test coverage (unit + integration + E2E required)
- Write tests first (TDD): RED → GREEN → IMPROVE

### Security
- Never hardcode secrets — always use environment variables
- Run npm audit before committing

### Dev Servers
- Always run dev servers in tmux: tmux new-session -d -s dev "npm run dev"
- Never run npm run dev directly (hook blocks it)

> One rule to keep CLAUDE.md honest:
> "Would removing this line cause mistakes? If not — cut it."
```

---

## 4. SKILL.md Definitions

### 4.1 `/avner` — Main Governance Skill [CONFIRMED + INFERRED]

```markdown
---
name: avner
description: AVNER governance overview. Session start, task selection, gate status, STATE management.
invocation: manual
model: sonnet
---

# /avner — Governance Manager

Show the current project state and help the user pick the next action.
This is the session-start skill. Run it when starting a new session.

## When Invoked

### Step 1: Read Context
- Read `.avner/4_operations/STATE.md` — identify tasks (IN PROGRESS, REVIEW, PLANNED, PAUSED)
- Read `.avner/MEMORY.md` — identity, non-goals, key decisions
- Read `.avner/1_vision/REQUIREMENTS.md` — R-id table and priorities

### Step 2: Run Gate Check
- G0: Is there anything that should be deleted instead of built? Flag if yes.
- G1: Is any task IN PROGRESS? If yes → remind user to complete before starting new work.
- Scan MEMORY.md non-goals: does any planned work violate them?

### Step 3: Present Project Status
Format a clear summary:

```
AVNER v8 — [PROJECT_NAME]
Phase: [Vision / Architecture / Contracts / Operations]
Version: [commit hash or tag]

IN PROGRESS:
  TASK-XX: [title] — stopped at [point]
  Next action: [what to run first]

READY TO START:
  TASK-YY (P0): [title] — [one-line description]
  TASK-ZZ (P1): [title] — [one-line description]

BACKLOG:
  [count] tasks pending — use /avner backlog to see all

LAST DEPLOY: [date] v[version] — [status]

OPEN QUESTIONS: [any unresolved decisions]
```

### Step 4: Suggest Next Action
Based on the state, recommend:
- If IN PROGRESS exists: "Resume TASK-XX with /fix or /one-flow"
- If P0 task is PLANNED: "Start TASK-YY — P0 priority, use /new or /one-flow"
- If no tasks: "All caught up — consider /review for a health check"

### Subcommands
/avner next      → Score and recommend highest-priority task (status + priority weight)
/avner backlog   → Show all PLANNED tasks sorted by priority
/avner status    → Show full STATE.md summary
/avner gates     → Show which gates are currently active
/avner council   → Show Council members and when they fire

## Task Scoring (for /avner next)
Score = status_weight + priority_weight
Status weights: IN PROGRESS (100), REVIEW (80), PLANNED (50), PAUSED (30)
Priority weights: P0 (40), P1 (30), P2 (20), P3 (10)
Highest score = recommended next task.

## Output
- Always show a clear recommended action.
- Never start implementing — /avner is read-only and planning-only.
- If no MEMORY.md or STATE.md exists → tell user to run onboarding.
```

---

### 4.2 `/one-flow` — Unified Workflow Skill [CONFIRMED]

```markdown
---
name: one-flow
description: End-to-end feature delivery. Plan → Review → Build → QA → Ship in 7 steps.
invocation: manual
model: sonnet
---

# /one-flow — End-to-End Feature Delivery

Full lifecycle for a feature, bugfix, or UI task. 7 steps, all gates enforced.
Entry point for all non-trivial work. Use /fix for simple bugs, /new for small features.

## Preconditions
- Read `.avner/4_operations/STATE.md` before starting (G0, G1 check)
- Read `.avner/MEMORY.md` (non-goals, sensitive areas)
- Read `.avner/1_vision/REQUIREMENTS.md` (R-id table)

---

## Step 0: Gate Check

Run G0 and G1 before anything else.

**G0 (Elon Gate)**: Can the user's goal be achieved by removing something?
- If yes: redirect to /prune. Do not continue.
- If no: proceed.

**G1 (Finish Before Start)**: Does STATE.md have any task with status IN PROGRESS?
- If yes: REFUSE. Say: "⛔ G1 Block: Complete [TASK-XX] before starting new work."
- Exceptions: P0 bugs, /deploy, /sec bypass G1.
- If no: proceed.

---

## Step 1: Input & Framing

**1a. Capture input**
- What is the user trying to build or fix?
- Which R-ids from REQUIREMENTS.md does this map to?
- If no R-id match: HALT — "This task doesn't map to an R-id. Add it to REQUIREMENTS.md first or clarify scope."

**1b. Scope check**
- Does this violate MEMORY.md non-goals? → HALT if yes.
- Is scope clear? → If vague, ask ONE clarifying question (Ambiguity Guard).

**1c. Six Forcing Questions (if user is unsure of need)**
1. Demand Reality: What's the strongest evidence someone wants this?
2. Status Quo: What are users doing right now to solve this?
3. Desperate Specificity: Name the actual human who needs this most.
4. Narrowest Wedge: What's the smallest version someone would use — this week?
5. Observation: Have you watched someone try to do this without help?
6. Future-Fit: In 3 years, does this become more essential or less?

Push once on each answer. First answers are polished; real answers come after follow-up.

---

## Step 2: Plan (Decisions + Plan Sections)

**Decisions section** (mandatory for /new and /core):
- What: What are we building?
- Why: Which R-ids does this address?
- How: Key technical approach (not step-by-step — just the approach)
- Risk: What could go wrong? Which risk tier (High/Medium/Low)?
- Not doing: What's explicitly out of scope?

**Plan section** (atomic tasks):
- Maximum 7 tasks for features, maximum 3 for bugs
- Each task must have: description, files to touch, verify command, risk tier
- One logical change = one task = one commit
- Never mix feat + fix + refactor in one task

---

## Step 3: Plan Review (GStack-style)

Run all three review passes on the plan before coding.

### 3a. CEO Review (Scope & Ambition)
Detect context mode:
- Greenfield (new project/feature) → SCOPE EXPANSION: What's 10x more ambitious for 2x effort?
- Enhancement (improving existing) → SELECTIVE EXPANSION: Hold scope + cherry-pick expansions
- Bug fix / hotfix → HOLD SCOPE: Maximum rigor, minimum change
- Overbuilt (too complex) → SCOPE REDUCTION: Strip to essentials

Checks:
- Premise challenge: Is this the right problem? What if we did nothing?
- Existing code leverage: What already exists to reuse?
- Temporal check: What must be decided NOW vs. can wait?

### 3b. Design Review (7 UX Dimensions, 0–10)
Rate each 0–10. For any dimension below 8, explain what would make it a 10.
Fix the plan to address any dimension below 7.

| # | Dimension | What to Check |
|---|-----------|---------------|
| 1 | Information Architecture | What does user see first/second/third? |
| 2 | Interaction State Coverage | Loading, empty, error, success, partial defined? |
| 3 | Edge Cases | Long names, zero results, network fails, colorblind, RTL? |
| 4 | User Journey | Emotional arc? Where does it break? |
| 5 | AI Slop Risk | Generic card grids? Hero sections? Looks like every AI site? |
| 6 | Empty States | "No items found" or designed with warmth + CTA? |
| 7 | Responsive & Accessibility | Per viewport? Keyboard nav, contrast, touch targets? |

### 3c. Eng Review (Architecture & Tests)
Checks:
- Complexity smell: >8 files or 2+ new classes? Challenge it.
- Existing code leverage: Does the framework have a built-in for each pattern?
- Architecture: System design, dependency graph, data flow, failure scenarios
- Test coverage: Trace every codepath → check against tests → flag gaps

Test quality: ★★★ = edge cases + error paths | ★★ = happy path | ★ = smoke test
Findings: AUTO-FIX (mechanical, do it) or ASK (needs user judgment)

---

## Step 4: UI Contract (conditional — skip if no UI)

- Detect: do any planned tasks touch UI files (components, pages, layouts, styles)?
- If YES: Check if in-scope screens are already defined in `.avner/3_contracts/UI_SPEC.md`.
  - If missing: run the `/ui` workflow inline → get user approval → then proceed to Step 5.
  - If present: confirm spec is current before proceeding.
- If NO: Skip to Step 5.

**DNA Safety Rule**: Show proposed UI_SPEC.md changes + get explicit approval before writing.

---

## Step 5: Execute

**5a. Vision Evidence**
- Run verify-vision (Elazar) as subagent with plan context. [CONFIRMED: 100% of /new and /core]
- If APPROVE: write `echo "APPROVE $(date +%s)" > .avner/4_operations/last_vision_check.txt`
- If HALT: stop. Show Elazar's clarifying question to user.
- If SOLVE-BY-REMOVAL: redirect to /prune.
- For /fix: write `echo "FIX-BYPASS $(date +%s)" > .avner/4_operations/last_vision_check.txt` (skip Elazar)

**5b. Implement Each Task**
For each atomic task:
1. Implement changes (max 5 files per task)
2. Run verify command from plan
3. Run lint: `npm run lint 2>/dev/null || true`
4. Run typecheck: `tsc --noEmit 2>/dev/null || true`
5. Run `git diff --staged` — verify no unintended changes
6. Commit: `<type>(scope): description` + `Co-Authored-By: Claude <noreply@anthropic.com>`

**5c. Spec Check (G2 Gate)**
- After any task that touches DB schema, public API signatures, or global state:
  - Invoke verify-spec (Eliezer) as subagent
  - If ESCALATE-TO-CORE: pause → inform user → switch to /core

---

## Step 6: UI Review (conditional — skip if Step 4 skipped)

Run `/ui-review` workflow:
- Score 6 pillars (1–4 each, total /24)
- Present Top 3 priority fixes
- Append entry to `.avner/4_operations/UI_REVIEW.md`
- **DNA Safety Rule**: Show proposed entry + get approval before appending.

---

## Step 7: Review & Ship

**7a. Verification Artifact**
```
Commands run:    [exact commands with output]
Expected result: [what passing looks like]
Observed result: [what actually happened]
Remaining risk:  [known gaps + why accepted]
```

**7b. Pre-ship Review (if shipping)**
- SQL safety: no raw string interpolation in queries
- Race conditions: concurrent write paths handled?
- Auth boundaries: every route checked?
- Enum completeness: all cases covered in switch/if-else?

**7c. Deploy Gates (only if /deploy)**
- verify-ops (Yossi): GO / NO-GO / CONDITIONAL-GO
- verify-security (Shimon): GO / NO-GO / NEEDS-MITIGATION
- Both must return GO. Shimon NO-GO = hard stop. No exceptions.
- Optionally: /codex review before shipping.

**7d. Update STATE.md + LESSONS (with user approval)**
DNA Safety Rule applies. Show diff → get approval → write.

**7e. Handoff Block**
```
1. What changed:        [files modified, features added/fixed, commits made]
2. What did NOT change: [explicitly deferred items]
3. Validation results:  [commands run + outcomes]
4. Remaining risks:     [known bugs, untested paths, open questions]
5. Next recommended action: [exact first step for next session]
```
```

---

### 4.3 `/ui` — UI Design Contract Skill [CONFIRMED]

```markdown
---
name: ui
description: Create or update .avner/3_contracts/UI_SPEC.md before UI work.
invocation: manual
model: sonnet
---

# /ui — UI Design Contract

Create or update the UI design contract before implementing UI changes.
This ensures all screens have defined states, copy, layout, and pillar compliance.

## Preconditions
- `.avner/1_vision/REQUIREMENTS.md` must exist. If missing, tell the user to run onboarding.
- Run this BEFORE `/new` or `/one-flow` executes UI changes.
- If `.avner/3_contracts/UI_SPEC.md` already has sections for in-scope screens,
  confirm with the user whether to update or skip.

## When Invoked

### Step 1: Scope
Ask the user:
- Which feature/task is in scope?
- Which UI surfaces are affected (screens, modals, flows)?
- Which R-ids from REQUIREMENTS.md does this deliver?

If user is unsure of need, run the Six Forcing Questions:
1. Demand Reality — strongest evidence someone wants this?
2. Status Quo — what are users doing right now without this?
3. Desperate Specificity — name one real human who needs this most.
4. Narrowest Wedge — smallest version someone would actually use this week?
5. Observation — have you watched someone try to do this without help?
6. Future-Fit — in 3 years, more essential or less?

Push once on each answer. First answers are polished; real answers come after follow-up.

### Step 2: Load Context
- Read `.avner/1_vision/REQUIREMENTS.md` — extract relevant R-ids.
- Read `.avner/2_architecture/ARCHITECTURE.md` — understand component structure.
- Read `.avner/3_contracts/UI_SPEC.md` if it exists — check what's already defined.
- Read `.avner/2_architecture/TECHSTACK.md` — detect component library, design tokens.

### Step 3: Detect Design System State
Scan the codebase before asking:
```bash
ls components.json tailwind.config.* postcss.config.* 2>/dev/null
grep -r "spacing\|fontSize\|colors\|fontFamily" tailwind.config.* 2>/dev/null
find src -name "*.tsx" -path "*/components/*" 2>/dev/null | head -20
test -f components.json && npx shadcn info 2>/dev/null
```

If no design system detected and project is React/Next.js/Vite:
Recommend shadcn/ui initialization. Ask: "Initialize shadcn now? [Y/n]"
- If Y: instruct user to configure preset at ui.shadcn.com/create, then `npx shadcn init`.
- If N: document "custom design system" in spec.

If design system already exists: extract tokens and confirm with user.

### Step 4: Build Spec Sections

For each in-scope screen, create or update a section in UI_SPEC.md.
All items below are mandatory per screen:
1. Screen name and description
2. Related R-ids (from REQUIREMENTS.md)
3. Layout — zones (header/sidebar/main/footer), hierarchy, key components
4. States — all 5 mandatory:
   - Default: what the user sees on first load
   - Loading: skeleton / spinner / progressive reveal
   - Error: inline / toast / full-page + copy
   - Empty: illustration + CTA / minimal text + copy
   - Disabled: which elements, when, why
5. Copy — all 4 mandatory:
   - Primary CTA: verb + object, NEVER "Submit", "OK", "Save"
   - Empty state: [what's missing] + [how to fix]
   - Error state: [what went wrong] + [what to do]
   - Destructive confirmation: [consequence] + [action name]
6. Components and variants — library name + specific variants
7. Accessibility — keyboard nav, screen reader labels, WCAG contrast level
8. Responsive — breakpoints (mobile/tablet/desktop), layout shifts

### Step 5: Validate — 6-Pillar Checker

Before finishing, check the spec against all 6 pillars:

| # | Pillar | Pass Criteria |
|---|--------|---------------|
| 1 | Copywriting | No generic labels. All states have copy. CTAs are verb+noun. |
| 2 | Visuals | Focal point declared. Visual hierarchy explicit. Icons have labels. |
| 3 | Color | 60/30/10 split declared. Accent reserved for specific elements. |
| 4 | Typography | Max 4 font sizes. Max 2 font weights. Roles defined. |
| 5 | Spacing | All values multiples of 4. Token scale used. No arbitrary px. |
| 6 | Experience Design | All 5 states (default/loading/error/empty/disabled) defined per screen. |

If any pillar has gaps → fix them before marking spec complete.

### Step 6: Write
- Open or create `.avner/3_contracts/UI_SPEC.md`.
- Add or update sections for in-scope screens.
- Ensure clear mapping: R-ids → screens → states.
- Update the Checker Sign-Off section at the bottom.

**DNA Safety Rule**: `.avner/3_contracts/UI_SPEC.md` is a contract file.
Show the user the proposed changes and get approval before writing.

### Output
Confirm to the user:
- Which screens were added/updated.
- Which R-ids are now covered.
- Any design decisions that need human input (flag as open questions).
- Next step: "UI_SPEC is ready. Proceed with /new or /one-flow to implement."

## R-id Parsing Rules
R-ids are in the format `R1`, `R2`, etc. from the V1 table in REQUIREMENTS.md.
When referencing R-ids in UI_SPEC.md, use exact IDs as they appear in that table.
```

---

### 4.4 `/ui-review` — UI Review Skill [CONFIRMED]

```markdown
---
name: ui-review
description: Review implemented UI against UI_SPEC and record pillar scores + top fixes.
invocation: manual
model: sonnet
---

# /ui-review — 6-Pillar UI Audit

Retroactive visual audit of implemented UI. Compares code to UI_SPEC.md,
scores 6 pillars, and records findings in UI_REVIEW.md.

## Preconditions
- `.avner/3_contracts/UI_SPEC.md` must exist. If missing, tell the user to run `/ui` first.
- `.avner/1_vision/REQUIREMENTS.md` must exist for R-id traceability.

## When Invoked

### Step 1: Scope
Ask the user:
- Which screens/flows to audit?
- Input mode (pick one):
  - Screenshots or live URLs (if dev server running at localhost:3000 / :5173 / :8080)
  - Detailed textual description of current UI
  - "Code-only audit" (inspects source, no visual)

### Step 2: Load Spec
- Read `.avner/3_contracts/UI_SPEC.md` — load design contract for in-scope screens.
- Read `.avner/1_vision/REQUIREMENTS.md` — understand which R-ids apply.

### Step 3: Audit Method

**If screenshots/URLs provided:**
- Compare visual output to spec definitions.
- Check each state (default, loading, error, empty, disabled) visually.
- Take desktop (1440px), tablet (768px), and mobile (375px) views if possible.

**If code-only mode:**
```bash
# Generic labels (Pillar 1)
grep -rn "\"Submit\"\|\"Click here\"\|\"OK\"\|\"Cancel\"\|\"Save\"" src --include="*.tsx" --include="*.jsx"

# Missing states (Pillar 6)
grep -rn "loading\|isLoading\|skeleton\|Spinner" src --include="*.tsx" --include="*.jsx"
grep -rn "error\|isError\|ErrorBoundary" src --include="*.tsx" --include="*.jsx"
grep -rn "empty\|isEmpty\|length === 0" src --include="*.tsx" --include="*.jsx"

# Hardcoded colors (Pillar 3)
grep -rn "#[0-9a-fA-F]\{3,8\}\|rgb(" src --include="*.tsx" --include="*.jsx"

# Spacing violations (Pillar 5)
grep -rn "\[.*px\]\|\[.*rem\]" src --include="*.tsx" --include="*.jsx"

# Typography violations (Pillar 4)
grep -rohn "text-\(xs\|sm\|base\|lg\|xl\|2xl\|3xl\|4xl\|5xl\)" src --include="*.tsx" --include="*.jsx" | sort -u
grep -rohn "font-\(thin\|light\|normal\|medium\|semibold\|bold\|extrabold\)" src --include="*.tsx" --include="*.jsx" | sort -u
```

### Step 4: Score 6 Pillars

Rate each pillar 1–4:
- **4** — Production-ready, no issues found
- **3** — Minor polish needed (1-2 small issues)
- **2** — Several gaps, needs work before ship
- **1** — Major issues, not shippable

| # | Pillar | What to Check |
|---|--------|---------------|
| 1 | **Copywriting** | Generic labels? Empty/error copy present and specific? CTAs verb+object? |
| 2 | **Visuals** | Clear focal point? Visual hierarchy matches spec? Icon-only elements have aria-labels? |
| 3 | **Color** | 60/30/10 discipline? Accent only on declared elements? No hardcoded hex/rgb? |
| 4 | **Typography** | ≤4 font sizes? ≤2 weights? Consistent role usage (body/label/heading/display)? |
| 5 | **Spacing** | All values multiples of 4? Token scale used? No arbitrary [Npx] values? |
| 6 | **Experience Design** | All 5 states present? Disabled states handled? Loading indicators? |

### Step 5: Top 3 Fixes

| # | Pillar | Description | Related R-ids | Suggested Next Step |
|---|--------|-------------|---------------|---------------------|
| 1 | [pillar] | [specific fix] | [R-ids] | [concrete action] |
| 2 | [pillar] | [specific fix] | [R-ids] | [concrete action] |
| 3 | [pillar] | [specific fix] | [R-ids] | [concrete action] |

Fixes must be specific: "Change button label from 'Submit' to 'Create Project'" not "improve labels".

### Step 6: Record
Append a new entry to `.avner/4_operations/UI_REVIEW.md`.
**DNA Safety Rule**: Show the user the proposed entry and get approval before writing.

### Step 7: Suggest Tasks
For each of the top 3 fixes, suggest:
- Open as a new task (TASK-XX in STATE.md)
- Bundle into current work
- Defer to backlog with rationale
Map each fix to the relevant R-ids from REQUIREMENTS.md.
```

---

## 5. Gates and Governance Logic

### 5.1 Gate Priority Order [CONFIRMED]

All gates are checked in this sequence. First match wins. [CONFIRMED]

| Priority | Gate | Trigger | Action |
|----------|------|---------|--------|
| 0 | Elon Gate (G0) | Any mode | Delete First? → /prune |
| 1 | Finish Before Start (G1) | /new, /core, TASK/FEAT | IN PROGRESS in STATE? → REFUSE |
| 2 | Ambiguity Guard | Any mode | Vague intent → HALT, ask one question |
| 3 | Safety Interrupt | Any mode | Unknown impact → HALT |
| 4 | Security Override | Sensitive areas touched | → escalate to /sec |
| 5 | Architect Trigger | DB/API/global state touched | → escalate to /core |
| 6 | Efficiency Downgrade | Overkill detected | → prefer boring, minimal change |
| 7 | Execute | All gates passed | Run the mode |

---

### 5.2 G0 — The Elon Gate (DELETE FIRST) [CONFIRMED]

```
TRIGGER: Before ANY mode executes. Universal pre-flight check.

QUESTION: "Can this outcome be achieved by removing an existing obstacle 
           instead of adding code or complexity?"

ALGORITHM:
  1. Read the user's stated intent.
  2. Scan .avner/1_vision/REQUIREMENTS.md for requirements that could 
     be simplified by removal.
  3. Ask: "If we deleted [X] instead of building [Y], would the user 
     goal still be achieved?"

PASS CONDITIONS:
  - The goal genuinely requires new code or new functionality.
  - No existing obstacle can be removed to achieve the same result.
  → Proceed to G1.

FAIL CONDITIONS:
  - The goal can be achieved by deleting a requirement, dead code, 
    over-engineered complexity, or an unused feature.
  - verify-vision returns SOLVE-BY-REMOVAL verdict.
  → HALT. Redirect to /prune.
  → Output: "⛔ G0: This can be solved by removing [X]. Run /prune."

ARTIFACTS CHECKED:
  - User's stated intent (in-session)
  - .avner/1_vision/REQUIREMENTS.md (are any R-ids candidates for deletion?)
  - STATE.md (are there tasks that are actually blockers to remove?)
```

---

### 5.3 G1 — Finish Before Start [CONFIRMED]

```
TRIGGER: Before /new, /core, or any TASK/FEAT in /one-flow.

QUESTION: "Does STATE.md have any task with status IN PROGRESS?"

ALGORITHM:
  1. Read .avner/4_operations/STATE.md.
  2. Parse task headers using regex:
     ^###\s+(~~)?((TASK|BUG|FEAT)-\d+)(~~)?:\s*(.+?)\s*\(([^)]+)\)
  3. Check for any task where status contains "IN PROGRESS".
  
PASS CONDITIONS:
  - No task has status IN PROGRESS.
  - Task is a P0 bug (bypasses G1).
  - Mode is /deploy (always bypasses G1).
  - Mode is /sec (always bypasses G1).
  → Proceed to execute the mode.

FAIL CONDITIONS:
  - Any task has status IN PROGRESS AND none of the bypass conditions apply.
  → REFUSE. Output: "⛔ G1 Block: Complete [TASK-XX] before starting new work."
  → Show the IN PROGRESS task and its last known stopping point.

ARTIFACTS CHECKED:
  - .avner/4_operations/STATE.md (task status)
  - Mode being invoked (for bypass check)
  - Task priority (for P0 bypass check)
```

---

### 5.4 UI Gate — Design Contract Checkpoint [CONFIRMED]

```
TRIGGER: /one-flow Step 4, when plan contains UI file changes.

QUESTION: "Are all affected screens defined in .avner/3_contracts/UI_SPEC.md?"

ALGORITHM:
  1. Scan the task list from Step 2 for files matching:
     - src/components/**, src/pages/**, src/app/**, src/layouts/**
     - *.tsx, *.jsx with JSX/UI patterns
     - *.css, *.scss, tailwind.config.*
  2. Extract the screen names implied by those files.
  3. Read .avner/3_contracts/UI_SPEC.md.
  4. Check if each implied screen has a complete spec section.

PASS CONDITIONS:
  - No UI files in plan → skip gate entirely.
  - All affected screens are defined in UI_SPEC.md with complete sections.
  → Proceed to Step 5 (Execute).

FAIL CONDITIONS (partial):
  - UI files are in plan AND affected screens are missing from UI_SPEC.md.
  → Run /ui workflow inline.
  → Get user approval on the new spec.
  → Only then proceed to Step 5.

NOTE: This gate does not BLOCK permanently. It inserts the /ui workflow
      and requires user approval. It is a checkpoint, not a hard stop.

ARTIFACTS CHECKED:
  - Step 2 task list (file paths)
  - .avner/3_contracts/UI_SPEC.md (screen coverage)
```

---

### 5.5 G2 — Contracts Gate (Spec Guardian) [CONFIRMED]

```
TRIGGER: After any task in /new, /fix, or /core that modifies:
  - DB schema or migration files
  - Public API signatures (route handlers, exported types)
  - Global or shared state, env contracts, auth primitives

AGENT: verify-spec (Eliezer) — Sonnet model, read-only subagent

ALGORITHM:
  1. Run git diff --name-only to detect changed files.
  2. Run git diff to see full diff.
  3. Classify each change:
     - ADDITIVE: new fields, new endpoints, new optional params
     - BREAKING: removal, rename, type change, status code change
     - NEUTRAL: implementation change (no signature change)
  4. Compare behavior vs. spec in API_CONTRACTS.md and DB_SCHEMA.md.

PASS CONDITIONS:
  - Change is additive only (backward-compatible).
  → PASS with explicit note: "Additive change — backward-compatible."

FAIL CONDITIONS:
  - Breaking change (removal, rename, type change, status code change).
  → ESCALATE-TO-CORE. Pause. Inform user. Switch to /core.
  - Any DB schema change.
  → ESCALATE-TO-CORE.
  - Timeout or incomplete review.
  → FAIL (fail-closed).

ARTIFACTS CHECKED:
  - git diff (current changes)
  - .avner/3_contracts/API_CONTRACTS.md (endpoint signatures)
  - .avner/3_contracts/DB_SCHEMA.md (table schemas)
```

---

### 5.6 Verify Gate — Pre-Deploy [CONFIRMED]

```
TRIGGER: Before /deploy completes. Both agents must pass.

AGENTS:
  - verify-ops (Yossi): GO / NO-GO / CONDITIONAL-GO
  - verify-security (Shimon): GO / NO-GO / NEEDS-MITIGATION

ALGORITHM:
  1. verify-ops checklist (all must pass for GO):
     a. Env vars: compare .env.example against deployment env
     b. Build: run project's build command — must succeed
     c. Migrations: any pending? non-destructive?
     d. Monitoring: error tracking, health endpoints
     e. Smoke tests: core flows work
     f. Integration: invoke verify-integration (Yehoshua) as subagent
  
  2. verify-security checklist (all must pass for GO):
     a. No secrets or credentials in code
     b. No auth bypass possible
     c. OWASP threats reviewed: injection, XSS, CSRF, SSRF, IDOR
     d. Rate limiting on all public endpoints
     e. All sensitive areas covered (auth, payments, secrets, PII)

PASS CONDITIONS:
  - verify-ops: GO
  - verify-security: GO
  → Proceed with deploy.

CONDITIONAL (requires human sign-off):
  - verify-ops: CONDITIONAL-GO (specific condition to resolve)
  → Display condition. Require explicit user confirmation before proceeding.

FAIL CONDITIONS (hard stop):
  - Build fails → NO-GO (period)
  - Required env vars missing → NO-GO (period)
  - Destructive migration without plan → NO-GO (period)
  - Secrets in code → NO-GO (period, immediate)
  - Auth bypass possible → NO-GO (period, immediate)
  - Shimon NO-GO → hard stop, no exceptions, Shimon has veto authority
  - Incomplete security review (timeout) → NO-GO
  → Output: "⛔ Verify Gate FAIL: [reason]. Fix before deploying."

ARTIFACTS CHECKED:
  - .env.example vs production env vars
  - Build output (must be clean)
  - git diff (for secrets scan)
  - All source files in sensitive areas
  - RUNBOOK.md (smoke test definitions)
```

---

## 6. Standard Workflows

### 6.1 New Feature

**Entry conditions**: User wants to build net-new functionality (no existing bug). No IN PROGRESS tasks in STATE.md.

| Step | Action | Skill/Agent | Files Created/Modified |
|------|--------|-------------|----------------------|
| 1 | G0 check: can it be solved by deletion? | Gate check (inline) | — |
| 2 | G1 check: any IN PROGRESS? | Gate check (inline) | — |
| 3 | Ambiguity check: clear scope? | Gate check (inline) | — |
| 4 | Map to R-ids in REQUIREMENTS.md | Claude Code | — |
| 5 | Write Decisions + Plan sections | `/new` SKILL | Plan in chat |
| 6 | CEO Review (scope challenge) | `/one-flow` Step 3a | Plan updated |
| 7 | Design Review (7 UX dimensions) | `/one-flow` Step 3b | Plan updated |
| 8 | Eng Review (arch + tests) | `/one-flow` Step 3c | Plan updated |
| 9 | UI Gate (if UI files in plan) | `/ui` SKILL | `UI_SPEC.md` created/updated |
| 10 | Vision Gate | Elazar (subagent, Opus) | `last_vision_check.txt` written |
| 11 | Implement each atomic task | Claude Code | Source files |
| 12 | Lint + typecheck after each task | ECC hooks (auto) | — |
| 13 | Commit each task | Claude Code | git history |
| 14 | G2 gate (if contracts touched) | Eliezer (subagent, Sonnet) | — |
| 15 | UI Review (if UI gate was triggered) | `/ui-review` SKILL | `UI_REVIEW.md` appended |
| 16 | Verification Artifact | Claude Code | In chat |
| 17 | Update STATE.md + LESSONS | Claude Code (with approval) | STATE.md, LESSONS_*.md |
| 18 | Handoff block | Claude Code | In chat |

**Exit conditions**: All tasks committed, lint/typecheck clean, Verification Artifact complete, STATE.md updated.

---

### 6.2 Bugfix

**Entry conditions**: Known bug with reproduction steps. `/fix` mode or `/one-flow` with fix context.

| Step | Action | Skill/Agent | Files Created/Modified |
|------|--------|-------------|----------------------|
| 1 | G0 check: can the bug be fixed by removing the feature? | Gate check | — |
| 2 | G1 check: allow P0 bypass | Gate check | — |
| 3 | Reproduce the bug (get exact error + stack) | Claude Code | — |
| 4 | Write FIX-BYPASS evidence | Claude Code | `last_vision_check.txt` |
| 5 | Plan: max 3 atomic tasks | `/fix` SKILL | Plan in chat |
| 6 | ER-Ribosome loop: max 3 iterations per root cause | Claude Code | Source files |
| 7 | Each iteration: new evidence before next attempt | Claude Code | — |
| 8 | After 3 failures → HALT → escalate to /core | Gate check | — |
| 9 | Regression test: add test that reproduces the bug | Claude Code | Test files |
| 10 | Lint + typecheck | ECC hooks (auto) | — |
| 11 | ONE commit per fix | Claude Code | git history |
| 12 | G2 gate if contracts touched | Eliezer (subagent) | — |
| 13 | Verification Artifact (MUST) | Claude Code | In chat |
| 14 | Update STATE.md | Claude Code (with approval) | STATE.md |

**Exit conditions**: Bug not reproducible, regression test passes, single commit with fix.

---

### 6.3 UI Feature

**Entry conditions**: New UI screen or component. No existing UI_SPEC.md coverage for affected screens.

| Step | Action | Skill/Agent | Files Created/Modified |
|------|--------|-------------|----------------------|
| 1 | G0 + G1 gate checks | Gate checks | — |
| 2 | Map to R-ids | Claude Code | — |
| 3 | Run `/ui` — Six Forcing Questions | `/ui` SKILL | `UI_SPEC.md` created |
| 4 | Detect design system state | `/ui` SKILL (bash) | — |
| 5 | Build spec sections (all 5 states, copy, components, a11y, responsive) | `/ui` SKILL | `UI_SPEC.md` updated |
| 6 | 6-pillar checker on spec | `/ui` SKILL | `UI_SPEC.md` sign-off |
| 7 | Get user approval on spec | Claude Code | — |
| 8 | Vision Gate (Elazar) | Elazar (subagent, Opus) | `last_vision_check.txt` |
| 9 | GStack Design Review (7 dimensions) | `/one-flow` Step 3b | Plan updated |
| 10 | Implement UI per spec | Claude Code | Source files |
| 11 | Lint + typecheck per file | ECC hooks (auto) | — |
| 12 | Run `/ui-review` — 6-pillar audit | `/ui-review` SKILL | `UI_REVIEW.md` appended |
| 13 | Commit with `feat(ui): description` | Claude Code | git history |
| 14 | Update STATE.md + LESSONS | Claude Code (with approval) | STATE.md |

**Exit conditions**: UI_SPEC approved, all 6 pillars scored ≥ 2, UI_REVIEW entry appended.

---

### 6.4 UI Refactor / Polish

**Entry conditions**: Existing UI code to improve. No logic changes. `/pol` mode.

| Step | Action | Skill/Agent | Files Created/Modified |
|------|--------|-------------|----------------------|
| 1 | G0 check: is this just removing cruft? | Gate check | — |
| 2 | Verify scope: ZERO logic changes permitted | `/pol` SKILL | — |
| 3 | Read existing UI_SPEC.md | Claude Code | — |
| 4 | Run `/ui-review` (code-only audit, baseline) | `/ui-review` SKILL | `UI_REVIEW.md` entry |
| 5 | Identify top 3 pillar gaps to fix | `/ui-review` SKILL | In chat |
| 6 | Implement pillar fixes (style only, no logic) | Claude Code | Source files |
| 7 | Lint only (no typecheck for polish) | ECC hooks (auto) | — |
| 8 | Re-run `/ui-review` to confirm improvement | `/ui-review` SKILL | `UI_REVIEW.md` entry |
| 9 | Commit: `style(ui): what was polished` | Claude Code | git history |
| 10 | Update STATE.md | Claude Code (with approval) | STATE.md |

**Exit conditions**: No logic changes, pillar scores improved, second UI_REVIEW appended.

---

### 6.5 Hotfix / Emergency

**Entry conditions**: P0 production bug. Bypasses G1. Bypasses /deploy gate only with CONDITIONAL-GO + human sign-off.

| Step | Action | Skill/Agent | Files Created/Modified |
|------|--------|-------------|----------------------|
| 1 | G0 check only (G1 bypassed for P0) | Gate check | — |
| 2 | Write FIX-BYPASS evidence immediately | Claude Code | `last_vision_check.txt` |
| 3 | ONE change, ONE commit, minimum viable fix | Claude Code | Source files |
| 4 | Reproduce → fix → regression test | Claude Code | Source + test files |
| 5 | Lint + typecheck (mandatory even for hotfix) | Claude Code | — |
| 6 | Verification Artifact (MUST) | Claude Code | In chat |
| 7 | Security check (Shimon) — if sensitive area | Shimon (subagent, Opus) | — |
| 8 | /codex review (optional but recommended) | Codex CLI | — |
| 9 | Deploy gates: verify-ops + verify-security | Yossi + Shimon (subagents) | — |
| 10 | Commit + deploy | Claude Code | git history |
| 11 | Update STATE.md + document incident in LESSONS_OPERATIONS | Claude Code (with approval) | STATE.md, LESSONS_OPERATIONS.md |
| 12 | Post-mortem handoff block | Claude Code | In chat |

**Exit conditions**: Bug fixed, regression test passes, deploy gates GO (or CONDITIONAL-GO with human sign-off), incident documented.

---

## 7. ECC Integration

### 7.1 How ECC Works in AVNER v8 [CONFIRMED]

AVNER v8 uses ECC's hook patterns via `.claude/settings.json`, not ECC's Node.js scripts directly. The settings.json approach is simpler and requires no npm install. For projects that want full ECC (multi-tool support including Cursor), the ECC npm package is vendored under `vendor/ecc/`.

**Two integration levels**:
1. **Minimal (settings.json)** — AVNER's native hooks, covers Claude Code only
2. **Full ECC (vendor/ecc/)** — ECC v1.9.0 Node.js hooks, covers Claude Code + Cursor + Codex

---

### 7.2 Exact Pre-Commit Hook Script [CONFIRMED]

This is the hook embedded in `.claude/settings.json` under `PreToolUse` (Bash matcher):

```bash
# Hook 1: Run lint + typecheck before git commit
if echo "$CLAUDE_TOOL_INPUT" | grep -q 'git commit'; then
  (npm run lint 2>/dev/null && tsc --noEmit 2>/dev/null) || true
fi
```

```bash
# Hook 2: Check commit evidence lock
if echo "$CLAUDE_TOOL_INPUT" | grep -q 'git commit'; then
  if ! grep -E -q '^(APPROVE|FIX-BYPASS)' .avner/4_operations/last_vision_check.txt 2>/dev/null; then
    echo 'COMMIT BLOCKED: No valid vision/fix evidence in last_vision_check.txt'
    exit 2
  fi
fi
```

**Exit code protocol**: Exit 2 = block the tool call. Exit 0 = allow. [CONFIRMED]

---

### 7.3 Exact Pre-Push Hook Script [INFERRED]

AVNER v8 does not use a native pre-push git hook (git pushes are in the permission deny list). The equivalent protection is the `block-no-verify` mechanism in full ECC and the deny list in settings.json.

For projects that enable git push, add to settings.json `allow` list and use this hook:

```bash
# PreToolUse hook for git push (add to settings.json)
{
  "matcher": "Bash",
  "hooks": [
    {
      "type": "command",
      "command": "if echo \"$CLAUDE_TOOL_INPUT\" | grep -q 'git push'; then echo '[AVNER] Review changes before push: git diff origin/main...HEAD'; fi"
    }
  ]
}
```

For full ECC, the `block-no-verify` package blocks `git commit --no-verify`:
```bash
npx block-no-verify@1.1.2
```
This prevents bypassing pre-commit, commit-msg, and pre-push hooks. [CONFIRMED]

---

### 7.4 Full settings.json (AVNER v8 Native) [CONFIRMED]

```json
{
  "model": "sonnet",
  "permissionMode": "default",
  "autoMemory": false,
  "env": {
    "ENABLE_TOOL_SEARCH": "auto:5"
  },
  "permissions": {
    "allow": [
      "npm test",
      "npm run dev",
      "npm run build",
      "npm run lint",
      "npm run test:*",
      "npx depcheck",
      "git status",
      "git diff",
      "git diff *",
      "git add *",
      "git commit *",
      "git log *",
      "tsc --noEmit",
      "eslint *",
      "npx drizzle-kit generate",
      "npx drizzle-kit push",
      "npx drizzle-kit studio",
      "npx shadcn info",
      "npx playwright install"
    ],
    "deny": [
      ".env",
      "rm -rf",
      "rm -r",
      "sudo",
      "curl * | bash",
      "git push *",
      "git reset --hard *",
      "git checkout -- *",
      "npx drizzle-kit push --force-reset"
    ]
  },
  "compaction": {
    "threshold": 0.9
  },
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "cat .avner/4_operations/STATE.md .avner/MEMORY.md 2>/dev/null || echo 'No STATE/MEMORY found.'"
          },
          {
            "type": "command",
            "command": "test -f .avner/4_operations/STATE.md && find .avner/4_operations/STATE.md -mtime +7 -exec echo '⚠️ STATE.md is over 7 days old. Consider updating.' \\; 2>/dev/null || true"
          }
        ]
      },
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo '=== POST-COMPACTION CONTEXT RESTORE ===' && head -n 150 .avner/MEMORY.md 2>/dev/null && echo '=== Read API_CONTRACTS.md and DB_SCHEMA.md before any /core or /deploy work. ==='"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Session ending. Remember to update STATE.md and LESSONS if needed.'"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "cp .avner/4_operations/STATE.md .avner/4_operations/STATE.md.bak 2>/dev/null || true"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_TOOL_INPUT\" | grep -q 'git commit'; then (npm run lint 2>/dev/null && tsc --noEmit 2>/dev/null) || true; fi"
          },
          {
            "type": "command",
            "command": "if echo \"$CLAUDE_TOOL_INPUT\" | grep -q 'git commit'; then if ! grep -E -q '^(APPROVE|FIX-BYPASS)' .avner/4_operations/last_vision_check.txt 2>/dev/null; then echo 'COMMIT BLOCKED: No valid vision/fix evidence in last_vision_check.txt'; exit 2; fi; fi"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

---

### 7.5 Full ECC Installation (vendor/ecc/) [CONFIRMED]

For multi-tool projects (Claude Code + Cursor + Codex CLI):

```bash
# Step 1: Install ECC globally or as dev dependency
npm install -g everything-claude-code  # or:
npm install --save-dev everything-claude-code

# Step 2: Set hook profile (standard recommended for AVNER v8)
export ECC_HOOK_PROFILE=standard

# Step 3: Initialize in project
npx ecc install

# Step 4: Sync ECC settings to Codex CLI
bash vendor/ecc/scripts/sync-ecc-to-codex.sh

# Step 5: Regenerate guardrails from git history
# [MISSING — regeneration command not documented; likely 'npx ecc generate']

# Disable individual hooks if needed
export ECC_DISABLED_HOOKS=pre:bash:tmux-reminder,pre:bash:git-push-reminder
```

**ECC Hook Profile Matrix** [CONFIRMED]:

| Hook ID | minimal | standard | strict |
|---------|---------|----------|--------|
| `session:start` | ✓ | ✓ | ✓ |
| `session:end:marker` | ✓ | ✓ | ✓ |
| `stop:session-end` | ✓ | ✓ | ✓ |
| `stop:evaluate-session` | ✓ | ✓ | ✓ |
| `stop:cost-tracker` | ✓ | ✓ | ✓ |
| `pre:bash:dev-server-block` | — | ✓ | ✓ |
| `stop:check-console-log` | — | ✓ | ✓ |
| `pre:bash:tmux-reminder` | — | — | ✓ |
| `pre:bash:git-push-reminder` | — | — | ✓ |

---

### 7.6 How ECC Extracts Conventions [CONFIRMED]

ECC analyzes the repository's git history and file patterns to generate `.claude/rules/everything-claude-code-guardrails.md`:

1. **Commit messages** → detect commit style (conventional commits → `conventional` type)
2. **File naming patterns** → detect casing convention (e.g., `camelCase`)
3. **Module organization** → detect architecture style (e.g., `hybrid`)
4. **Test layout** → detect test organization (e.g., `separate`)
5. **Import patterns** → detect `relative` vs absolute, `mixed` exports
6. **PR and review flow** → detect existing review workflow
7. **Detected workflows** → discovers repeated patterns, names them

**Generated guardrails file format**:
```markdown
# Everything Claude Code Guardrails

Generated by ECC Tools from repository history.

## Commit Workflow
- Prefer `conventional` commit messaging with prefixes such as fix, test, feat, docs.
- Keep new changes aligned with the existing pull-request and review flow.

## Architecture
- Preserve the current `hybrid` module organization.
- Respect the current test layout: `separate`.

## Code Style
- Use `camelCase` file naming.
- Prefer `relative` imports and `mixed` exports.

## ECC Defaults
- Current recommended install profile: `full`.
- Validate risky config changes in PRs.

## Detected Workflows
- [workflow-name]: [description]

## Review Reminder
- Regenerate this bundle when repository conventions materially change.
- Keep suppressions narrow and auditable.
```

**Regenerate** when conventions change: [MISSING — command not documented in ECC sources]

---

### 7.7 CLAUDE.md ECC Integration Block

Add this block to CLAUDE.md under "ECC Coding Conventions":

```markdown
## ECC Active Hooks
- beforeShellExecution: blocks dev servers outside tmux, git push reminders
- afterFileEdit: auto-format, TypeScript check, console.log warning
- stop: console.log audit, session evaluation, cost tracking
- beforeSubmitPrompt: secret detection (sk-, ghp_, AKIA patterns)
- preCompact: saves state before context compaction

## ECC Profile
Current profile: standard
To change: export ECC_HOOK_PROFILE=minimal|standard|strict
To disable hook: export ECC_DISABLED_HOOKS=hook-id-1,hook-id-2

## block-no-verify
The npx block-no-verify@1.1.2 hook is active.
git commit --no-verify is BLOCKED. Pre-commit, commit-msg, and pre-push hooks cannot be bypassed.
```

---

## 8. Council Agent Protocols

### 8.1 Council Summary [CONFIRMED]

| Agent | Character | Role | When | Model | Verdicts |
|-------|-----------|------|------|-------|----------|
| **Elazar** | R. Elazar ben Arach | Vision Gate | 100% of /new and /core | Opus 4.6 | APPROVE / HALT / NEEDS-CLARIFICATION / SOLVE-BY-REMOVAL |
| **Eliezer** | R. Eliezer ben Hyrcanus | Spec Guardian | ~15% of tasks (contracts touched) | Sonnet 4.6 | PASS / FAIL / ESCALATE-TO-CORE |
| **Yehoshua** | R. Yehoshua ben Hananiah | Integration Check | Invoked by Yossi (/deploy) | Sonnet 4.6 | PASS / FAIL / NEEDS-REVIEW |
| **Yossi** | R. Yosi ben Yoenam | SRE / Deploy | /deploy only | Sonnet 4.6 | GO / NO-GO / CONDITIONAL-GO |
| **Shimon** | R. Shimon ben Netanel | CISO / Veto | /deploy + sensitive areas | Opus 4.6 | GO / NO-GO / NEEDS-MITIGATION |

"Most tasks trigger 0-1 Council members. All 5 firing = something big is happening." [CONFIRMED]

---

### 8.2 Elazar (verify-vision) — Vision Gate [CONFIRMED]

**File**: `.claude/agents/verify-vision.md`

| Property | Value |
|----------|-------|
| Model | Opus 4.6 |
| Allowed tools | Read, Glob (read-only) |
| Disallowed tools | Bash, Write, Edit |
| Max turns | 12 |
| Fail-closed | Timeout or no verdict = HALT |

**Sources of truth** (priority order):
```
1. VISION.md
2. MEMORY.md
3. REQUIREMENTS.md
4. ARCHITECTURE.md
5. API_CONTRACTS.md / DB_SCHEMA.md
6. GAP_ANALYSIS.md
7. STATE.md
```

**Protocol**:
1. Read MEMORY.md — load user preferences, key decisions, explicit non-goals
2. Read VISION.md — extract target user, value prop, north-star metrics, non-goals
3. Read REQUIREMENTS.md — check if change maps to V1 R-id
4. Read GAP_ANALYSIS.md — understand current priorities
5. Read STATE.md (optional context)
6. Evaluate the proposed change against all sources
7. Challenge the requirement itself (ELAN Gate):
   - Who created this R-id (Owner)? What evidence justified it?
   - Could the user's need be met by removing an existing obstacle instead?
   - If this R-id were deleted today, what would actually break?

**Output format** (strict):
```
Verdict: APPROVE | HALT | NEEDS-CLARIFICATION | SOLVE-BY-REMOVAL
Why: ≤ 5 bullets.
[If APPROVE: state the single requirement that would survive deletion most easily]
[If HALT: exactly 1 clarifying question that would unblock alignment]
[If SOLVE-BY-REMOVAL: exact obstacle to target with /prune]
```

**Hard rules** [CONFIRMED]:
- Conflict with explicit non-goals → HALT
- Request is vague → NEEDS-CLARIFICATION
- R-id Owner is missing, generic ("Team", "TBD"), or lacks Evidence → HALT
- Key Decision from current session cannot override HALT in same session
- Fail-closed: timeout or no verdict → HALT

---

### 8.3 Eliezer (verify-spec) — Spec Guardian [CONFIRMED]

**File**: `.claude/agents/verify-spec.md`

| Property | Value |
|----------|-------|
| Model | Sonnet 4.6 |
| Allowed tools | Read, Glob, Grep, Bash |
| Disallowed tools | Write, Edit |
| Max turns | 18 |
| Fail-closed | Timeout → FAIL |

**Input artifacts**: git diff output, API_CONTRACTS.md, DB_SCHEMA.md

**Protocol**:
1. Run `git diff --name-only` then `git diff`
2. Identify if changes touch: DB schema, public API signatures, global state
3. Classify: ADDITIVE (new fields, new endpoints) vs BREAKING (removal, rename, type change)
4. Compare behavior vs spec in API_CONTRACTS.md and DB_SCHEMA.md

**Hard rules** [CONFIRMED]:
- DB/API/global-state change → ESCALATE-TO-CORE
- Backward-incompatible change → ESCALATE-TO-CORE
- Backward-compatible additive change → PASS with explicit note
- Fail-closed: timeout → FAIL

**Output format**:
```
Verdict: PASS | FAIL | ESCALATE-TO-CORE
Scope: [list of files and change types found]
[If PASS: note the additive nature explicitly]
[If FAIL: exact spec violation with file:line reference]
[If ESCALATE-TO-CORE: exact breaking change description + migration path needed]
```

---

### 8.4 Yehoshua (verify-integration) — Integration Check [CONFIRMED]

**File**: `.claude/agents/verify-integration.md`

| Property | Value |
|----------|-------|
| Model | Sonnet 4.6 |
| Allowed tools | Read, Glob, Grep, Bash |
| Disallowed tools | Write, Edit |
| Max turns | 20 |
| Isolation | worktree |
| Invoked by | Yossi (verify-ops) as subagent |

**Protocol**:
1. `git diff --name-only` then `git diff`
2. Identify integration points: API calls, webhooks, auth middleware, DB queries, external SDKs
3. For each integration point: verify caller and callee are still compatible
4. Check error cases are handled at every boundary

**Output**: PASS / FAIL / NEEDS-REVIEW + broken pipes (file+line) + missing error handling

---

### 8.5 Yossi (verify-ops) — SRE / Deploy [CONFIRMED]

**File**: `.claude/agents/verify-ops.md`

| Property | Value |
|----------|-------|
| Model | Sonnet 4.6 |
| Allowed tools | Read, Glob, Grep, Bash |
| Disallowed tools | Write, Edit |
| Max turns | 15 |
| Isolation | worktree |

**Checklist** (all must pass for GO):
- [ ] Env vars: compare `.env.example` against deployment env
- [ ] Build: run project's build command — must succeed
- [ ] Migrations: any pending? non-destructive only?
- [ ] Monitoring: error tracking configured, health endpoints reachable
- [ ] Smoke tests: core flows verified
- [ ] Integration: invoke Yehoshua (verify-integration) as subagent

**Hard rules** [CONFIRMED]:
- Build fails → NO-GO. Period.
- Required env vars missing → NO-GO. Period.
- Destructive migration → NO-GO. Period.
- CONDITIONAL-GO requires explicit human sign-off — no automated continuation

**Output format**:
```
Verdict: GO | NO-GO | CONDITIONAL-GO
Checklist results: [each item — PASS / FAIL / SKIP + reason]
[If NO-GO: exact blocker with file/config reference]
[If CONDITIONAL-GO: exact condition required + what human must confirm]
Integration check (Yehoshua): [PASS / FAIL / NEEDS-REVIEW]
```

---

### 8.6 Shimon (verify-security) — CISO / Veto [CONFIRMED]

**File**: `.claude/agents/verify-security.md`

| Property | Value |
|----------|-------|
| Model | Opus 4.6 |
| Allowed tools | Read, Glob, Grep, Bash |
| Disallowed tools | Write, Edit |
| Max turns | 20 |
| Isolation | worktree |
| Authority | VETO — Shimon's NO-GO is a hard stop. No exceptions. |

**Sensitive areas** (always examine if touched):
- Auth, sessions, tokens, cookies, JWT, passwords
- Middleware, CORS, RBAC/ACL, API keys
- PII, email, phone, ID numbers, encryption, payment logic
- Secrets, env vars, infra config

**Threat model**: auth bypass, injection (SQL/XSS/SSTI), replay attacks, SSRF, IDOR, mass assignment, rate abuse, secrets in code

**Severity levels**:
- 🔴 Critical — must fix before deploy
- 🟠 Medium — should fix
- 🟡 Low — optional

**Hard rules** [CONFIRMED]:
- Secrets or credentials in code → NO-GO. Immediate.
- Auth bypass possible → NO-GO. Immediate.
- Shimon has veto power in /deploy. Yossi executes; Shimon decides.
- maxTurns reached without completing security coverage → NO-GO (incomplete review)

**Output format**:
```
Verdict: GO | NO-GO | NEEDS-MITIGATION
Findings:
  🔴 Critical: [description + file:line]
  🟠 Medium: [description + file:line]
  🟡 Low: [description]
[If NO-GO: exact blocker — no exceptions]
[If NEEDS-MITIGATION: exact mitigations required before next review]
Threat model coverage: [which threats were checked]
```

---

## 9. File Format Schemas

### 9.1 STATE.md [CONFIRMED]

```markdown
# Project State — {{PROJECT_NAME}}

Updated: {{YYYY-MM-DD}}
Phase:   {{Vision | Architecture | Contracts | Operations}}
Version: {{current tag or commit hash}}

> **Status values:** `PLANNED` / `IN PROGRESS` / `REVIEW` / `PAUSED` / `✅ DONE`
> **ID format:** `TASK-XXX` · `BUG-XXX` · `FEAT-XXX` (globally sequential)

---

## Session Continuity
- Stopped at:        [exact point — file, function name, or decision pending]
- Next action:       [first command or step to run in next session]
- Open questions:    [unresolved decisions that need input before continuing]
- Last commands run: [relevant terminal commands run in this session]

---

## Active Work

### TASK-01: [Title] (IN PROGRESS)
**Priority**: P1
**Status**: IN PROGRESS (YYYY-MM-DD)

[Description of the task and current progress]

---

## Review

### TASK-02: [Title] (REVIEW)
**Priority**: P1
**Status**: REVIEW (YYYY-MM-DD)
**Commits**: [hash]

[What's waiting for review]

---

## Backlog

### TASK-03: [Title] (PLANNED)
**Priority**: P2
**Status**: PLANNED (YYYY-MM-DD)

[Description]

---

## Completed

### ~~TASK-50~~: [Title] (✅ DONE)
**Priority**: P0
**Status**: ✅ DONE (YYYY-MM-DD)
**Commits**: [hash range]

---

## Recent Deploys
- [YYYY-MM-DD] v[X.X] — [what shipped] — [status: stable / monitoring / rolled back]
```

**Parsing rules** (used by all modes): [CONFIRMED]
- Task header regex: `^###\s+(~~)?((TASK|BUG|FEAT)-\d+)(~~)?:\s*(.+?)\s*\(([^)]+)\)`
- Status normalization: "DONE", "✅", strikethrough → DONE | "IN PROGRESS" → IN PROGRESS | "REVIEW" → REVIEW | "PAUSED" → PAUSED | else → PLANNED

---

### 9.2 LESSONS_GLOBAL.md / LESSONS_PROJECT.md [CONFIRMED]

Four files share this format: `LESSONS_VISION.md`, `LESSONS_ARCHITECTURE.md`, `LESSONS_CONTRACTS.md`, `LESSONS_OPERATIONS.md`

```markdown
# Lessons — {{Vision | Architecture | Contracts | Operations}}

Record what we learned about [domain].
DNA Safety Rule: Claude must not edit this file without explicit user approval + visible diffs.

---

## Entries

### {{YYYY-MM-DD}} {{Title}}
- **What happened**: [brief description]
- **What we learned**: [insight]
- **Action taken**: [how this changed our approach]

---

## Incidents

| Date | Incident | Impact | Resolution |
|------|----------|--------|------------|
| | | | |
```

**When to update**: After significant events, during `/review` handoff, at end of sprint.
**Who approves**: The user. Claude proposes, never auto-writes. [CONFIRMED]

---

### 9.3 RUNBOOK.md [CONFIRMED]

```markdown
# Runbook — {{PROJECT_NAME}}

## Deploy Checklist
1. [ ] All tests pass (`npm test`)
2. [ ] Build succeeds (`npm run build`)
3. [ ] verify-ops (Yossi): GO
4. [ ] verify-security (Shimon): GO
5. [ ] Env vars set in production
6. [ ] Migrations applied (if any)
7. [ ] CHANGELOG updated
8. [ ] Version bumped

## Deploy Commands
# Build: [build command from TECHSTACK.md]
# Deploy: [deploy command]
# Verify: [smoke test command or health check URL]

## Rollback Procedure
1. Identify the last known-good version: git log --oneline -10
2. Revert to last good deploy: [platform-specific rollback command]
3. Verify rollback: [health check]
4. Notify team: [channel/email]

## Smoke Tests
| Test | Command / URL | Expected |
|------|--------------|----------|
| Health check | GET /api/health | { status: "ok" } |
| Auth flow | [describe] | [expected] |
| Core feature | [describe] | [expected] |

## Backup & Recovery
- Database: [backup strategy]
- Files: [if applicable]
- Secrets: [rotation schedule]

## Emergency Contacts
| Role | Contact | When |
|------|---------|------|
| On-call | [name/handle] | Production down |
| Security | [name/handle] | Breach/vulnerability |
```

---

### 9.4 REQUIREMENTS.md [CONFIRMED]

```markdown
# Requirements — {{PROJECT_NAME}}

## V1 (Must Ship for "Done")
| ID | Requirement | Acceptance Criteria | Priority | Owner | Evidence |
|----|-------------|---------------------|----------|-------|---------|
| R1 | [What] | [How verified] | P0 | @name | [Source/date] |
| R2 | | | P0 | | |

## V2 (Next Phase)
| ID | Requirement | Notes |
|----|-------------|-------|
| R3 | [What] | Deferred to next sprint |

## Out-of-Scope (Explicit No)
- [What we're NOT doing and why]
- [Common requests we'll reject]

## Traceability Rule
Every /new and /core Decisions section must reference at least one R-id.
If a task doesn't map to an R-id → HALT (scope creep or missing requirement).
```

**HALT triggers for verify-vision**: [CONFIRMED]
- R-id Owner is missing, generic ("Team", "TBD"), or lacks Evidence → HALT
- Change contradicts explicit non-goals → HALT
- R-id added in current session → cannot override HALT in same session

---

### 9.5 VISION.md [CONFIRMED]

```markdown
# Vision — {{PROJECT_NAME}}

## Target User
- Who: [Describe the specific person — role, context, pain level]
- Where: [How do they find you? Where do they feel the pain?]

## Core Problem
[One sentence — what sucks about the status quo?]

## Value Proposition
[One sentence — what does {{PROJECT_NAME}} make possible that wasn't before?]

## North-Star Metrics
| Metric | Current | Target | Timeframe |
|--------|---------|--------|-----------|
| [e.g., Active users] | 0 | [target] | [date] |

## Non-Goals (V1)
- [What we explicitly will NOT build in V1]
- [What we will defer to V2+]

## Current Phase
- Phase: V1
- Goal: [GOAL]
- Status: Planning
```

---

### 9.6 ARCHITECTURE.md [CONFIRMED]

```markdown
# Architecture — {{PROJECT_NAME}}

## System Overview
{{STACK}}
[High-level description of system and purpose]

## Component Diagram
```
  ┌──────────┐     ┌──────────┐     ┌──────────┐
  │ Frontend  │────▶│   API    │────▶│    DB    │
  └──────────┘     └──────────┘     └──────────┘
```

## Module Responsibilities
| Module | Responsibility | Owns |
|--------|----------------|------|
| [module] | [what it does] | [files/dirs] |

## Data Flow
1. [User action] → [component] → [component] → [result]

## Key Design Decisions
- [YYYY-MM-DD] [Decision]: [rationale]

## Boundary Contracts
- Frontend ↔ API: see .avner/3_contracts/API_CONTRACTS.md
- API ↔ DB: see .avner/3_contracts/DB_SCHEMA.md
- External services: [list integrations and contracts]

## Constraints
- [Performance requirements]
- [Security requirements]
- [Infrastructure limitations]
```

---

### 9.7 UI_SPEC.md [CONFIRMED]

```markdown
---
status: draft | approved
reviewed_at: YYYY-MM-DD | pending
---

# UI Spec — {{PROJECT_NAME}}

This is the UI design contract. Update before UI-heavy work via `/ui`.
Audit implementation via `/ui-review`.
DNA Safety Rule applies — modifications require user approval + visible diff.

---

## Design System

| Property | Value |
|----------|-------|
| Component library | [shadcn/ui / Radix / MUI / Headless UI / custom] |
| shadcn preset | [preset string / not applicable] |
| Icon set | [Lucide / Heroicons / custom] |
| Font | [Inter / Geist / system-ui / custom] |
| Tailwind config | [path to tailwind.config.ts] |

---

## Spacing Scale (4-point grid — all values must be multiples of 4)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon gaps, tight inline padding |
| sm | 8px | Related element gaps, compact spacing |
| md | 16px | Default section padding |
| lg | 24px | Card padding, section internal margins |
| xl | 32px | Section margins, layout gaps |
| 2xl | 48px | Major page sections |
| 3xl | 64px | Hero spacing, full-page sections |

Exceptions: [list non-4-multiple values and justification, or "none"]

---

## Typography (max 4 sizes, max 2 weights)

| Role | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| Body | 14–16px | 400 | 1.5 | Paragraphs, descriptions |
| Label | 12–14px | 500 | 1.4 | Form labels, captions, secondary info |
| Heading | 20–24px | 600 | 1.2 | Section headers, card titles |
| Display | 32–48px | 700 | 1.1 | Page titles, hero text |

---

## Color System (60/30/10)

| Role | Proportion | Value | Usage |
|------|-----------|-------|-------|
| Dominant | 60% | [hex] | Backgrounds, page surface, panels |
| Secondary | 30% | [hex] | Text, borders, cards, sidebar |
| Accent | 10% | [hex] | [LIST EXACT ELEMENTS — never "all interactive"] |
| Destructive | — | [hex] | Delete actions, error states only |

**Accent is reserved for**: [exact list — e.g., "primary CTA button, active nav item, focus ring, selected state"]

---

## Copywriting Contract

| Pattern | Template | Concrete Example |
|---------|----------|--------------------|
| Primary CTA | [verb] + [object] | "Create project" / "Send message" |
| Secondary CTA | [verb] | "Cancel" / "Go back" |
| Empty state heading | [what's missing] | "No projects yet" |
| Empty state body | [what's missing] + [how to fix] | "No projects yet. Create your first one to get started." |
| Error state | [what went wrong] + [what to do] | "Could not save. Check your connection and try again." |
| Destructive confirm | [consequence] + [action] | "This will permanently delete all project data. Delete project?" |

---

## Screens

<!-- One section per screen. Add more as needed. -->

### [Screen Name]

- **Description**: [What this screen does and when the user sees it]
- **Related R-ids**: [R1, R2]
- **Layout**:
  - Zones: [header / sidebar / main content / footer]
  - Hierarchy: [primary focus element] → [secondary] → [tertiary]
  - Key components: [list components used in this screen]
- **States**:
  - **Default**: [what the user sees on successful load]
  - **Loading**: [skeleton / spinner / progressive reveal — which elements]
  - **Error**: [inline / toast / full-page — copy: "X went wrong. Y to fix."]
  - **Empty**: [illustration? / minimal text — copy: "Nothing yet. Do X to start."]
  - **Disabled**: [which elements, when disabled, visual indicator]
- **Copy**:
  - Primary CTA: "[Specific verb + noun]"
  - Empty state: "[Specific message]"
  - Error: "[Specific message + action]"
  - Destructive confirm: "[Consequence + action label]"
- **Components**: [List with variants — e.g., "Button (primary, destructive), Card, Input (text, error state)"]
- **Accessibility**:
  - Keyboard nav: [tab order, focus trapping for modals]
  - Screen reader: [aria-labels for icon-only buttons, live regions for dynamic content]
  - Contrast: [WCAG AA minimum — 4.5:1 for body text]
- **Responsive**:
  - Mobile (< 768px): [layout shift description]
  - Tablet (768–1024px): [layout shift description]
  - Desktop (> 1024px): [default layout]

---

## Registry Safety (shadcn only — skip if not using shadcn)

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| shadcn official | [list blocks] | not required |
| [third-party name] | [list blocks] | view passed — no flags — [YYYY-MM-DD] |

---

## Checker Sign-Off

- [ ] Pillar 1 Copywriting: no generic labels, all states have specific copy
- [ ] Pillar 2 Visuals: focal point declared, hierarchy explicit, icons labeled
- [ ] Pillar 3 Color: 60/30/10 declared, accent elements listed specifically
- [ ] Pillar 4 Typography: max 4 sizes, max 2 weights, roles defined
- [ ] Pillar 5 Spacing: all values multiples of 4, token scale used
- [ ] Pillar 6 Experience Design: all 5 states defined per screen
```

---

### 9.8 UI_REVIEW.md [CONFIRMED]

```markdown
# UI Review Log — {{PROJECT_NAME}}

Append an entry after each `/ui-review` audit. Do not delete previous entries.
Managed by: `/ui-review` skill. Protected by DNA Safety Rule.

---

## Review: {{YYYY-MM-DD}}

- **Reviewer**: [human name / Claude]
- **Scope**: [screens/flows audited — list specifically]
- **Audit method**: [screenshots at localhost:3000 / code-only / textual description]
- **Baseline**: [UI_SPEC.md revision / abstract 6-pillar standards]

### 6-Pillar Scores

| # | Pillar | Score (1–4) | Key Finding |
|---|--------|-------------|-------------|
| 1 | Copywriting | [1-4] | [one-line summary] |
| 2 | Visuals | [1-4] | [one-line summary] |
| 3 | Color | [1-4] | [one-line summary] |
| 4 | Typography | [1-4] | [one-line summary] |
| 5 | Spacing | [1-4] | [one-line summary] |
| 6 | Experience Design | [1-4] | [one-line summary] |

**Overall: [total]/24**

Scoring guide: 4 = Production-ready | 3 = Minor polish | 2 = Needs work | 1 = Not shippable

### Detailed Findings

#### Pillar 1: Copywriting ([score]/4)
[Findings with file:line references for any issues]

#### Pillar 2: Visuals ([score]/4)
[Findings]

#### Pillar 3: Color ([score]/4)
[Findings with class usage counts and hardcoded color refs]

#### Pillar 4: Typography ([score]/4)
[Findings with size/weight distribution]

#### Pillar 5: Spacing ([score]/4)
[Findings with spacing class analysis, arbitrary value list]

#### Pillar 6: Experience Design ([score]/4)
[Findings with state coverage analysis — which states are missing]

### Top 3 Priority Fixes

| # | Pillar | Description | Related R-ids | Suggested Next Step |
|---|--------|-------------|---------------|---------------------|
| 1 | [pillar] | [specific issue] | [R-ids] | [concrete action] |
| 2 | [pillar] | [specific issue] | [R-ids] | [concrete action] |
| 3 | [pillar] | [specific issue] | [R-ids] | [concrete action] |

### Task Recommendations

| Fix # | Recommended Action | Task ID (if created) |
|-------|-------------------|----------------------|
| 1 | [Open as TASK-XX / Bundle into current / Defer: reason] | [TASK-XX or —] |
| 2 | [Open as TASK-XX / Bundle / Defer] | [TASK-XX or —] |
| 3 | [Open as TASK-XX / Bundle / Defer] | [TASK-XX or —] |

### Remaining Risk & Tradeoffs

- [Known issues accepted for this release and why]
- [Areas not audited and why]
- [Registry audit: N third-party blocks checked, no flags / flags — see above]

---
```

---

### 9.9 GAP_ANALYSIS.md [CONFIRMED]

```markdown
# Gap Analysis — {{PROJECT_NAME}}

## What Exists Today
- [List current capabilities, features, infrastructure already in place]

## What Is Missing
| Gap | Related R-ids | Priority | Notes |
|-----|---------------|----------|-------|
| [Missing capability] | R1, R2 | P0 | [Context] |

## Current Sprint Focus
- Primary: [The ONE thing we're building this sprint]
- Secondary: [If primary is done early]
- Blocked: [Items waiting on external input or decisions]
```

---

### 9.10 MEMORY.md [CONFIRMED]

```markdown
# AVNER Memory — Project Seed
# Auto-loaded at session start. Keep under 200 lines.

## Identity
- Project:       {{PROJECT_NAME}}
- Stack:         {{STACK}}
- Soul Purpose:  {{GOAL — one sentence, production-ready definition}}
- Current Focus: [Active sprint goal in one sentence]

## Non-goals (explicit — what we will NOT do)
- [Be specific. Vagueness here causes wasted sessions.]
- [Common: "No mobile app", "No third-party auth providers", "No SSR"]

## Sensitive Areas
- Auth / session / token / JWT logic
- Payments / billing / webhooks
- Secrets and environment contracts
- [Add project-specific areas here]

## Key Decisions (permanent record)
- [YYYY-MM-DD] [Title]: [what was decided + why + who approved]

## Lessons (top 3 from last sprint)
- [Most important lesson applied right now]
- [Second lesson]
- [Third lesson]
```

**Priority rule for verify-vision**: VISION.md > MEMORY.md > REQUIREMENTS.md [CONFIRMED]
A Key Decision in MEMORY.md overrides Vision ONLY if: date is prior to current session + Owner is named + Evidence is present. [CONFIRMED]

---

## 10. Best Practices and Anti-Patterns

### 10.1 Best Practices

#### From GStack: Core Execution Principles [CONFIRMED]

| Principle | What It Means | How to Apply |
|-----------|--------------|--------------|
| **Boil the Lake** | Never expand scope mid-task | Write a hard "Not Doing" section in every Decisions block |
| **Search Before Building** | Check if framework/library has it already | Eng Review explicitly checks: "Does the framework have a built-in for each pattern?" |
| **Completeness Principle** | ★★★ tests cover edge cases AND error paths | Rate test quality: ★★★ / ★★ / ★ in Eng Review |
| **Cross-Model Diversity** | Two models find different bugs | Run both Claude's /review and Codex's /codex review before shipping |
| **CEO before Code** | Challenge scope before building | Always run CEO Review in Step 3 before Step 5 (Execute) |
| **Complexity Smell** | >8 files or 2+ new classes → challenge it | Eng Review triggers automatic complexity challenge |

#### From AVNER: Governance Principles [CONFIRMED]

| Principle | What It Means | Enforcement |
|-----------|--------------|-------------|
| **DNA Safety** | Protected files need human approval + visible diffs | settings.json autoMemory:false + DNA list |
| **Evidence-Based Commits** | No commit without proof that vision gate ran | `last_vision_check.txt` checked by PreToolUse hook |
| **Council Consensus** | High-risk work gets independent verification | Agent routing table + mandatory Council for High-risk paths |
| **Fail-Closed Defaults** | Timeout = HALT/FAIL, not PASS | Every Council agent: "timeout → HALT" hard rule |
| **One Fix, One Commit** | Never mix concerns in one commit | Commit discipline enforced in all mode SKILL.md files |
| **ER-Ribosome Loop** | Max 3 debug iterations, then escalate | Hard rule in /fix SKILL.md |
| **Air-Gap Rule** | No external skills (supply-chain risk) | Skill registry in TECHSTACK.md, no external install permitted |

#### From ECC: Convention Enforcement Principles [CONFIRMED]

| Principle | What It Means | Enforcement |
|-----------|--------------|-------------|
| **Immutability First** | Always create new objects; never mutate | ECC guardrails + common-coding-style rules |
| **Convention Extraction** | Learn from repo history, not just static rules | ECC auto-generates guardrails from git history |
| **Hook Enforcement** | Standards enforced at tool level, not just instruction | dev-server-block, auto-format, typecheck hooks |
| **block-no-verify** | Prevent bypass of quality gates | `npx block-no-verify@1.1.2` in beforeShellExecution |
| **Session Evaluation** | Cost + quality tracking across sessions | stop hooks: cost-tracker + evaluate-session |
| **Small Files, High Cohesion** | 200-400 lines typical, 800 max | ECC coding style enforced in guardrails |
| **Explicit Error Handling** | Never silently swallow errors | ECC common-coding-style.md rule |

---

### 10.2 Anti-Patterns

#### Skipping Gates [CONFIRMED]

**Pattern**: Bypassing G0/G1/UI Gate because the task "feels small."

**Why it fails**: G0 skips lead to unnecessary code. G1 skips lead to two half-finished features and context fragmentation. UI Gate skips lead to unspecified screens where every state is undefined.

**Correct behavior**:
- G0 is checked before every mode. No exceptions.
- G1 bypasses only for P0 bugs, /deploy, and /sec.
- UI Gate is checked in Step 4 of every /one-flow that touches UI files.

---

#### Fixing Symptoms Without Root Cause [CONFIRMED]

**Pattern**: Changing the error message when the real problem is missing validation.

**Why it fails**: The ER-Ribosome loop exists precisely for this. Each iteration must produce NEW evidence. If you repeat the same fix pattern three times, you're fixing symptoms.

**Correct behavior**:
- Each /fix attempt must document: "What new evidence did this iteration produce?"
- After 3 failures on same root cause → HALT → escalate to /core
- If /core also fails → document in LESSONS_ARCHITECTURE.md → halt for human

---

#### Silent Scope Changes [CONFIRMED]

**Pattern**: Expanding the plan mid-implementation without updating Decisions.

**Why it fails**: Elazar checks that the task maps to an R-id. If scope expands silently, the commit touches work that has no vision evidence. The commit is blocked, or worse, slips through with false approval.

**Correct behavior**:
- Scope changes require re-running the Decisions section.
- If new R-id needed → update REQUIREMENTS.md first.
- If new R-id contradicts non-goals → HALT (Ambiguity Guard or Elazar will catch it).

---

#### Building Without Searching First [CONFIRMED]

**Pattern**: Implementing a custom date picker when the stack already has one. Implementing auth from scratch when the framework has middleware.

**Why it fails**: Wastes dev cycles, introduces unvetted code, increases surface area.

**Correct behavior**:
- Eng Review Step 3c explicitly checks: "Does the framework have a built-in for each pattern?"
- /research mode exists for pre-build investigation of unfamiliar territory.
- Search Before Building: look in `node_modules`, framework docs, existing codebase before writing new code.

---

#### Committing Without Evidence [CONFIRMED]

**Pattern**: Bypassing `last_vision_check.txt` by using `--no-verify` or by writing the file manually without running verify-vision.

**Why it fails**: The commit evidence lock exists because AI can rationalize almost any change as aligned with vision. The Council provides an independent check.

**Correct behavior**:
- block-no-verify prevents `--no-verify` bypass.
- `last_vision_check.txt` must be written by the actual workflow (post-Elazar APPROVE or /fix FIX-BYPASS).
- Manual writing of the file is the worst anti-pattern — it defeats the purpose of the gate.

---

#### Auto-Writing DNA-Protected Files [CONFIRMED]

**Pattern**: Letting Claude update STATE.md, MEMORY.md, or LESSONS_*.md automatically at session end.

**Why it fails**: These files are the permanent record. Auto-updates introduce AI-generated "facts" into the permanent record without human review.

**Correct behavior**:
- `autoMemory: false` in settings.json.
- SessionEnd hook REMINDS the user to update. It does not write.
- All updates to DNA files require: user approval + visible diff in chat.
- "Show the user the proposed entry and get approval before writing" — the canonical phrase.

---

#### Running Dev Servers Without tmux [CONFIRMED]

**Pattern**: Running `npm run dev` directly (no tmux). ECC's dev-server-block hook blocks this.

**Why it fails**: Log access is impossible without tmux. Long-running processes die with the Claude Code session.

**Correct behavior**:
```bash
tmux new-session -d -s dev "npm run dev"
# Access logs:
tmux attach -t dev
# Or read log directly:
tmux capture-pane -t dev -p
```

---

#### Using Codex as the Primary Executor [INFERRED]

**Pattern**: Routing implementation work through Codex CLI rather than Claude Code.

**Why it fails**: Codex runs in read-only sandbox (`-s read-only`). It has no access to AVNER governance files. It cannot run gates, invoke Council agents, or enforce DNA Safety.

**Correct behavior**:
- Codex = second opinion, reviewer, strategic challenger.
- Claude Code = primary executor and governor.
- Use `/codex review` after Claude Code has made changes, not before.

---

#### Mixing feat + fix + refactor in One Commit [CONFIRMED]

**Pattern**: One large commit that adds a feature, fixes a bug, and refactors a module.

**Why it fails**: Impossible to revert selectively. Gate evidence is ambiguous (which type of work needs which gate?). Code review is cognitively overwhelming.

**Correct behavior**:
- One logical change = one commit.
- Plan tasks are atomic: max 5 files per task in /new, max 3 files in /fix.
- Commit format is type-specific: `feat(scope): X` vs `fix(scope): Y` vs `refactor(scope): Z`.

---

#### Ignoring the Verify Gate for "Small Deploys" [CONFIRMED]

**Pattern**: Skipping verify-ops and verify-security for a "one-line config change."

**Why it fails**: Shimon's hardest rules fire on exactly the things that look small — env var changes, auth config tweaks, secrets in config files.

**Correct behavior**:
- The Verify Gate fires for ALL /deploy operations. No exceptions.
- "Small" deploys that touch sensitive areas trigger Shimon's full scan.
- Build must succeed: if build fails for any reason → NO-GO. Period.

---

## Appendix A: Model Routing Table [CONFIRMED]

| Mode / Task | Model | Reason |
|-------------|-------|--------|
| `/sec` | Opus 4.6 | Full adversarial thinking required |
| Vision decisions | Opus 4.6 | Strategic product thinking |
| Elazar (verify-vision) | Opus 4.6 | CTO-level alignment check |
| Shimon (verify-security) | Opus 4.6 | Adversarial threat modeling |
| `/core`, `/review` | opusplan | Opus for Decisions/Plan, Sonnet for Execute |
| `/new`, `/fix`, `/deploy`, `/research`, `/prune` | Sonnet 4.6 | Speed + quality balance |
| `/ui`, `/ui-review` | Sonnet 4.6 | Pattern matching + spec compliance |
| Eliezer (verify-spec) | Sonnet 4.6 | Exactness at speed |
| Yehoshua (verify-integration) | Sonnet 4.6 | Connection checking |
| Yossi (verify-ops) | Sonnet 4.6 | Operational readiness checklist |
| `/pol`, quick reads, formatting, searches | Haiku 4.5 | Cost efficiency |

**Context pressure rules**: [CONFIRMED]
- > 70%: prefer minimal scope, one task at a time, consider /compact
- > 90%: Haiku for reads, run /compact, smallest step only

---

## Appendix B: Codex CLI Setup [CONFIRMED]

```bash
# Install Codex CLI
npm install -g @openai/codex

# Check installation
which codex  # if not found, stop and notify user

# Codex uses its own auth from ~/.codex/ — no OPENAI_API_KEY env var needed

# Codex runs in read-only sandbox
# -s read-only prevents any writes to project files

# Usage in AVNER v8:
codex review --base main -c 'model_reasoning_effort="xhigh"' --enable web_search_cached
```

**Codex session continuity**: Session ID saved to `.context/codex-session-id`. Use for follow-up questions in the same session. [CONFIRMED]

**Codex MCP servers** (from `.codex/config.toml`) [CONFIRMED]:
```toml
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "live"

[mcp_servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]

[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp@latest"]

[mcp_servers.exa]
url = "https://mcp.exa.ai/mcp"

[mcp_servers.memory]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-memory"]

[mcp_servers.playwright]
command = "npx"
args = ["-y", "@playwright/mcp@latest", "--extension"]

[mcp_servers.sequential-thinking]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-sequential-thinking"]

[features]
multi_agent = true
```

---

## Appendix C: Cross-Model Analysis Protocol [CONFIRMED]

When both Claude's `/review` and Codex's `/codex review` have run:

```
CROSS-MODEL ANALYSIS:
  Both found:        [findings that overlap between Claude and Codex]
  Only Codex found:  [findings unique to Codex]
  Only Claude found: [findings unique to Claude's /review]
  Agreement rate:    X% (N/M total unique findings overlap)
```

**Significance**:
- Both found: high-confidence issues, must fix
- Only Codex found: Claude may have missed — investigate
- Only Claude found: model-dependent — Codex may have different blindspot
- Low agreement rate (< 50%): complex/ambiguous code — escalate to human review

**Note**: Present Codex output verbatim. Never summarize or truncate. Codex is the "200 IQ autistic developer" — direct, terse, technically precise. [CONFIRMED]

---

## Appendix D: GStack GSTACK REVIEW REPORT Format [CONFIRMED]

Auto-maintained in plan files after GStack reviews:

```markdown
## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | /plan-ceo-review | Scope & strategy | {runs} | {status} | {findings} |
| Codex Review | /codex review | Independent 2nd opinion | {runs} | {status} | {findings} |
| Eng Review | /plan-eng-review | Architecture & tests (required) | {runs} | {status} | {findings} |
| Design Review | /plan-design-review | UI/UX gaps | {runs} | {status} | {findings} |

VERDICT: {summary}
```

---

## Appendix E: AVNER v8 Quick Start Checklist

For a new project:

```
[ ] 1. Create CLAUDE.md from Section 3 template. Fill in Identity.
[ ] 2. Create .claude/settings.json from Section 7.4.
[ ] 3. Create .claude/rules/01-protocol.md (lifecycle, gates, verification artifact).
[ ] 4. Create .claude/rules/02-models.md (model routing table).
[ ] 5. Create .claude/skills/ directory with all 14 SKILL.md files.
[ ] 6. Create .claude/agents/ directory with all 5 Council agent files.
[ ] 7. Create .avner/ directory structure (4 worlds).
[ ] 8. Write .avner/MEMORY.md — identity, non-goals, sensitive areas.
[ ] 9. Write .avner/1_vision/VISION.md — target user, problem, value prop.
[ ] 10. Write .avner/1_vision/REQUIREMENTS.md — R-id table with owners and evidence.
[ ] 11. Write .avner/1_vision/GAP_ANALYSIS.md — current vs. missing.
[ ] 12. Write .avner/2_architecture/TECHSTACK.md — stack, commands, skill registry.
[ ] 13. Create .avner/4_operations/STATE.md — initial PLANNED tasks.
[ ] 14. Create .avner/4_operations/RUNBOOK.md — deploy checklist.
[ ] 15. (Optional) Install ECC: npm install -g everything-claude-code, export ECC_HOOK_PROFILE=standard
[ ] 16. (Optional) Install Codex: npm install -g @openai/codex
[ ] 17. Start first session: type /avner to see state, then /one-flow to begin work.
```

---

*AVNER v8 Complete Specification — Generated 2026-03-29*
*All content sourced from: GSTACK_SKILL_REFERENCE.md, ECC_HOOKS_SETUP.md, UI_SKILL_SPEC.md, AVNER_FILE_FORMATS.md, CLAUDE_CODE_CODEX_BRIDGE.md, avner-stack/docs/AVNER_v7-FINAL.md, avner-stack/skills/avner/SKILL.md, avner-stack/skills/one-flow/SKILL.md, avner-stack/vendor/gstack/ARCHITECTURE.md, avner-stack/vendor/gstack/ETHOS.md*
