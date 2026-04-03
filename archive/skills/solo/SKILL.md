---
name: solo
description: Single-session pipeline combining /dispatch + /execute + /review-gate inline. No Agent spawning for execution. Council agents still invoked via Agent().
invocation: manual
model: sonnet
---

# /solo — Single-Session Autonomous Pipeline

Collapses the 3-agent pipeline (Manager → Executor → Codex Reviewer) into one session.
Use when Paperclip is unavailable, or for faster iteration on LOW/MEDIUM tasks.

Produces the same artifact trail as multi-agent mode: DISPATCH.md, EVIDENCE.md, REVIEW.md, COUNCIL_LOG.md.

---

## Step 0: Artifact Cleanup + Gate Check

Run `/dispatch` Step 0 inline:

1. Clean stale artifacts (gate_pass.txt, last_vision_check.txt, .touched_files)
2. Clear stale DISPATCH.md if prior task is DONE/FAILED
3. Enforce G0-G7 gates (see `/dispatch` Step 0 for full protocol)

---

## Step 1: Plan & Dispatch (inline /dispatch Steps 1-6)

Run the full `/dispatch` protocol inline — **except Step 7 (spawn Executor)**:

1. Assess risk tier
2. Determine required Council
3. Run vision gate (for /new and /core): invoke `verify-vision` via Agent()
4. Decompose task into subtasks
5. Write DISPATCH.md
6. Update STATE.md (IN_PROGRESS)

**Do NOT spawn a separate Executor.** Continue to Step 2 in the same session.

---

## Step 2: Implement (inline /execute Steps 0-5)

Run the full `/execute` protocol inline — in the current working tree (no worktree isolation):

1. Parse DISPATCH.md (already written in Step 1, so fields are known)
2. Read relevant .avner/ docs (TECHSTACK, ARCHITECTURE, contracts)
3. Create branch: `git checkout -b [branch-from-dispatch]`
4. For each subtask: code → verify → commit (same protocol as `/execute` Step 2)
5. Check acceptance criteria
6. Write EVIDENCE.md
7. Note your own verdict: Status (COMPLETE/PARTIAL/FAILED), Task, Commits, Files changed, Tests, Summary

**File-touch limits still apply.** Respect /new,/core ≤ 5 files; /fix ≤ 3 files.

---

## Step 3: Self-Review (replaces Codex review)

For MEDIUM and HIGH risk only. Skip for LOW.

Perform the codex-reviewer protocol inline (read `agents/codex-reviewer.md` for the full checklist):

1. Run `git diff main...[branch]`
2. Critical pass: injection, auth bypass, race conditions, secrets, data loss
3. Spec pass (MEDIUM+): acceptance criteria match, side effects, backward compat
4. Quality pass (HIGH): test coverage, error handling, perf, a11y
5. Write REVIEW.md in the same format as codex-reviewer output
6. Self-issue verdict: GO / NO-GO / NEEDS-REVISION

**If NEEDS-REVISION:** fix the findings yourself (you're in the same session), re-verify, update REVIEW.md. Max 1 self-revision cycle.

**If NO-GO (self-issued):** stop, present to human.

---

## Step 4: Council Gate (inline /review-gate Step 3)

Council agents are still invoked via Agent() — they are read-only and safe:

1. Invoke required Council agents per DISPATCH.md `### Required Council`
2. Parse and normalize verdicts per `docs/verdict-protocol.md`
3. Write COUNCIL_LOG.md entries
4. Aggregate: any BLOCK → stop; any HOLD → present to human; all PASS → proceed

---

## Step 5: Merge Decision (inline /review-gate Step 4)

- **LOW/MEDIUM** + all PASS → write gate_pass.txt, merge
- **HIGH** + all PASS → present to human for approval (no Paperclip in solo mode)
  - Approved → write gate_pass.txt, merge
  - Rejected → abandon branch, log

---

## Step 6: Post-Merge (inline /review-gate Step 5)

1. Update STATE.md: task → DONE
2. Lesson synthesis:
   - Extract from EVIDENCE.md surprises + REVIEW.md patterns + Council resolutions
   - LOW risk → auto-append LESSONS_AUTO.md
   - MEDIUM+ → present to human
3. Clear artifacts: DISPATCH.md, gate_pass.txt, last_vision_check.txt, .touched_files
4. Report: "Task [TASK-ID] merged and closed."

---

## Key Differences from Multi-Agent Mode

| Aspect | Multi-Agent | Solo |
|--------|------------|------|
| Execution | Worktree-isolated Executor agent | Current session, current worktree |
| Code review | Codex-reviewer agent (model: codex) | Self-review using codex-reviewer protocol |
| Paperclip | Heartbeats + approval requests | Skipped (human approval direct) |
| Council | Agent() calls | Same — Agent() calls |
| Artifacts | Identical | Identical |
| Isolation | Full (worktree) | None (current branch) |

## When to Use /solo

- Paperclip is unavailable or not configured
- LOW/MEDIUM risk tasks where worktree isolation overhead isn't needed
- Rapid iteration when context switching between Manager and Executor wastes tokens
- Human is actively pairing and can provide approvals inline
