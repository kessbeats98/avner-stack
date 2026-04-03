---
name: review-gate
description: Post-Executor pipeline — Codex review, Council gates, merge decision, cleanup. Used by AVNER Manager after Executor returns.
invocation: manual
model: sonnet
---

# /review-gate — Post-Execution Review & Merge Pipeline

Used by AVNER Manager after claude-executor returns. Drives Codex review, Council gates, merge decision, lesson synthesis, and artifact cleanup.

---

## Step 0: Parse Executor Verdict

The Agent tool returns the Executor's final output. Parse these fields by line prefix:

| Field | Pattern | Required |
|-------|---------|----------|
| Status | `^Status:\s*(COMPLETE\|PARTIAL\|FAILED)` | YES |
| Task | `^Task:\s*(\S+)` | YES |
| Commits | `^Commits:\s*(.+)` | YES |
| Files changed | `^Files changed:\s*(\d+)` | NO |
| Tests | `^Tests:\s*(PASS\|FAIL\|SKIPPED)` | YES |
| Summary | `^Summary:\s*(.+)` | YES |

**If Status = FAILED:**
1. Read `.avner/4_operations/EVIDENCE.md` for failure details
2. Log to STATE.md: task status → FAILED, reason from Summary
3. Log to COUNCIL_LOG.md: `Verdict: EXECUTOR-FAILED`, `Action: HUMAN-REVIEW`
4. Present failure to human: "Executor failed on [TASK-ID]: [Summary]. See EVIDENCE.md. Options: retry, reassign, abandon."
5. **Stop.** Do not proceed to review or Council.

**If Status = PARTIAL:**
- Proceed but flag: "Executor completed partially. Unfinished subtasks may cause Council failures."

---

## Step 1: Read Context

1. Read `.avner/4_operations/DISPATCH.md` — extract risk tier, mode, required Council, branch name
2. Read `.avner/4_operations/EVIDENCE.md` — confirm Executor output exists
3. Determine branch: from DISPATCH.md `Branch:` field

---

## Step 2: Codex Review (MEDIUM and HIGH risk only)

Skip this step for LOW risk tasks.

### 2a. Collect diff

```bash
git diff main...[branch-name]
```

### 2b. Invoke Codex Reviewer

```
Agent(
  name: "codex-reviewer",
  prompt: "[Full DISPATCH.md contents]\n---\n[git diff output from 2a]"
)
```

If the agent fails (model unavailable), retry with model override:
```
Agent(
  name: "codex-reviewer",
  model: "sonnet",
  prompt: "[same prompt]"
)
```
Note the fallback in COUNCIL_LOG.md: `Evidence: review used fallback model (sonnet)`.

### 2c. Parse Review Verdict

Read `.avner/4_operations/REVIEW.md`. Parse verdict per `docs/verdict-protocol.md`:
- Scan for `^## Verdict\n(.+)$` or `^Verdict:\s*(.+)$`

**Verdict handling:**

| Review Verdict | Action |
|---------------|--------|
| GO | Proceed to Step 3 |
| NEEDS-REVISION | Go to Step 2d (retry) |
| NO-GO | Task BLOCKED — log, alert human, **stop** |

### 2d. Handle NEEDS-REVISION (max 1 retry)

1. Read REVIEW.md findings (Medium-severity items, unmet acceptance criteria)
2. Re-dispatch to Executor with feedback:
   ```
   Agent(
     name: "claude-executor",
     isolation: "worktree",
     prompt: "[Original DISPATCH.md]\n\n## Review Feedback\n[REVIEW.md findings]\n\nAddress the review findings. Write updated EVIDENCE.md."
   )
   ```
3. Parse Executor's return (same as Step 0)
4. Re-invoke Codex Reviewer (Step 2b) on the updated diff
5. If second review returns NEEDS-REVISION or NO-GO → task BLOCKED, escalate to human

---

## Step 3: Council Gate

Invoke required Council agents based on DISPATCH.md `### Required Council` section.

### 3a. Determine which agents to invoke

Read the Required Council section from DISPATCH.md:
- `verify-spec: REQUIRED` → invoke
- `verify-security: REQUIRED` → invoke
- `verify-ops: REQUIRED` → invoke
- `NOT_REQUIRED` → skip

### 3b. Invoke Council agents

For each required agent, invoke via Agent tool. All Council agents are read-only and can run in parallel if the Agent tool supports it.

**verify-spec:**
```
Agent(
  name: "verify-spec",
  prompt: "Verify spec compliance for [TASK-ID] on branch [branch]. Risk: [tier]. Mode: [mode]."
)
```

**verify-security:**
```
Agent(
  name: "verify-security",
  prompt: "Security review for [TASK-ID] on branch [branch]. Risk: [tier]. Sensitive areas: [from DISPATCH.md spec]."
)
```

**verify-ops:**
```
Agent(
  name: "verify-ops",
  prompt: "Ops readiness check for [TASK-ID] on branch [branch]. Risk: [tier]."
)
```

### 3c. Parse and normalize verdicts

For each agent's output, parse verdict per `docs/verdict-protocol.md`:

1. Extract raw verdict line
2. Normalize: APPROVE/PASS/GO → PASS; HALT/FAIL/NO-GO → BLOCK; all others → HOLD
3. Write COUNCIL_LOG.md entry per the schema in verdict-protocol.md

### 3d. Aggregate

- **Any BLOCK** → task BLOCKED
  1. Write block reason to STATE.md
  2. Send Paperclip approval request (or write to APPROVAL_PENDING.md if unreachable)
  3. Present to human: "[agent] issued [verdict] for [TASK-ID]: [evidence summary]"
  4. **Stop.** Do not merge.

- **Any HOLD** → task HELD
  1. Present hold reason to human
  2. Wait for human resolution
  3. If human resolves → re-run the specific Council agent that issued HOLD
  4. If human overrides → log override in COUNCIL_LOG.md with `Action: HUMAN-OVERRIDE`

- **All PASS** → proceed to Step 4

---

## Step 4: Merge Decision

Based on risk tier (from DISPATCH.md):

### LOW or MEDIUM (all Council PASS)

1. Write gate_pass.txt:
   ```
   GATE_PASS [TASK-ID] [ISO-8601-timestamp] [risk-tier] [comma-separated-agent-names]
   ```
2. Merge the feature branch:
   ```bash
   git merge [branch-name]
   ```
3. Proceed to Step 5

### HIGH (all Council PASS)

1. Send Paperclip approval request:
   ```bash
   curl -s -X POST "${PAPERCLIP_API_URL}/api/companies/${PAPERCLIP_COMPANY_ID}/approvals" \
     -H "Authorization: Bearer ${PAPERCLIP_API_KEY}" \
     -H "Content-Type: application/json" \
     -d '{"type":"high_risk_merge","payload":{"taskId":"[TASK-ID]","risk":"HIGH","council_status":"ALL_PASS"}}' \
     2>/dev/null || true
   ```
2. **Fallback** (Paperclip unreachable): write to `.avner/4_operations/APPROVAL_PENDING.md`:
   ```markdown
   ### [ISO-8601] — [TASK-ID] — high_risk_merge
   - Type: high_risk_merge
   - Risk: HIGH
   - Council: ALL_PASS ([agent names])
   - Action needed: Approve or reject merge of branch [branch] to main
   - Status: PENDING
   ---
   ```
3. Wait for human approval
   - **Approved** → write gate_pass.txt, merge, proceed to Step 5
   - **Rejected** → log rejection in COUNCIL_LOG.md, abandon branch, update STATE.md

---

## Step 5: Post-Merge

### 5a. Update STATE.md
- Mark task as DONE with commit hash reference
- Move from Active Work to Completed section

### 5b. Lesson Synthesis

Read EVIDENCE.md and REVIEW.md. Extract lessons:

1. From EVIDENCE.md `## Surprises / Delays`: non-trivial surprise = lesson candidate
2. From REVIEW.md `## Patterns Noticed` and `## Anti-Patterns Detected`: direct lesson material
3. From Council verdicts in this cycle: any HOLD that was resolved = lesson about what triggered it

Format each lesson:
```markdown
- [ISO-8601] [TASK-ID] — [1 sentence lesson]. Source: [EVIDENCE|REVIEW|COUNCIL].
```

- **LOW risk**: auto-append to `.avner/LESSONS_AUTO.md`
- **MEDIUM+ risk**: present lessons to human, append only with approval (DNA Safety Rule)

### 5c. Send Paperclip cost event

```bash
curl -s -X POST "${PAPERCLIP_API_URL}/api/agents/${PAPERCLIP_AGENT_ID}/cost-event" \
  -H "Authorization: Bearer ${PAPERCLIP_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"taskId":"[TASK-ID]","risk":"[tier]","estimated_cost":"[budget-cap from DISPATCH]"}' \
  2>/dev/null || true
```

### 5d. Artifact Cleanup

1. Clear DISPATCH.md: overwrite with `## No active assignment`
2. Delete gate_pass.txt: `rm -f .avner/4_operations/gate_pass.txt`
3. Delete last_vision_check.txt: `rm -f .avner/4_operations/last_vision_check.txt`
4. Delete .touched_files: `rm -f .avner/4_operations/.touched_files`

### 5e. Return to Main Loop

Signal to Manager: "Task [TASK-ID] merged and closed. Ready for next task."
Manager returns to Main Loop Step 1 (select next task from STATE.md backlog).
