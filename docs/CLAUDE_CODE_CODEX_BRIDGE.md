# CLAUDE_CODE_CODEX_BRIDGE.md — AVNER v8 Reference Document
# Phase D: Claude Code + Codex Integration for Multi-Skill AVNER v8 Projects

> **Sources**: `avner-stack/vendor/gstack/codex/SKILL.md`, `avner-stack/vendor/gstack/CLAUDE.md`,
> `avner-stack/docs/AVNER_v7-FINAL.md`, `avner-stack/docs/OVERVIEW.md`,
> `avner-stack/templates/project/CLAUDE.md.tmpl`, `avner-stack/templates/project/.claude/settings.json.tmpl`,
> `avner-stack/agents/` (all 5), `avner-stack/skills/` (avner, one-flow)
>
> **Annotation key**: [CONFIRMED] = directly read in source files · [INFERRED] = reasoned from multiple sources · [MISSING] = not found, proposed for v8

---

## Table of Contents

1. [System Architecture — Four Layers](#1-system-architecture)
2. [CLAUDE.md Template — Multi-Skill AVNER v8 Project](#2-claudemd-template)
3. [Load Order and Priorities](#3-load-order-and-priorities)
4. [When to Call Codex vs GStack vs AVNER](#4-when-to-call-codex-vs-gstack-vs-avner)
5. [Hooks and Safety Rules](#5-hooks-and-safety-rules)
6. [How Codex Handles THINK/PLAN/REVIEW](#6-how-codex-handles-thinkplanreview)
7. [How Claude Code Handles BUILD/VERIFY/SHIP](#7-how-claude-code-handles-buildverifyship)
8. [GStack Plan Review Workflow](#8-gstack-plan-review-workflow)
9. [Cross-Model Analysis Protocol](#9-cross-model-analysis-protocol)
10. [Skill Registry and Air-Gap Rule](#10-skill-registry-and-air-gap-rule)

---

## 1. System Architecture

[CONFIRMED from `OVERVIEW.md` and `vendor/gstack/CLAUDE.md`]

The AVNER v8 stack layers four complementary systems:

```
┌─────────────────────────────────────────────────────────────────┐
│  /one-flow  (unified skill)                                      │  ← User entry point
├─────────────────────────────────────────────────────────────────┤
│  AVNER v7 Governance                                             │  ← Gates, Council, DNA Safety
│  Gates: G0 Delete First → G1 Finish First → UI Gate →           │
│         G2 Contracts → Verify Gate                               │
│  Council: Elazar, Eliezer, Yehoshua, Yossi, Shimon              │
│  Lifecycle: Decisions → Plan → Execute → Verify                  │
├─────────────────────────────────────────────────────────────────┤
│  GStack-style Plan Review                                        │  ← CEO / Design / Eng passes
│  CEO: scope/ambition (4 modes)                                   │
│  Design: 7 UX dimensions 0-10                                    │
│  Eng: architecture + test coverage diagram                       │
│  Codex: independent /codex review + /codex challenge             │
├─────────────────────────────────────────────────────────────────┤
│  GSD-style UI Contracts                                          │  ← 6-pillar spec + audit
│  /ui: create UI_SPEC.md before building                          │
│  /ui-review: audit + score after building                        │
│  Pillars: Copywriting, Visuals, Color, Typography,               │
│           Spacing, Experience Design                              │
├─────────────────────────────────────────────────────────────────┤
│  ECC-inspired Hooks & Tooling                                    │  ← Session, commit, lint
│  SessionStart: restore STATE + MEMORY                            │
│  PreCompact: backup STATE.md                                     │
│  PreToolUse: commit evidence lock (lint + typecheck + vision)    │
│  PostToolUse: auto-lint after file edits                         │
│  SessionEnd: remind to update STATE.md                           │
└─────────────────────────────────────────────────────────────────┘
```

### Role Division

| System | Owner | What It Does | Claude Code Handles |
|--------|-------|-------------|---------------------|
| AVNER v7 | Claude Code (main session) | Governance, gates, lifecycle, DNA safety | All of it |
| GStack reviews | Claude Code (main) + Codex (subagent) | Plan review passes | Claude orchestrates; Codex provides second opinion |
| GSD UI | Claude Code (main session) | UI design contract + audit | All of it (single-agent) |
| ECC hooks | settings.json (system) | Session/commit automation | Configured in settings.json, runs automatically |

---

## 2. CLAUDE.md Template — Multi-Skill AVNER v8 Project

> Ready-to-use. Place at project root as `CLAUDE.md`. Combines AVNER v7 governance with GStack + Codex bridge.

```markdown
# AVNER v8.0 — One-Dev Software House
# Stack: AVNER v7 + GStack Plan Review + GSD UI + Codex Second Opinion

## Quick Start (5 minutes)
1. Fill in Identity below.
2. Write .avner/MEMORY.md — identity, non-goals, sensitive areas.
3. Write .avner/1_vision/VISION.md — target user, core problem, metrics.
4. Write .avner/1_vision/REQUIREMENTS.md — R-id table.
5. Start with /one-flow for full plan-to-ship workflow.

## Identity
- Project:  {{PROJECT_NAME}}
- Stack:    {{STACK}}
- Goal:     {{GOAL}}

## Worlds (A.B.I.A)
- Vision:    .avner/1_vision/        (WHY)
- Arch:      .avner/2_architecture/  (WHAT)
- Contracts: .avner/3_contracts/     (HOW)
- Ops:       .avner/4_operations/    (DO)

## The Council (AVNER Verification Agents)
- Elazar   (Vision Gate):        .claude/agents/verify-vision.md       100% of /new and /core
- Eliezer  (Spec Guardian):      .claude/agents/verify-spec.md         ~15% of tasks
- Yehoshua (Integration Check):  .claude/agents/verify-integration.md  invoked by Yossi
- Yossi    (SRE / Deploy):       .claude/agents/verify-ops.md          /deploy only
- Shimon   (CISO / Veto):        .claude/agents/verify-security.md     /deploy + sensitive

Most tasks trigger 0-1 Council members. All 5 firing = something big is happening.

## External Reviewers (GStack + Codex)
- Codex review: /codex review     — Independent diff review via OpenAI Codex CLI
- Codex challenge: /codex challenge — Adversarial mode (tries to break your code)
- Plan CEO review: /plan-ceo-review — GStack scope & ambition pass
- Plan Eng review: /plan-eng-review — GStack architecture & test coverage pass
- Plan Design review: /plan-design-review — GStack UX/UI pass

These are OPTIONAL. Use /one-flow to get CEO/Design/Eng review inline.
Use /codex after implementation for independent second opinion.

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
/save     → Save work-in-progress
/one-flow → End-to-end feature delivery (plan → review → build → QA → ship)
/ui       → Create or update UI design contract (UI_SPEC.md)
/ui-review → Retroactive 6-pillar UI audit (UI_REVIEW.md)

## GStack Modes (optional — plan review layer)
/plan-ceo-review    → Scope & ambition pass on a plan
/plan-eng-review    → Architecture, complexity, test coverage pass
/plan-design-review → UX/UI gaps pass (7 dimensions, 0-10 each)
/codex review       → Independent Codex CLI diff review (pass/fail gate)
/codex challenge    → Adversarial Codex review
/codex <question>   → Ask Codex anything with session continuity

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
- opusplan     → /core, /review
- Sonnet 4.6   → /new, /fix, /deploy, /research, /prune, /ui, /ui-review, Eliezer, Yehoshua, Yossi
- Haiku 4.5    → /pol, quick reads, searches, formatting

Codex uses its own model (default OpenAI frontier model — no override needed).

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

## GStack Integration Notes
- Codex requires: npm install -g @openai/codex (or see https://github.com/openai/codex)
- Codex reviews run with model_reasoning_effort="xhigh" for maximum signal
- Cross-model comparison: after Codex review, Claude flags agreement/disagreement
- GSTACK REVIEW REPORT section is auto-maintained in plan files

> One rule to keep CLAUDE.md honest:
> "Would removing this line cause mistakes? If not — cut it."
```

---

## 3. Load Order and Priorities

[CONFIRMED from `OVERVIEW.md`, `AVNER_v7-FINAL.md`, `settings.json.tmpl`; INFERRED for GStack ordering]

### At Session Start

```
1. settings.json SessionStart hook fires automatically:
   a. cat .avner/4_operations/STATE.md .avner/MEMORY.md
   b. Warn if STATE.md > 7 days old
   c. (If post-compact): restore MEMORY.md head, remind about API_CONTRACTS + DB_SCHEMA

2. CLAUDE.md is in Claude Code's system context (always present)
   - Identity, Worlds, Modes, Protocol, Rules

3. Session continues with full context of:
   - STATE.md (session continuity)
   - MEMORY.md (non-goals, key decisions)
   - CLAUDE.md (constitution)
```

### Skill Load Order (when running a mode)

```
1. CLAUDE.md (always in context — no explicit load needed)
2. .claude/rules/01-protocol.md (referenced in CLAUDE.md)
3. .claude/rules/02-models.md (referenced in CLAUDE.md)
4. Invoked skill SKILL.md (e.g., .claude/skills/new/SKILL.md)
5. Council agents (only when triggered by gates — read as subagents)
6. GStack skills (only when explicitly invoked: /codex, /plan-eng-review, etc.)
```

### Priority Hierarchy (when conflicts arise)

[CONFIRMED for AVNER priorities; INFERRED for GStack/Codex relative priority]

```
1. AVNER DNA Safety Rule          — highest, blocks any auto-modification
2. AVNER Gates (G0-G7)           — checked before any mode executes
3. AVNER Council verdicts        — HALT/FAIL/NO-GO stop execution
4. GStack Codex gate (P1 finding) — FAIL verdict blocks shipping
5. GStack plan review            — recommendations, not hard stops
6. /one-flow lifecycle           — orchestrated flow
7. Individual mode SKILL.md      — specific mode behavior
```

### Context Priority for Council Decisions

[CONFIRMED from all 5 Council agent constitutions]

```
VISION.md > MEMORY.md > REQUIREMENTS.md > ARCHITECTURE.md
> API_CONTRACTS/DB_SCHEMA > GAP_ANALYSIS.md > STATE.md
```

---

## 4. When to Call Codex vs GStack vs AVNER

[CONFIRMED for AVNER triggers; CONFIRMED for Codex triggers from `vendor/gstack/codex/SKILL.md`; INFERRED for GStack triggers from `vendor/gstack/CLAUDE.md`]

### Decision Tree

```
User wants to do something
│
├─ Is this a governance action? (gate check, task selection, session start)
│   └─→ AVNER (/avner, /one-flow Step 0)
│
├─ Is this a product decision? (new feature, bugfix, architecture change)
│   └─→ AVNER mode (/new, /fix, /core)
│        └─ After plan is drafted:
│             └─→ GStack plan review (CEO/Design/Eng) — optional, via /one-flow Step 3
│
├─ Is this UI work?
│   └─→ Before coding: /ui (AVNER skill)
│   └─→ After coding: /ui-review (AVNER skill)
│
├─ Is there a diff ready for review?
│   └─→ /codex review — independent second opinion from Codex CLI
│   └─→ /review — AVNER internal sweep
│
├─ Is there a security concern?
│   └─→ AVNER: /sec or verify-security (Shimon)
│   └─→ /codex challenge — adversarial Codex review for edge cases
│
├─ Shipping to production?
│   └─→ AVNER: /deploy → verify-ops (Yossi) → verify-security (Shimon)
│   └─→ Optionally: /codex review before committing
│
└─ Exploratory / open question about codebase?
    └─→ /codex <question> — consult mode with session continuity
```

### Codex vs AVNER Council — When to Use Which

| Situation | Use AVNER Council | Use Codex | Notes |
|-----------|------------------|-----------|-------|
| Does this feature belong in V1? | Elazar (verify-vision) | — | AVNER has product context |
| Does this change break API contracts? | Eliezer (verify-spec) | — | AVNER has DB_SCHEMA/API_CONTRACTS |
| Is this safe to deploy? | Yossi + Shimon | /codex review | Run both — they complement each other |
| Security audit | Shimon (verify-security) | /codex challenge | Shimon has veto; Codex finds edge cases |
| Code quality review | — | /codex review | Codex is model-independent second opinion |
| Adversarial testing | — | /codex challenge | "200 IQ autistic developer" mode |
| Ask a technical question | — | /codex <question> | Codex consult mode with session continuity |

### GStack Reviews — When to Use

[INFERRED from `vendor/gstack/CLAUDE.md` project structure + `one-flow/SKILL.md` Step 3]

| Review | When | What It Does |
|--------|------|-------------|
| CEO Review (/plan-ceo-review) | After drafting plan, before coding | Challenges scope, premise, existing code leverage |
| Design Review (/plan-design-review) | After plan has UI tasks | Rates 7 UX dimensions 0-10, forces fixes below 7 |
| Eng Review (/plan-eng-review) | After plan is finalized | Architecture, complexity smell (>8 files), test coverage gaps |
| Codex Review (/codex review) | After coding, before shipping | Pass/fail gate (P1 findings = FAIL) |

**Inline via /one-flow**: CEO + Design + Eng reviews run in Step 3 of `/one-flow`. [CONFIRMED]
**Manual GStack invocation**: Use `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review` as standalone skills. [INFERRED]

---

## 5. Hooks and Safety Rules

[CONFIRMED from `templates/project/.claude/settings.json.tmpl`, `AVNER_v7-FINAL.md`]

### Hook Map

| Hook | Trigger | What It Does | AVNER Purpose |
|------|---------|-------------|---------------|
| SessionStart (empty matcher) | Every session start | Load STATE.md + MEMORY.md | Context restore |
| SessionStart (compact matcher) | After context compaction | Restore MEMORY.md head, remind about contracts | Compaction guard |
| SessionEnd | Session end | Remind to update STATE.md | Session hygiene |
| PreCompact | Before context compaction | Backup STATE.md to STATE.md.bak | Data safety |
| PreToolUse (Bash, git commit) | Every `git commit` attempt | Run lint + typecheck; check last_vision_check.txt | Commit evidence lock |
| PostToolUse (Edit/Write/MultiEdit) | After any file edit | Run `npm run lint` | Auto-lint |

### Critical Safety Rules

**1. Commit Evidence Lock**: [CONFIRMED]
- `git commit` is BLOCKED by PreToolUse hook unless `.avner/4_operations/last_vision_check.txt` contains `APPROVE <timestamp>` or `FIX-BYPASS <timestamp>`
- Fail-closed: missing file = BLOCKED

**2. DNA Safety Rule**: [CONFIRMED]
- CLAUDE.md, MEMORY.md, STATE.md, LESSONS_*.md, UI_SPEC.md, UI_REVIEW.md are never auto-written
- All modifications require: user approval + visible diff shown in-chat

**3. Compaction Guard**: [CONFIRMED]
- PreCompact hook backs up STATE.md before compaction
- Post-compaction SessionStart hook restores MEMORY.md (first 150 lines) and reminds about contracts

**4. Permission Deny List**: [CONFIRMED]
These commands are permanently denied:
```
.env           — never read secrets
rm -rf         — no recursive deletion
rm -r          — no recursive deletion
sudo           — no privilege escalation
curl * | bash  — no remote code execution
git push *     — no unauthorized pushes
git reset --hard * — no hard resets
git checkout -- * — no file overwrites
```

**5. Air-Gap Rule**: [CONFIRMED]
```
"External community skills are STRICTLY PROHIBITED (supply-chain risk).
No npx skills add url --skill find-skills or similar commands.
Only local ./skills/ and official avner-stack skills permitted."
```

**6. Codex Safety**: [CONFIRMED from `vendor/gstack/codex/SKILL.md`]
- Codex runs in `read-only` sandbox (`-s read-only`) — no writes to project
- 5-minute timeout on all Codex invocations
- Codex session IDs saved to `.context/codex-session-id` for continuity
- Review results logged to `~/.gstack/analytics/` (user config, not project)

**7. Sensitive Area Escalation**: [CONFIRMED]
High-risk files (auth, payments, secrets, DB schema, public API, deploy configs):
- Council is mandatory
- verify-security runs
- /sec mode before finalizing

---

## 6. How Codex Handles THINK/PLAN/REVIEW

[CONFIRMED from `vendor/gstack/codex/SKILL.md`]

### Codex Think → Plan → Review Pipeline

Codex operates in three modes, each mapping to a phase of development:

```
THINK phase  →  /codex <question>      (Consult mode — pre-plan investigation)
PLAN phase   →  /codex review [plan]   (Plan review — challenge assumptions)
REVIEW phase →  /codex review          (Diff review — pass/fail gate on code)
```

### THINK: Consult Mode

**Trigger**: `/codex <anything>` with no diff, or `/codex` when no diff exists [CONFIRMED]

**What Codex does**:
1. Reads plan files scoped to the current project (by project directory name)
2. Adopts persona: "Brutally honest technical reviewer"
3. Reviews for: logical gaps, unstated assumptions, missing error handling, overcomplexity, feasibility risks, missing dependencies
4. Streams reasoning traces via JSONL (`[codex thinking]` lines)
5. Saves session ID to `.context/codex-session-id` for follow-up continuity

**How Claude handles Codex output**:
- Present full output verbatim — do not summarize
- Flag disagreements: "Note: Claude Code disagrees on X because Y." [CONFIRMED]
- Cross-model comparison with Claude's own analysis if `/review` ran earlier

### PLAN: Plan File Review

**Trigger**: Plan file exists + user asks Codex to review [CONFIRMED]

**What Codex does**:
- Prepends adversarial persona: "Review for logical gaps, unstated assumptions, missing error handling, overcomplexity, feasibility risks, missing dependencies"
- Reads and critiques the plan file
- Reports in GSTACK REVIEW REPORT section in the plan file

**Plan file GSTACK REVIEW REPORT format**: [CONFIRMED]
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

### REVIEW: Diff Gate

**Trigger**: `/codex review` with diff present [CONFIRMED]

**What Codex does**:
1. Runs: `codex review --base <base> -c 'model_reasoning_effort="xhigh"' --enable web_search_cached`
2. Parses output for `[P1]` markers (critical) and `[P2]` markers (medium)
3. Determines gate verdict:
   - Contains `[P1]` → **FAIL** (blocks shipping)
   - No `[P1]` (only `[P2]` or none) → **PASS**

**Output format**: [CONFIRMED]
```
CODEX SAYS (code review):
════════════════════════════════════════════════════════════
[full codex output, verbatim — do not truncate or summarize]
════════════════════════════════════════════════════════════
GATE: PASS | FAIL (N critical findings)    Tokens: N | Est. cost: ~$X.XX
```

**After Codex review**: [CONFIRMED]
- Log result: `gstack-review-log '{...}'`
- Update GSTACK REVIEW REPORT in plan file
- Cross-model comparison if Claude's `/review` already ran

### CHALLENGE: Adversarial Mode

**Trigger**: `/codex challenge` [CONFIRMED]

**What Codex does**:
- Adversarial persona: "Find ways this code will fail in production. Think like an attacker and chaos engineer."
- Looks for: edge cases, race conditions, security holes, resource leaks, failure modes, silent data corruption
- Uses `codex exec` with JSONL output to capture reasoning traces
- Streams `[codex thinking]` traces — the reasoning before the answer

**Integration with AVNER /sec**:
- `/codex challenge` is complementary to Shimon (verify-security) [INFERRED]
- Shimon: checks against known AVNER sensitive areas + threat model
- Codex challenge: free-form adversarial — finds what AVNER's structured review might miss

---

## 7. How Claude Code Handles BUILD/VERIFY/SHIP

[CONFIRMED from `AVNER_v7-FINAL.md`, `skills/one-flow/SKILL.md`, `skills/new/SKILL.md`, `skills/fix/SKILL.md`]

### BUILD Phase (/new, /fix, /core)

**Step-by-step**:

```
1. G0 Gate: Can this be solved by deletion? If yes → /prune
2. G1 Gate: Is anything IN PROGRESS? If yes → REFUSE (unless P0/deploy/sec)
3. Elazar (verify-vision): Run unconditionally. Fail-closed (no verdict = HALT).
4. Write evidence: echo "APPROVE $(date +%s)" > .avner/4_operations/last_vision_check.txt
5. Plan: atomic tasks (max 7), each with verify command and risk tier
6. [If /one-flow]: Run GStack plan review (CEO/Design/Eng) on the plan
7. [If UI work]: Run /ui workflow → get UI_SPEC.md approved
8. For each task:
   a. Implement
   b. Run verify command
   c. Run lint + typecheck
   d. git diff --staged (verify no unintended changes)
   e. Commit: feat(scope): description + Co-Authored-By: Claude <noreply@anthropic.com>
9. If DB/API/global state touched: invoke Eliezer (verify-spec)
10. [If UI work]: Run /ui-review → score 6 pillars → get UI_REVIEW.md entry approved
```

**Commit discipline**: [CONFIRMED]
- One logical change = one commit
- Never mix feat + fix + refactor in one commit
- Commit after each atomic task, before starting next
- `/fix`: ONE fix = ONE commit

**ER-Ribosome debug loop (/fix)**: [CONFIRMED]
- Max 3 iterations on same root cause
- Each iteration MUST produce new evidence
- After 3 failures → HALT → escalate to /core

### VERIFY Phase

**Evidence requirements by mode**: [CONFIRMED]

| Mode | Verification Artifact | lint | typecheck | tests |
|------|----------------------|------|-----------|-------|
| /prune | Required | ✓ | ✓ | prove safe to remove |
| /fix | MUST have | ✓ | ✓ | reproduce + regression |
| /new | SHOULD have | ✓ | ✓ | task verify step |
| /core | SHOULD have | ✓ | ✓ (build) | all tests |
| /deploy | MUST have | ✓ | ✓ (build) | all tests |
| /pol | lint only | ✓ | — | — |
| /sec | SHOULD have | ✓ | ✓ | + verify-security |

**Verification Artifact format**: [CONFIRMED]
```
Commands run:    [exact commands executed]
Expected result: [what passing looks like]
Observed result: [what actually happened]
Remaining risk:  [known open gaps + why accepted]
```

**Pre-commit validation matrix** (stack-aware, run what exists): [CONFIRMED]
```bash
tsc --noEmit              # TypeScript type check
eslint .                  # Lint
npm test                  # Unit tests
npm run build             # Build check (for /deploy and /core)
npx prisma generate       # Schema sync (if Prisma in stack)
git diff --staged         # Review staged changes
```

### SHIP Phase (/deploy)

**Gates before shipping**: [CONFIRMED]

```
1. All tests pass
2. Build succeeds (clean)
3. verify-ops (Yossi): GO / NO-GO / CONDITIONAL-GO
   - Checks: env vars, build, migrations, monitoring, smoke tests, integration
   - Invokes Yehoshua (verify-integration) as a subagent
   - CONDITIONAL-GO requires explicit human sign-off
4. verify-security (Shimon): GO / NO-GO / NEEDS-MITIGATION
   - Checks: attack surfaces, auth boundaries, secrets in code, OWASP threats
   - Shimon has VETO authority. NO-GO = hard stop. No exceptions.
5. [Optionally]: /codex review — independent Codex diff review
```

**Handoff format** (after shipping): [CONFIRMED]
```
1. What changed:        [files modified, features added/fixed, commits made]
2. What did NOT change: [explicitly list deferred items]
3. Validation results:  [commands run + outcomes]
4. Remaining risks:     [known bugs, untested paths, open questions]
5. Next recommended action: [exact first step for next session]
```

---

## 8. GStack Plan Review Workflow

[CONFIRMED from `skills/one-flow/SKILL.md` Step 3; INFERRED from `vendor/gstack/CLAUDE.md` structure]

In `/one-flow` Step 3, three review passes run before implementation:

### CEO Review (Scope & Ambition)

Four modes based on context: [CONFIRMED]
- **Greenfield** → SCOPE EXPANSION: What's 10x more ambitious for 2x effort?
- **Enhancement** → SELECTIVE EXPANSION: Hold scope + cherry-pick expansions
- **Bug fix / hotfix** → HOLD SCOPE: Maximum rigor, minimum change
- **Overbuilt** → SCOPE REDUCTION: Strip to essentials

Checks: [CONFIRMED]
- Premise challenge: Is this the right problem? What if we did nothing?
- Existing code leverage: What already exists to reuse?
- Temporal check: What must be decided NOW vs. can wait?

### Design Review (7 UX Dimensions, 0-10)

[CONFIRMED from `skills/one-flow/SKILL.md` Step 3b]

Rate 0-10. For each below 8, explain what would make it a 10:

| # | Dimension | What It Checks |
|---|-----------|---------------|
| 1 | Information Architecture | What does user see first/second/third? |
| 2 | Interaction State Coverage | Loading, empty, error, success, partial defined? |
| 3 | Edge Cases | Long names, zero results, network fails, colorblind, RTL? |
| 4 | User Journey | Emotional arc? Where does it break? |
| 5 | AI Slop Risk | Generic card grids? Hero sections? Looks like every AI site? |
| 6 | Empty States | "No items found" or design with warmth + CTA? |
| 7 | Responsive & Accessibility | Per viewport? Keyboard nav, contrast, touch targets? |

**Rule**: Fix the plan to address any dimension below 7. [CONFIRMED]

### Eng Review (Architecture & Tests)

[CONFIRMED from `skills/one-flow/SKILL.md` Step 3c]

Checks:
- **Complexity smell**: >8 files or 2+ new classes = challenge it
- **Existing code**: Does the framework have a built-in for each pattern?
- **Architecture**: System design, dependency graph, data flow, failure scenarios
- **Test coverage**: Trace every codepath → check against tests → flag gaps

Test quality levels: [CONFIRMED]
- ★★★ = Tests behavior with edge cases AND error paths
- ★★ = Tests correct behavior, happy path only
- ★ = Smoke test / existence check

Findings format: [CONFIRMED]
- **AUTO-FIX** = mechanical change, do it
- **ASK** = needs user judgment

---

## 9. Cross-Model Analysis Protocol

[CONFIRMED from `vendor/gstack/codex/SKILL.md` Step 2A point 6]

When both Claude's `/review` and Codex's `/codex review` have run:

```
CROSS-MODEL ANALYSIS:
  Both found: [findings that overlap between Claude and Codex]
  Only Codex found: [findings unique to Codex]
  Only Claude found: [findings unique to Claude's /review]
  Agreement rate: X% (N/M total unique findings overlap)
```

**Significance**:
- Items found by BOTH: high-confidence issues, must fix
- Items found by Codex only: Claude may have missed; investigate
- Items found by Claude only: model-dependent; Codex may have different blindspot
- High disagreement rate (< 50%): suggests complex/ambiguous code — escalate to human review [INFERRED]

**Note**: Codex is the "200 IQ autistic developer" — direct, terse, technically precise. [CONFIRMED]
Present its output faithfully, not summarized. Never truncate Codex output. [CONFIRMED]

---

## 10. Skill Registry and Air-Gap Rule

[CONFIRMED from `templates/project/.avner/2_architecture/TECHSTACK.md.tmpl`, `AVNER_v7-FINAL.md`]

### Canonical TECHSTACK.md Skill Registry

```markdown
## Internal Skill Registry
| Skill | Source | Status |
|-------|--------|--------|
| /avner | avner-stack | installed |
| /one-flow | avner-stack | installed |
| /new | avner-stack | installed |
| /fix | avner-stack | installed |
| /pol | avner-stack | installed |
| /sec | avner-stack | installed |
| /deploy | avner-stack | installed |
| /core | avner-stack | installed |
| /research | avner-stack | installed |
| /review | avner-stack | installed |
| /save | avner-stack | installed |
| /prune | avner-stack | installed |
| /ui | avner-stack | installed |
| /ui-review | avner-stack | installed |
| /codex | gstack | installed |
| /plan-ceo-review | gstack | installed |
| /plan-eng-review | gstack | installed |
| /plan-design-review | gstack | installed |
```

### Air-Gap Rule

**Hard prohibition**: [CONFIRMED]
```
External community skills are STRICTLY PROHIBITED (supply-chain risk).
No npx skills add url --skill find-skills or similar commands.
No pulling skills from skills.sh, Vercel community, or third-party URLs.
```

**Permitted**:
- Local custom-built skills from `./skills/` (project-specific)
- Official `avner-stack` skills (pre-installed via `./setup`)
- Official `gstack` skills (pre-installed via GStack `./setup`)
- `skill-creator` (official Anthropic tool for creating new local skills) [CONFIRMED from AVNER_v7-FINAL.md]

**This table is the authoritative skill registry**: Update it when adding new skills. Any unlisted skill is unauthorized. [CONFIRMED]

### Codex Installation Requirement

[CONFIRMED from `vendor/gstack/codex/SKILL.md`]

Codex requires the OpenAI Codex CLI:
```bash
npm install -g @openai/codex
```

Check: `which codex` → if not found, stop and notify user.
Codex uses its own auth from `~/.codex/` config — no `OPENAI_API_KEY` env var needed.

---

## Appendix A: /one-flow Full Step Reference

[CONFIRMED from `skills/one-flow/SKILL.md`]

```
Step 0: Gate Check
  - Read STATE.md → G1 enforcement
  - Read MEMORY.md, REQUIREMENTS.md

Step 1: Input & Framing
  1a. Feature description + R-id mapping
  1b. Scope check (G0, G1, MEMORY non-goals)
  [If user unsure: Six Forcing Questions]

Step 2: Plan (AVNER Decisions + Plan)
  2a. Decisions section (What/Why/How/Risk/Not-doing)
  2b. Plan section (max 7 atomic tasks, risk tiers)

Step 3: Plan Review (GStack-style)
  3a. CEO Review (scope & ambition)
  3b. Design Review (7 UX dimensions, 0-10)
  3c. Eng Review (architecture & tests)

Step 4: UI Contract (conditional — skip if no UI)
  - Detect UI files in plan
  - Check UI_SPEC.md for in-scope screens
  - If missing: run /ui workflow
  - Get user approval before Step 5

Step 5: Execute
  5a. Vision evidence (verify-vision OR FIX-BYPASS)
  5b. Implement each task with verify + commit
  5c. Spec check (verify-spec if contracts touched)

Step 6: UI Review (conditional — skip if Step 4 skipped)
  - Score 6 pillars (1-4 each)
  - Present Top 3 fixes
  - Append to UI_REVIEW.md (with approval)

Step 7: Review & Ship
  7a. Verification Artifact
  7b. Pre-ship review (SQL safety, race conditions, auth, enum completeness)
  7c. Deploy gates (verify-ops + verify-security, if shipping)
  7d. Update STATE.md + LESSONS (with approval)
  7e. Handoff block
```

---

## Appendix B: Context Pressure Protocol

[CONFIRMED from `AVNER_v7-FINAL.md` `.claude/rules/02-models.md`]

| Context Level | Action |
|--------------|--------|
| > 70% | Prefer minimal scope, one task at a time, consider /compact |
| > 90% | Haiku for reads; run /compact; smallest possible step only |

PostCompaction recovery: [CONFIRMED]
```bash
# Runs automatically via SessionStart "compact" matcher hook:
echo '=== POST-COMPACTION CONTEXT RESTORE ===' \
  && head -n 150 .avner/MEMORY.md \
  && echo '=== Read API_CONTRACTS.md and DB_SCHEMA.md before any /core or /deploy work. ==='
```

PreCompact backup: [CONFIRMED]
```bash
# Runs automatically via PreCompact hook:
cp .avner/4_operations/STATE.md .avner/4_operations/STATE.md.bak 2>/dev/null || true
```
