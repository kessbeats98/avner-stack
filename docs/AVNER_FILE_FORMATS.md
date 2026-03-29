# AVNER_FILE_FORMATS.md — AVNER v8 Reference Document
# Phase D: AVNER v7 File Formats, Gates, and Council Protocol

> **Sources**: `avner-stack/docs/AVNER_v7-FINAL.md`, `avner-stack/docs/OVERVIEW.md`,
> `avner-stack/docs/ONBOARDING_NEW_PROJECT.md`, `avner-stack/docs/ONBOARDING_EXISTING_PROJECT.md`,
> `avner-stack/skills/avner/SKILL.md`, `avner-stack/skills/one-flow/SKILL.md`,
> `avner-stack/templates/project/` (all templates),
> `avner-stack/agents/` (all 5 Council agents)
>
> **Annotation key**: [CONFIRMED] = directly read in source files · [INFERRED] = reasoned from multiple sources · [MISSING] = not found, proposed for v8

---

## Table of Contents

1. [AVNER File Tree — Complete Structure](#1-avner-file-tree)
2. [CLAUDE.md Format](#2-claudemd-format)
3. [.avner/MEMORY.md Format](#3-memorymd-format)
4. [.avner/1_vision/ Contents](#4-1_vision-contents)
5. [.avner/2_architecture/ Contents](#5-2_architecture-contents)
6. [.avner/3_contracts/ Contents](#6-3_contracts-contents)
7. [.avner/4_operations/ Contents](#7-4_operations-contents)
8. [LESSONS_*.md Format (all four)](#8-lessons_md-format)
9. [STATE.md Format](#9-statemd-format)
10. [RUNBOOK.md Format](#10-runbookmd-format)
11. [Gates System — Complete Reference](#11-gates-system)
12. [Council Agents — Roles and Protocol](#12-council-agents)
13. [Modes DSL — All Modes](#13-modes-dsl)
14. [settings.json — Hooks and Permissions](#14-settingsjson)
15. [Commit Evidence Lock](#15-commit-evidence-lock)
16. [DNA Safety Rule](#16-dna-safety-rule)
17. [Model Routing Table](#17-model-routing-table)

---

## 1. AVNER File Tree

[CONFIRMED from `AVNER_v7-FINAL.md` and `OVERVIEW.md`]

```
project-root/
├── CLAUDE.md                              ← Project constitution (DNA protected)
├── .claude/
│   ├── settings.json                      ← Hooks, permissions, model routing
│   ├── rules/
│   │   ├── 01-protocol.md                 ← Lifecycle, gates, verification artifact
│   │   └── 02-models.md                   ← Model routing table
│   ├── skills/
│   │   ├── prune/SKILL.md                 ← /prune mode
│   │   ├── new/SKILL.md                   ← /new mode
│   │   ├── fix/SKILL.md                   ← /fix mode
│   │   ├── pol/SKILL.md                   ← /pol mode
│   │   ├── sec/SKILL.md                   ← /sec mode
│   │   ├── deploy/SKILL.md                ← /deploy mode
│   │   ├── core/SKILL.md                  ← /core mode
│   │   ├── research/SKILL.md              ← /research mode
│   │   ├── review/SKILL.md                ← /review mode + handoff template
│   │   ├── save/SKILL.md                  ← /save mode (v6.9+)
│   │   ├── avner/SKILL.md                 ← /avner governance manager
│   │   ├── one-flow/SKILL.md              ← /one-flow end-to-end delivery
│   │   ├── ui/SKILL.md                    ← /ui design contract
│   │   └── ui-review/SKILL.md             ← /ui-review pillar audit
│   └── agents/
│       ├── verify-vision.md               ← Elazar (Vision Gate)
│       ├── verify-spec.md                 ← Eliezer (Spec Guardian)
│       ├── verify-integration.md          ← Yehoshua (Integration Check)
│       ├── verify-ops.md                  ← Yossi (SRE / Deploy)
│       └── verify-security.md             ← Shimon (CISO / Veto)
└── .avner/
    ├── MEMORY.md                          ← Project seed (DNA protected, loaded every session)
    ├── AGENT_CONSTITUTION.md              ← Agent identity/constraints (v7.0+)
    ├── LESSONS_VISION.md                  ← Lessons from vision phase (DNA protected)
    ├── LESSONS_ARCHITECTURE.md            ← Lessons from architecture phase (DNA protected)
    ├── LESSONS_CONTRACTS.md               ← Lessons from contracts phase (DNA protected)
    ├── LESSONS_OPERATIONS.md              ← Lessons from operations phase (DNA protected)
    ├── 1_vision/
    │   ├── VISION.md                      ← Target user, value prop, metrics
    │   ├── REQUIREMENTS.md                ← R-id table with traceability
    │   └── GAP_ANALYSIS.md                ← Current vs. missing capabilities
    ├── 2_architecture/
    │   ├── ARCHITECTURE.md                ← System design, component diagram
    │   └── TECHSTACK.md                   ← Stack table, commands, skill registry
    ├── 3_contracts/
    │   ├── API_CONTRACTS.md               ← Endpoints, error shapes, versioning
    │   ├── DB_SCHEMA.md                   ← Tables, migrations, relationships
    │   └── UI_SPEC.md                     ← 6-pillar UI design contract
    └── 4_operations/
        ├── STATE.md                        ← Tasks, session continuity (DNA protected)
        ├── RUNBOOK.md                      ← Deploy checklist, rollback
        ├── UI_REVIEW.md                    ← 6-pillar audit log (DNA protected)
        ├── last_vision_check.txt           ← Commit evidence lock file (v7.0+)
        └── STATE.md.bak                    ← Auto-backup before compaction
```

**Four Worlds (A.B.I.A.)**: [CONFIRMED]
- **Vision** `.avner/1_vision/` — WHY we build
- **Architecture** `.avner/2_architecture/` — WHAT we build
- **Contracts** `.avner/3_contracts/` — HOW we build
- **Operations** `.avner/4_operations/` — DO it safely

---

## 2. CLAUDE.md Format

[CONFIRMED from `templates/project/CLAUDE.md.tmpl` and `AVNER_v7-FINAL.md`]

```markdown
# AVNER v7.0 — One-Dev Software House

## Quick Start (5 minutes)
1. Fill in Identity below (if not already set by avner-init).
2. Write .avner/MEMORY.md — identity, non-goals, sensitive areas.
3. Write .avner/1_vision/VISION.md — target user, core problem, metrics.
4. Pick your first task. Use /fix for bugs or /new for features.
5. Or run /one-flow for full plan-to-ship workflow.

## Identity
- Project:  [PROJECT_NAME]
- Stack:    [STACK]
- Goal:     [One sentence — what does production-ready mean here?]

## Worlds (A.B.I.A)
- Vision:    .avner/1_vision/        (WHY)
- Arch:      .avner/2_architecture/  (WHAT)
- Contracts: .avner/3_contracts/     (HOW)
- Ops:       .avner/4_operations/    (DO)

## The Council
- Elazar   (Vision Gate):        .claude/agents/verify-vision.md       100% of /new and /core
- Eliezer  (Spec Guardian):      .claude/agents/verify-spec.md         ~15% of tasks
- Yehoshua (Integration Check):  .claude/agents/verify-integration.md  invoked by Yossi
- Yossi    (SRE / Deploy):       .claude/agents/verify-ops.md          /deploy only
- Shimon   (CISO / Veto):        .claude/agents/verify-security.md     /deploy + sensitive

Most tasks trigger 0-1 Council members. All 5 firing = something big is happening.

## Modes (DSL)
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
/one-flow → End-to-end feature delivery (plan → review → build → QA → ship)
/ui       → Create or update UI design contract (UI_SPEC.md)
/ui-review → Retroactive 6-pillar UI audit (UI_REVIEW.md)

## Council Protocol (Meta-Priority — first match wins)
0. The Elon Gate       → Delete First? Can this be solved by removing? Redirect to /prune.
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

Patterns:
- /new:    feat(scope): description
- /fix:    fix(scope): description
- /core:   refactor(scope): description
- /sec:    sec(scope): mitigation description
- /deploy: chore(deploy): v[version] — what shipped
- /pol:    style(scope): what was polished
- /save:   wip(TASK-XX): progress summary

## Commit Evidence Lock
Before committing, evidence must exist in .avner/4_operations/last_vision_check.txt:
- /new and /core: APPROVE <timestamp> (written by verify-vision after APPROVE verdict)
- /fix: FIX-BYPASS <timestamp> (written before commit in /fix workflow)
The PreToolUse hook blocks git commit if this file is missing or invalid.

## Models
- Opus 4.6     → /sec, vision decisions (full adversarial thinking)
- opusplan     → /core, /review (Opus for Decisions/Plan, Sonnet for Execute)
- Sonnet 4.6   → /new, /fix, /deploy, /research, /prune, integration
- Haiku 4.5    → /pol, quick reads, searches, formatting

## DNA Safety Rule (חוק יסוד)
Claude NEVER modifies these files without explicit user approval + visible diffs:
- CLAUDE.md (constitution)
- .avner/MEMORY.md (permanent memory)
- .avner/4_operations/STATE.md (session state)
- .avner/*/LESSONS_*.md (lessons learned)

Auto Memory is disabled. All "learned rules" must be proposed in-chat, not auto-appended.
Hooks may READ these files. Hooks may REMIND user to update. Hooks NEVER WRITE to them.

NOTE: Hooks rely on Bash. On Windows, run Claude Code via Git Bash or WSL.

> One rule to keep CLAUDE.md honest:
> "Would removing this line cause mistakes? If not — cut it."
```

---

## 3. MEMORY.md Format

[CONFIRMED from `templates/project/.avner/MEMORY.md.tmpl`]

Located at: `.avner/MEMORY.md`
DNA Safety Rule applies: never auto-modified. Keep under 200 lines.
Loaded at every session start via SessionStart hook.

```markdown
# AVNER Memory — Project Seed
# Auto-loaded at session start. Keep under 200 lines.

## Identity
- Project:       [PROJECT_NAME]
- Stack:         [STACK]
- Soul Purpose:  [GOAL — one sentence, production-ready definition]
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

## 4. 1_vision/ Contents

### VISION.md

[CONFIRMED from `templates/project/.avner/1_vision/VISION.md.tmpl`]

```markdown
# Vision — [PROJECT_NAME]

## Target User
- Who: [Describe the specific person — role, context, pain level]
- Where: [How do they find you? Where do they feel the pain?]

## Core Problem
[One sentence — what sucks about the status quo?]

## Value Proposition
[One sentence — what does [PROJECT_NAME] make possible that wasn't before?]

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

### REQUIREMENTS.md

[CONFIRMED from `templates/project/.avner/1_vision/REQUIREMENTS.md.tmpl`]

```markdown
# Requirements — [PROJECT_NAME]

## V1 (Must Ship for "Done")
| ID | Requirement | Acceptance Criteria | Priority | Owner | Evidence |
|----|-------------|---------------------|----------|-------|---------|
| R1 | [What] | [How verified] | P0 | @name | [Source] |
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

### GAP_ANALYSIS.md

[CONFIRMED from `templates/project/.avner/1_vision/GAPANALYSIS.md.tmpl`]

```markdown
# Gap Analysis — [PROJECT_NAME]

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

## 5. 2_architecture/ Contents

### ARCHITECTURE.md

[CONFIRMED from `templates/project/.avner/2_architecture/ARCHITECTURE.md.tmpl`]

```markdown
# Architecture — [PROJECT_NAME]

## System Overview
[STACK]
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

### TECHSTACK.md

[CONFIRMED from `templates/project/.avner/2_architecture/TECHSTACK.md.tmpl`]

```markdown
# Tech Stack — [PROJECT_NAME]

## Stack
| Layer | Technology | Version | Notes |
|-------|-----------|---------|-------|
| Framework | [STACK] | | |
| Database | | | |
| Auth | | | |
| Payments | | | |
| Hosting | | | |
| CI/CD | | | |

## Commands
| Action | Command |
|--------|---------|
| Dev server | |
| Build | |
| Test | |
| Lint | |
| Type check | |
| Migrations | |

## Internal Skill Registry
| Skill | Source | Status |
|-------|--------|--------|
| /one-flow | avner-stack | installed |
| /ui | avner-stack | installed |
| /ui-review | avner-stack | installed |
| /avner | avner-stack | installed |

## Air-Gapped Rule
External community skills are STRICTLY PROHIBITED (supply-chain risk).
No `find-skills` command. No `npx skills add url --skill find-skills` or similar.
Only local `./skills/` and official avner-stack skills permitted.
This table is the authoritative skill registry. Update when adding skills.
```

---

## 6. 3_contracts/ Contents

### API_CONTRACTS.md

[CONFIRMED from `templates/project/.avner/3_contracts/APICONTRACTS.md.tmpl`]

```markdown
# API Contracts — [PROJECT_NAME]

## Endpoints
| Method | Path | Description | Auth | Request Body | Response |
|--------|------|-------------|------|-------------|---------|
| GET | /api/health | Health check | none | — | { status: "ok" } |

## Error Shape (standard)
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable message",
    "details": {}
  }
}

## Status Codes
| Code | Meaning | When |
|------|---------|------|
| 200 | OK | Successful read/update |
| 201 | Created | Successful creation |
| 400 | Bad Request | Validation failure |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 500 | Internal Error | Unexpected server error |

## Versioning Policy
- API changes must be additive (new fields, new endpoints).
- Removals or type changes require /core escalation and migration plan.
- Breaking changes must update this document BEFORE implementation.
```

**verify-spec triggers for API changes**: [CONFIRMED]
- Backward-compatible change (additive only) → PASS with explicit note
- Backward-incompatible change (removal, rename, type change, status code change) → ESCALATE-TO-CORE

### DB_SCHEMA.md

[CONFIRMED from `templates/project/.avner/3_contracts/DBSCHEMA.md.tmpl`]

```markdown
# DB Schema — [PROJECT_NAME]

## Tables
| Table | Description | Key Columns |
|-------|-------------|-------------|
| [table_name] | [purpose] | id, created_at, updated_at |

## Schema Details

### [table_name]
| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| id | uuid | no | gen_random_uuid() | PK |
| created_at | timestamptz | no | now() | |
| updated_at | timestamptz | no | now() | |

## Indexes
| Table | Index | Columns | Type |
|-------|-------|---------|------|

## Relationships
| From | To | Type | FK |
|------|----|------|-----|

## Migration Log
| Date | Migration | Description | Status |
|------|-----------|-------------|--------|
| | | | pending / applied / rolled back |

## Rules
- All schema changes require /core escalation.
- Destructive migrations (column drop, table drop) require explicit user approval.
- This document must be updated BEFORE running migrations.
```

### UI_SPEC.md

Located at: `.avner/3_contracts/UI_SPEC.md`
Full format is in `UI_SKILL_SPEC.md` Section 4. [CONFIRMED]

---

## 7. 4_operations/ Contents

### STATE.md

[CONFIRMED from `templates/project/.avner/4_operations/STATE.md.tmpl`]

DNA Safety Rule applies.
Updated after every session (with user approval).
Session hooks auto-backup to `STATE.md.bak` before compaction.

```markdown
# Project State — [PROJECT_NAME]

Updated: [YYYY-MM-DD]
Phase:   [Vision / Architecture / Contracts / Operations]
Version: [current tag or commit hash]

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

### TASK-01: [Title] (PLANNED)
**Priority**: P1
**Status**: PLANNED (YYYY-MM-DD)

[Description of the task]

---

## Backlog

### TASK-XX: [Title] (PLANNED)
**Priority**: P3
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

**STATE.md Parsing Rules** (used by all modes): [CONFIRMED]
- Extract tasks from `###` headers
- Regex: `^###\s+(~~)?((TASK|BUG|FEAT)-\d+)(~~)?:\s*(.+?)\s*\(([^)]+)\)`
- Status normalization:
  - Contains "DONE", "✅", or has strikethrough → `DONE`
  - Contains "IN PROGRESS" → `IN PROGRESS`
  - Contains "REVIEW" → `REVIEW`
  - Contains "PAUSED" → `PAUSED`
  - Otherwise → `PLANNED`
- Priority: Look for `**Priority**: P0-P3` below header. Default P2.

**Task Scoring** (used by `/avner:next`): [CONFIRMED]
- Status weight: IN PROGRESS (100), REVIEW (80), PLANNED (50), PAUSED (30)
- Priority weight: P0 (40), P1 (30), P2 (20), P3 (10)
- Total = status weight + priority weight

### RUNBOOK.md

[CONFIRMED from `templates/project/.avner/4_operations/RUNBOOK.md.tmpl`]

```markdown
# Runbook — [PROJECT_NAME]

## Deploy Checklist
1. [ ] All tests pass
2. [ ] Build succeeds
3. [ ] verify-ops: GO
4. [ ] verify-security: GO
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

### UI_REVIEW.md

Located at: `.avner/4_operations/UI_REVIEW.md`
Full format is in `UI_SKILL_SPEC.md` Section 5. [CONFIRMED]

### last_vision_check.txt

[CONFIRMED from `AVNER_v7-FINAL.md` v7.0 new feature]

```
APPROVE 1717000000
```
or
```
FIX-BYPASS 1717000001
```

Written by:
- `/new` and `/core` (after verify-vision returns APPROVE): `echo "APPROVE $(date +%s)" > .avner/4_operations/last_vision_check.txt`
- `/fix` (before commit): `echo "FIX-BYPASS $(date +%s)" > .avner/4_operations/last_vision_check.txt`

Read by: PreToolUse hook on `git commit`. Commit is BLOCKED if file is missing or doesn't match `^(APPROVE|FIX-BYPASS)`.

---

## 8. LESSONS_*.md Format

[CONFIRMED from all four `templates/project/.avner/LESSONS_*.md.tmpl` files]

All four LESSONS files share the same format. DNA Safety Rule applies to all four.

Files:
- `.avner/LESSONS_VISION.md` — product direction, user needs, scope decisions
- `.avner/LESSONS_ARCHITECTURE.md` — system design, tech choices, structural decisions
- `.avner/LESSONS_CONTRACTS.md` — API design, schema changes, interface contracts
- `.avner/LESSONS_OPERATIONS.md` — deploys, incidents, monitoring, operational procedures

```markdown
# Lessons — [Vision / Architecture / Contracts / Operations]

Record what we learned about [domain]. 
DNA Safety Rule: Claude must not edit this file without explicit user approval + visible diffs.

---

## Entries

### [YYYY-MM-DD] [Title]
- **What happened**: [brief description]
- **What we learned**: [insight]
- **Action taken**: [how this changed our approach]

---

## Incidents
| Date | Incident | Impact | Resolution |
|------|----------|--------|-----------|
| | | | |
```

**When to update**: After significant events, during `/review` handoff, at end of sprint.
**Who approves**: The user — Claude proposes, never auto-writes.

---

## 9. STATE.md Format

> See Section 7 above for full format. Key additional notes:

**Priority levels**: [CONFIRMED]
- P0 = Critical / production emergency
- P1 = Must-have for next release
- P2 = Default priority
- P3 = Nice-to-have / backlog

**G1 Block**: Any IN PROGRESS task in STATE.md blocks starting new TASK/FEAT. [CONFIRMED]
Exceptions:
- P0 bugs bypass G1
- `/deploy` always bypasses
- `/sec` always bypasses

---

## 10. RUNBOOK.md Format

> See Section 7 above for full format.

---

## 11. Gates System — Complete Reference

[CONFIRMED from `AVNER_v7-FINAL.md` `.claude/rules/01-protocol.md` section, `skills/avner/SKILL.md`, `skills/one-flow/SKILL.md`]

The gates are checked in priority order. First match wins.

### G0 — The Elon Gate (DELETE FIRST)

**When**: Before ANY mode starts. Global rule. [CONFIRMED]
**Question**: "Can this outcome be achieved by removing an existing obstacle instead of adding code/complexity?"
**If YES**: HALT current intent → redirect immediately to `/prune`
**If NO**: Continue to G1

**Checked by**: Every mode pre-flight. `/prune` is the target mode.
**Also triggers**: When verify-vision returns `SOLVE-BY-REMOVAL` verdict.

### G1 — Finish Before Start

**When**: Before `/new` or `/core` (and before any TASK/FEAT in `/one-flow`). [CONFIRMED]
**Question**: "Does STATE.md have any task with status IN PROGRESS?"
**If YES**: REFUSE new TASK/FEAT. Say: `"⛔ G1 Block: Complete [TASK-XX] before starting new work."`
**If NO**: Continue

**Exceptions** (bypass G1): [CONFIRMED]
- P0 bugs
- `/deploy` (production emergencies cannot be blocked)
- `/sec` (security emergencies cannot be blocked)

### UI Gate — Design Contract Checkpoint

**When**: In `/one-flow` Step 4, before implementation when UI files are in plan. [CONFIRMED]
**Question**: "Are affected screens defined in UI_SPEC.md?"
**If screens missing from spec**: Run `/ui` workflow inline → get user approval → then proceed
**If screens present**: Confirm spec is current before proceeding

**Note**: This gate has no hard stop — it's conditional on whether UI work is planned.

### G2 — Contracts (Spec Guardian)

**When**: After `/new` or `/fix` modifies DB schema / public API signatures / global state. [CONFIRMED]
**Agent**: verify-spec (Eliezer)
**Trigger**: Changes that touch:
  - DB schema or migrations
  - Public API signatures, route handlers, exported types
  - Global or shared state, env contracts, auth primitives
**If FAIL**: Fix the spec violation before continuing
**If ESCALATE-TO-CORE**: Pause and inform user → switch to `/core`

### Verify Gate — Pre-Deploy

**When**: Before `/deploy` completes. Both agents must pass. [CONFIRMED]
**Agents**: verify-ops (Yossi) + verify-security (Shimon)
**Verdicts**:
  - verify-ops: GO / NO-GO / CONDITIONAL-GO
  - verify-security: GO / NO-GO / NEEDS-MITIGATION
**Rules**:
  - Both must return GO to proceed.
  - verify-ops CONDITIONAL-GO: acceptable only with explicit human confirmation.
  - verify-security NO-GO: hard stop. No exceptions. Shimon has veto authority.
  - Build fails → NO-GO. Period.
  - Required env vars missing → NO-GO. Period.
  - Destructive migration → NO-GO. Period.

### Full Gate Priority Order (CLAUDE.md meta-priority)

| # | Gate | Trigger | Action |
|---|------|---------|--------|
| 0 | Elon Gate | Any mode | Delete First? → /prune |
| 1 | Finish Before Start | /new, /core, TASK/FEAT | IN PROGRESS in STATE? → REFUSE |
| 2 | Ambiguity Guard | Any mode | Vague intent → HALT, ask one question |
| 3 | Safety Interrupt | Any mode | Unknown impact → HALT |
| 4 | Security Override | Sensitive areas touched | → escalate to /sec |
| 5 | Architect Trigger | DB/API/global state touched | → escalate to /core |
| 6 | Efficiency Downgrade | Overkill detected | → prefer boring, minimal change |
| 7 | Execute | All gates passed | Run the mode |

---

## 12. Council Agents — Roles and Protocol

[CONFIRMED from `avner-stack/agents/` directory — all 5 agents read directly]

### Council Summary Table

| Agent Name | Character | Role | When Invoked | Timeout Default | Verdicts |
|-----------|-----------|------|-------------|-----------------|---------|
| Elazar (verify-vision) | R. Elazar ben Arach | Vision Gate | 100% of /new and /core | HALT | APPROVE / HALT / NEEDS-CLARIFICATION / SOLVE-BY-REMOVAL |
| Eliezer (verify-spec) | R. Eliezer ben Hyrcanus | Spec Guardian | ~15% of tasks (contracts touched) | FAIL | PASS / FAIL / ESCALATE-TO-CORE |
| Yehoshua (verify-integration) | R. Yehoshua ben Hananiah | Integration Check | Invoked by Yossi | FAIL | PASS / FAIL / NEEDS-REVIEW |
| Yossi (verify-ops) | R. Yosi ben Yoenam | SRE / Deploy | /deploy only | NO-GO | GO / NO-GO / CONDITIONAL-GO |
| Shimon (verify-security) | R. Shimon ben Netanel | CISO / Veto | /deploy + sensitive areas | NO-GO | GO / NO-GO / NEEDS-MITIGATION |

"Most tasks trigger 0-1 Council members. All 5 firing = something big is happening." [CONFIRMED]

### Elazar (verify-vision) — Full Protocol

[CONFIRMED from `agents/verify-vision.md`]

**Model**: Opus
**Tools**: Read, Glob (read-only)
**Disallowed**: Bash, Write, Edit
**Max turns**: 12

**Sources of truth** (priority order):
1. VISION.md
2. MEMORY.md
3. REQUIREMENTS.md
4. ARCHITECTURE.md
5. API_CONTRACTS/DB_SCHEMA
6. GAP_ANALYSIS.md
7. STATE.md

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

**Hard rules**: [CONFIRMED]
- Conflict with explicit non-goals → HALT
- Request is vague → NEEDS-CLARIFICATION
- R-id Owner is missing, generic, or lacks Evidence → HALT
- Key Decision from current session cannot override HALT in same session
- Fail-closed: timeout or no verdict → treat as HALT

### Eliezer (verify-spec) — Full Protocol

[CONFIRMED from `agents/verify-spec.md`]

**Model**: Sonnet
**Tools**: Read, Glob, Grep, Bash
**Disallowed**: Write, Edit
**Max turns**: 18

**Protocol**:
1. Run `git diff --name-only` then `git diff`
2. Identify if changes touch: DB schema, public API signatures, global state
3. Compare behavior vs spec: endpoints, request/response shapes, status codes, backward compat

**Hard rules**: [CONFIRMED]
- DB/API/global-state change detected → ESCALATE-TO-CORE
- Backward-incompatible change → ESCALATE-TO-CORE
- Backward-compatible additive change → PASS with explicit note
- Fail-closed: timeout → FAIL

### Yehoshua (verify-integration) — Full Protocol

[CONFIRMED from `agents/verify-integration.md`]

**Model**: Sonnet
**Tools**: Read, Glob, Grep, Bash
**Disallowed**: Write, Edit
**Max turns**: 20
**Isolation**: worktree

**Protocol**:
1. `git diff --name-only` then `git diff`
2. Identify integration points touched (API calls, webhooks, auth middleware, DB queries, external SDKs)
3. Verify caller and callee are still compatible for each integration point
4. Check error cases are handled at every boundary

**Output**: PASS / FAIL / NEEDS-REVIEW + broken pipes (file+line) + missing error handling

### Yossi (verify-ops) — Full Protocol

[CONFIRMED from `agents/verify-ops.md`]

**Model**: Sonnet
**Tools**: Read, Glob, Grep, Bash
**Disallowed**: Write, Edit
**Max turns**: 15
**Isolation**: worktree

**Checklist** (all must pass for GO):
- Env vars: compare .env.example against deployment env
- Build: run project's build command
- Migrations: any pending? non-destructive?
- Monitoring: error tracking, health endpoints
- Smoke tests
- Integration: invoke verify-integration (Yehoshua)

**Hard rules**: [CONFIRMED]
- Build fails → NO-GO. Period.
- Required env vars missing → NO-GO. Period.
- Destructive migration → NO-GO. Period.
- CONDITIONAL-GO requires explicit human sign-off — no automated continuation

### Shimon (verify-security) — Full Protocol

[CONFIRMED from `agents/verify-security.md`]

**Model**: Opus
**Tools**: Read, Glob, Grep, Bash
**Disallowed**: Write, Edit
**Max turns**: 20
**Isolation**: worktree

**Sensitive areas** (always examine if touched):
- Auth, sessions, tokens, cookies, JWT, passwords
- Middleware, CORS, RBAC/ACL, API keys
- PII, email, phone, ID numbers, encryption, payment logic
- Secrets, env vars, infra config

**Threat model**: auth bypass, injection (SQL/XSS/SSTI), replay attacks, SSRF, IDOR, mass assignment, rate abuse, secrets in code

**Severity**: 🔴 Critical (must fix before deploy) / 🟠 Medium (should fix) / 🟡 Low (optional)

**Hard rules**: [CONFIRMED]
- Secrets or credentials in code → NO-GO. Immediate.
- Auth bypass possible → NO-GO. Immediate.
- Shimon has veto power in /deploy. Yossi executes; Shimon decides.
- If maxTurns reached without completing security coverage → NO-GO (incomplete review)

---

## 13. Modes DSL — All Modes

[CONFIRMED from `AVNER_v7-FINAL.md`, `CLAUDE.md.tmpl`, `skills/avner/SKILL.md`]

| Mode | Purpose | When to Use | Council | Commit Format |
|------|---------|------------|---------|---------------|
| `/prune` | Delete dead code, features, requirements | G0 redirect, proactive cleanup | Optional | `refactor(prune): removed [target]` |
| `/new` | New feature, component, file | Adding net-new product surface | Elazar (always) | `feat(scope): description` |
| `/fix` | Bug fix, logic correction | Existing bug with reproduction | Security (if sensitive) | `fix(scope): description` |
| `/pol` | Polish only — zero logic changes | Style, naming, formatting | None | `style(scope): what was polished` |
| `/sec` | Security review or hardening | Auth/secrets/payments touched | Shimon | `sec(scope): mitigation description` |
| `/deploy` | Ship to production | All tests pass, ready to ship | Yossi + Shimon | `chore(deploy): v[version] — what shipped` |
| `/core` | DB schema / API / architecture | Any contract or structure change | Elazar + Eliezer | `refactor(scope): description` |
| `/research` | Pre-build investigation | Unfamiliar tech, uncertain approach | None | N/A |
| `/review` | Reflect, sweep, handoff | End of sprint, session end | None | N/A |
| `/save` | Save WIP and push | Context pressure, end of session | None | `wip(TASK-XX): progress summary` |
| `/avner` | Governance overview, task selection | Session start, mode selection | N/A | N/A |
| `/one-flow` | End-to-end feature delivery | Full feature from plan to ship | All (as needed) | Per task type |
| `/ui` | Create UI design contract | Before any UI implementation | None | N/A |
| `/ui-review` | Retroactive 6-pillar UI audit | After UI implementation | None | N/A |

### Mode Lifecycle (mandatory for /new and /core)

[CONFIRMED from `01-protocol.md`]

```
Decisions → Plan → Execute → Verify
```

Four mandatory output sections:
1. **Decisions** — what was decided and why, before touching code
2. **Plan** — atomic task list (max 7 tasks for /new, max 3 for /fix)
3. **Execute** — what was actually done, task by task
4. **Verify** — Verification Artifact (mandatory for /fix and /deploy, SHOULD for others)

### Atomic Task Rules

| Mode | Max tasks | Max files per task | Escape hatch |
|------|-----------|-------------------|--------------|
| /new, /core | 7 | 5 | Split into Plan A + Plan B |
| /fix | 3 | 3 | Justification in Decisions |

If /fix needs more than 3 tasks → the bug is a /core problem.

### ER-Ribosome Debug Loop (/fix)

[CONFIRMED from `01-protocol.md`]
- Max 3 iterations on same root cause
- Each failed iteration MUST produce new evidence before next attempt
- After 3 failures → HALT → escalate to /core
- If /core also fails → document in LESSONS_ARCHITECTURE.md → HALT for human

---

## 14. settings.json — Hooks and Permissions

[CONFIRMED from `templates/project/.claude/settings.json.tmpl`]

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
      "eslint *"
    ],
    "deny": [
      ".env",
      "rm -rf",
      "rm -r",
      "sudo",
      "curl * | bash",
      "git push *",
      "git reset --hard *",
      "git checkout -- *"
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

**Non-Node.js stack equivalents**: [CONFIRMED from `ONBOARDING_EXISTING_PROJECT.md`]
| npm command | Python | Go | Rust |
|-------------|--------|-----|------|
| `npm test` | `pytest` | `go test ./...` | `cargo test` |
| `npm run build` | — | `go build ./...` | `cargo build` |
| `npm run lint` | `ruff check .` | `golangci-lint run` | `cargo clippy` |
| `tsc --noEmit` | `mypy .` | — | — |

---

## 15. Commit Evidence Lock

[CONFIRMED from `AVNER_v7-FINAL.md`, `CLAUDE.md.tmpl`]

File: `.avner/4_operations/last_vision_check.txt`

Written by:
- **APPROVE path** (after verify-vision APPROVE): `echo "APPROVE $(date +%s)" > .avner/4_operations/last_vision_check.txt`
- **FIX-BYPASS path** (in /fix before commit): `echo "FIX-BYPASS $(date +%s)" > .avner/4_operations/last_vision_check.txt`

Read by: PreToolUse hook. If `git commit` is detected in the command:
- Check file exists and first line matches `^(APPROVE|FIX-BYPASS)`
- If NOT: `echo 'COMMIT BLOCKED: No valid vision/fix evidence in last_vision_check.txt'; exit 2`

**Fail-closed**: missing file = BLOCKED. [CONFIRMED]
**Note**: This hook uses Bash. On Windows, use Git Bash or WSL. [CONFIRMED]

---

## 16. DNA Safety Rule

[CONFIRMED from `AVNER_v7-FINAL.md`, `CLAUDE.md.tmpl`, all SKILL.md files]

**Protected files** — Claude NEVER modifies without explicit user approval + visible diffs:
- `CLAUDE.md` (project constitution)
- `.avner/MEMORY.md` (permanent memory)
- `.avner/4_operations/STATE.md` (session state)
- `.avner/*/LESSONS_*.md` (all four lessons files)
- `.avner/4_operations/UI_REVIEW.md` (UI audit log) [CONFIRMED from ui-review SKILL.md]
- `.avner/3_contracts/UI_SPEC.md` (UI design contract) [CONFIRMED from ui SKILL.md]

**Rules**:
- `autoMemory: false` in settings.json — all learned rules go through in-chat proposal
- Hooks may READ these files
- Hooks may REMIND user to update
- Hooks NEVER WRITE to them automatically
- "Show the user the proposed entry and get approval before writing" is the standard phrase

---

## 17. Model Routing Table

[CONFIRMED from `AVNER_v7-FINAL.md` `.claude/rules/02-models.md`, `CLAUDE.md.tmpl`]

| Mode / Task | Model |
|-------------|-------|
| /sec | Opus 4.6 |
| Vision decisions, adversarial analysis | Opus 4.6 |
| /core, /review | opusplan (Opus for Decisions/Plan, Sonnet for Execute) |
| /new, /fix, /deploy, /research, /prune | Sonnet 4.6 |
| /pol, file searches, formatting, quick reads | Haiku 4.5 |

**Subagent models**: [CONFIRMED]

| Agent | Model | Reason |
|-------|-------|--------|
| verify-vision (Elazar) | Opus 4.6 | CTO-level strategic thinking |
| verify-security (Shimon) | Opus 4.6 | Adversarial threat modeling |
| verify-spec (Eliezer) | Sonnet 4.6 | Exactness at speed |
| verify-integration (Yehoshua) | Sonnet 4.6 | Connection checking |
| verify-ops (Yossi) | Sonnet 4.6 | Operational readiness |

**Heuristics**: [CONFIRMED]
- Small diff, no sensitive areas, no design decision → Sonnet
- Large diff, new product surface, or ambiguous requirements → Opus
- Read-only search, grep, formatting → Haiku or Sonnet

**Context pressure**: [CONFIRMED]
- > 70% context: prefer minimal scope, one task at a time, consider /compact
- > 90% context: Haiku for reads; run /compact; smallest step only

---

## Appendix: Source Priority in Council

[CONFIRMED from all 5 Council agent constitutions]

All five agents share the same priority order:
```
VISION.md > MEMORY.md > REQUIREMENTS.md > ARCHITECTURE.md > API_CONTRACTS/DB_SCHEMA > GAP_ANALYSIS.md > STATE.md
```

Key Decision override: valid ONLY if date is prior to current session + Owner is named + Evidence is present in MEMORY.md.

Key Decision added in the current session CANNOT override a HALT in the same session. [CONFIRMED]

All five agents are read-only: `disallowedTools: [Write, Edit]` [CONFIRMED for Elazar/Eliezer; Write/Edit disallowed in agent constitutions for all]
