# ARCHITECTURE.md — avner-stack framework

## 3-Role Model (v10)

```
Human (you)
  │
  ▼
CEO CODEX (codex model)     ← decides WHAT and WHY
  │  writes REQ, reviews PLAN, updates primer/hindsight
  │  Paperclip: approvals, budget, cost events
  │
  ▼
CLAUDE CODE (sonnet model)  ← decides HOW
  │  writes PLAN, implements code, writes EVIDENCE.md
  │  Paperclip: heartbeats (via PostToolUse hook)
  │
  ▼
CODEX REVIEW (codex model)  ← adversarial quality gate
     reads diff + EVIDENCE, writes REVIEW.md
     surgical fix protocol on 3rd strike
     no Paperclip calls (read-only)
```

## Council (HIGH risk only)

5 verification agents invoked via Agent() during Step 7 of /one-flow:

| Agent | Domain | Veto Power |
|-------|--------|------------|
| verify-vision (Elazar) | Vision alignment | Can HALT |
| verify-spec (Eliezer) | DB/API/spec guard | Can ESCALATE-TO-CORE |
| verify-security (Shimon) | Threat model | Veto on /deploy |
| verify-ops (Yossi) | Env, build, monitoring | Can BLOCK |
| verify-integration (Yehoshua) | Cross-system pipes | Can BLOCK |

## Lifecycle (/one-flow)

```
Step 0: Load Context (primer.md, hindsight.md, git)
Step 1: Requirements (CEO CODEX writes REQ)
Step 2: Plan (Claude Code writes PLAN)
Step 3: Plan Review (CEO CODEX → GO/REVISE/CANCEL, max 3 rounds)
  3d: Paperclip approval gate (HIGH risk only)
Step 4: UI Contract (conditional)
Step 5: Execute (Claude Code implements, commits, writes EVIDENCE.md)
  5.pre-a: Paperclip budget check (soft)
  5.pre-b: Constraint alignment check
Step 6: Review (Codex Review → GO/NEEDS-REVISION/HARD-NO, max 2 fix rounds)
Step 7: Council Gate (HIGH risk, optional)
Step 8: Merge & Close + Post-Task (CEO CODEX updates primer/hindsight)
```

## File Coordination

All state lives in `.avner/` — no external DB. Git is the source of truth.
Agents communicate via artifacts: REQ, PLAN, DISPATCH.md, EVIDENCE.md, REVIEW.md.
Hooks enforce gates: commit-evidence lock, merge-gate lock, DNA safety.

## Paperclip (optional)

`.paperclip/config.yaml` + `lib/paperclip.sh` bash client.
`dry_run: true` by default — logs to stderr, no HTTP calls.
CEO CODEX owns all Paperclip calls except heartbeats (hook-driven).
