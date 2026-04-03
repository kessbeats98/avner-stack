---
name: manager-dispatch
description: Task decomposition, risk assessment, and dispatch writing for AVNER Manager.
invocation: manual
model: sonnet
---

# /dispatch — Task Decomposition & Assignment

Used by AVNER Manager to decompose a goal into a dispatchable task and write DISPATCH.md.

---

## Step 0: Artifact Cleanup + Gate Check (G0-G7)

Before dispatching, clean up stale artifacts from prior tasks:

1. If DISPATCH.md has an active assignment but STATE.md shows that task as DONE/FAILED/not IN_PROGRESS → clear DISPATCH.md to `## No active assignment`
2. Delete stale files if they exist:
   ```bash
   rm -f .avner/4_operations/gate_pass.txt
   rm -f .avner/4_operations/last_vision_check.txt
   rm -f .avner/4_operations/.touched_files
   ```

Then enforce the Council Protocol gates in order (first match wins):

0. **G0 (Elon Gate)**: Can this be solved by removing something? → redirect to /prune
1. **G1 (Finish Before Start)**: STATE.md has IN_PROGRESS task? → refuse. Say: "Complete [TASK-XX] first."
   - Exceptions: P0 bugs, /deploy, /sec
2. **G2 (Ambiguity Guard)**: Vague intent? → ask one clarifying question
3. **G3 (Safety Interrupt)**: Unknown impact? → HALT
4. **G4 (Security Override)**: Sensitive areas? → set mode to /sec, escalate risk to HIGH
5. **G5 (Architect Trigger)**: DB/API/global state? → set mode to /core, escalate risk to HIGH
6. **G6 (Efficiency Downgrade)**: Overkill? → prefer minimal change, downgrade risk
7. **G7 (Execute)**: All gates pass → proceed to dispatch

---

## Step 1: Assess Risk Tier

Classify by highest-risk file likely touched:

| Tier | Triggers | Council Required |
|------|----------|-----------------|
| **HIGH** | auth, payments, secrets, DB schema, public API, global state, deploy configs, CORS, RBAC | verify-spec + verify-security + verify-ops + human approval |
| **MEDIUM** | business logic, data transforms, UI state, service integrations | verify-spec + verify-security + verify-ops |
| **LOW** | docs, tests-only, comments, formatting, config labels | verify-spec only |

---

## Step 2: Determine Required Council

Based on risk tier AND files touched:

- `verify-spec`: ALWAYS (all risk tiers)
- `verify-security`: if touching auth, billing, PII, secrets, env vars, or risk ≥ MEDIUM
- `verify-ops`: if /deploy mode, or touching env vars, migrations, infra, or risk ≥ MEDIUM

---

## Step 3: Run Vision Gate (for /new and /core)

Invoke `verify-vision` agent before dispatch:

- **APPROVE** → proceed, write `Vision-evidence: APPROVE <timestamp>` in DISPATCH.md
- **HALT** → stop, present blocker to human, do NOT dispatch
- **SOLVE-BY-REMOVAL** → redirect to /prune mode
- **NEEDS-CLARIFICATION** → ask the clarifying question, wait for answer, re-run

For /fix mode: skip vision gate, write `Vision-evidence: FIX-BYPASS <timestamp>`

---

## Step 4: Decompose Task

Break into atomic subtasks:
- **/new, /core**: max 7 subtasks, each touching ≤ 5 files
- **/fix**: max 3 subtasks, each touching ≤ 3 files
- Each subtask has a verify command (how to confirm it worked)
- Each subtask is independently committable

---

## Step 5: Write DISPATCH.md

Overwrite `.avner/4_operations/DISPATCH.md` with:

```markdown
# DISPATCH — Active Work Order

## Current Assignment
Task: [TASK-ID] — [Title]
Assignee: claude-executor
Status: IN_PROGRESS
Risk: [HIGH / MEDIUM / LOW]
Reason: [why this risk tier — which sensitive areas touched]
Branch: [feat/task-XX-slug or fix/task-XX-slug]
Mode: [/new, /fix, /core, /pol, /sec, /ui, /ui-review]
Dispatched: [ISO 8601 timestamp]
Budget-cap: [$XX.00]
Vision-evidence: [APPROVE <timestamp> | FIX-BYPASS <timestamp>]

### Spec
[Concrete requirements — what must be built/changed]
- R-ids: [from REQUIREMENTS.md]

### Subtasks
1. [Title] — Files: [paths] — Verify: [command]
2. [Title] — Files: [paths] — Verify: [command]
...

### Required Council
- verify-spec: [REQUIRED | NOT_REQUIRED]
- verify-security: [REQUIRED | NOT_REQUIRED]
- verify-ops: [REQUIRED | NOT_REQUIRED]
- Human approval: [REQUIRED | NOT_REQUIRED]

### Acceptance Criteria
- [ ] [criterion 1]
- [ ] [criterion 2]
...
```

---

## Step 6: Update STATE.md

Mark the task as IN_PROGRESS in STATE.md (with human approval if DNA Safety requires it).

---

## Step 7: Spawn Executor

Invoke claude-executor via Agent tool with worktree isolation:

```
Agent(
  name: "claude-executor",
  isolation: "worktree",
  prompt: "[Full DISPATCH.md contents]\n\nExecute this task per the executor-run protocol."
)
```

## Budget Estimation

Before dispatch, estimate cost:
- LOW task: ~$0.50-2.00 (Executor only)
- MEDIUM task: ~$2.00-8.00 (Executor + Council)
- HIGH task: ~$8.00-25.00 (Executor + Council + Codex review)
- Each Council agent invocation: ~$1.00-5.00

If Paperclip is connected, check remaining budget. If estimated cost > remaining → do not dispatch → notify human.
