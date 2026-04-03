# AGENTS.md — Active Agent Index

## Execution Agents (v10)

| Agent | File | Role | Model | maxTurns | Reads | Writes |
|-------|------|------|-------|----------|-------|--------|
| CEO CODEX | `agents/ceo-codex.md` | Product owner. Writes REQ, reviews PLAN, updates primer/hindsight. Owns Paperclip calls (approvals, budget, cost). | codex | 20 | CLAUDE.md, primer.md, obsidian/, .avner/, source (context) | REQ artifacts, primer.md, hindsight.md, backlog.md |
| Claude Code | `agents/claude-code.md` | Architect + builder. Plans, implements, commits. Heartbeats via hook. | sonnet | 50 | Everything CEO reads + git context, hindsight.md, TECHSTACK.md | PLAN, source code, EVIDENCE.md, git commits |
| Codex Review | `agents/codex-review.md` | Adversarial reviewer. Reads diff + EVIDENCE, writes REVIEW.md. Surgical fix on 3rd strike. | codex | 3 | Everything Claude Code reads + diff + EVIDENCE.md | REVIEW.md, one surgical fix (max 1 file, 20 lines) |

## Council Agents (HIGH risk / on-demand)

| Agent | File | Domain | Model | maxTurns | Tools |
|-------|------|--------|-------|----------|-------|
| verify-vision (Elazar) | `agents/verify-vision.md` | Vision alignment | opus | 12 | Read, Glob |
| verify-spec (Eliezer) | `agents/verify-spec.md` | DB/API/spec guard | sonnet | 18 | Read, Glob, Grep, Bash |
| verify-security (Shimon) | `agents/verify-security.md` | Threat model, veto on /deploy | opus | 20 | Read, Glob, Grep, Bash |
| verify-ops (Yossi) | `agents/verify-ops.md` | Ops readiness, pre-deploy | sonnet | 15 | Read, Glob, Grep, Bash |
| verify-integration (Yehoshua) | `agents/verify-integration.md` | Cross-system pipes | sonnet | 20 | Read, Glob, Grep, Bash |

All Council agents are **read-only** (disallow Write/Edit). They return verdicts only.

## Archived Agents (v9)

Moved to `archive/agents/`. Not wired into any active skill or workflow.

| Agent | Reason Archived |
|-------|----------------|
| avner-manager | Replaced by CEO CODEX + /one-flow inline orchestration |
| claude-executor | Replaced by claude-code (plans + executes in one agent) |
| codex-reviewer | Duplicate of codex-review; stateless variant no longer needed |

## Skills Index

Active skills installed by `setup`:

| Skill | Entry Point | Purpose |
|-------|------------|---------|
| /avner | `skills/avner/SKILL.md` | Governance overview + session management |
| /one-flow | `skills/one-flow/SKILL.md` | End-to-end delivery lifecycle (the primary workflow) |
| /ceo-codex | `skills/ceo-codex/SKILL.md` | Elon-style first-principles decision framework |
| /ui | `skills/ui/SKILL.md` | UI design contract creation (6-pillar) |
| /ui-review | `skills/ui-review/SKILL.md` | 6-pillar UI audit |

Archived: /manager-dispatch, /review-gate, /solo, /skill-creator (in `archive/skills/`).
