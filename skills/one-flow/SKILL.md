---
name: one-flow
description: End-to-end feature delivery — plan, review, build, QA, ship.
invocation: manual
model: sonnet
---

# /one-flow — Full Feature Delivery

Orchestrates AVNER governance + structured plan review + UI contracts + QA + shipping
into a single end-to-end workflow. Each step is self-contained — read only the current step.

---

## Step 0: Gate Check

Before anything:
1. Read `.avner/4_operations/STATE.md` — check for IN PROGRESS tasks.
2. If IN PROGRESS exists → enforce G1: "⛔ Complete [TASK-XX] first." (Exception: P0 bugs)
3. Read `.avner/MEMORY.md` — load identity, non-goals, key decisions.
4. Read `.avner/1_vision/REQUIREMENTS.md` — have R-ids available.

---

## Step 1: Input & Framing

### 1a. Feature Description
Ask the user:
- What feature are you building? (one sentence)
- Which R-ids does it satisfy? (from REQUIREMENTS.md)

If the user is unsure, run a **mini-brief** (adapted from GStack office-hours):

**Six forcing questions:**
1. **Demand Reality**: What's the strongest evidence someone wants this?
2. **Status Quo**: What are users doing right now to solve this?
3. **Desperate Specificity**: Name the actual human who needs this most.
4. **Narrowest Wedge**: What's the smallest version someone would use — this week?
5. **Observation**: Have you watched someone try to do this without help?
6. **Future-Fit**: In 3 years, does this become more essential or less?

Push once on each answer. First answers are polished; real answers come after follow-up.

### 1b. Scope Check
- Does this map to at least one R-id? If not → HALT (scope creep).
- Does it conflict with non-goals in MEMORY.md? If yes → HALT.
- Could this be solved by removing something? If yes → suggest /prune first.

---

## Step 2: Plan (AVNER Decisions + Plan)

### 2a. Decisions Section
Document before touching code:
- **What**: one-sentence description of the change.
- **Why**: which R-ids this satisfies and why they can't be deferred.
- **How**: high-level approach (not implementation details).
- **Risk**: what could go wrong, what's the rollback.
- **Not doing**: explicitly list what's out of scope for this feature.

### 2b. Plan Section
Break into **max 7 atomic tasks**, each with:
- Task number and title
- Files likely touched
- Verify command (how to confirm this task worked)
- Estimated risk tier (High / Medium / Low)

Format:
```
Task 1: [Title]
  Files: [paths]
  Verify: [command]
  Risk: Low

Task 2: [Title]
  ...
```

One change = one commit. Each task is independently verifiable.

---

## Step 3: Plan Review

Run three review passes. For each, take a position and present recommendations.
Only ask the user when there's a genuine judgment call.

### 3a. CEO Review (scope & ambition)

Pick a mode based on context:
- **Greenfield** → SCOPE EXPANSION (what's 10x more ambitious for 2x effort?)
- **Enhancement** → SELECTIVE EXPANSION (hold scope + cherry-pick expansions)
- **Bug fix / hotfix** → HOLD SCOPE (maximum rigor, minimum change)
- **Overbuilt** → SCOPE REDUCTION (strip to essentials)

Check:
- Premise challenge: Is this the right problem? What if we did nothing?
- Existing code leverage: What already exists that we can reuse?
- Temporal check: What must be decided NOW vs. can wait?

### 3b. Design Review (UX/UI — skip if no UI)

Rate these 7 dimensions 0-10. For each below 8, explain what would make it a 10:

1. **Information Architecture** — What does the user see first/second/third?
2. **Interaction State Coverage** — Loading, empty, error, success, partial defined?
3. **Edge Cases** — Long names, zero results, network fails, colorblind, RTL?
4. **User Journey** — Emotional arc? Where does it break?
5. **AI Slop Risk** — Generic card grids? Hero sections? Looks like every AI site?
6. **Empty States** — "No items found" or actual design with warmth + CTA?
7. **Responsive & Accessibility** — Per viewport? Keyboard nav, contrast, touch targets?

Fix the plan to address any dimension below 7.

### 3c. Eng Review (architecture & tests)

Check:
- **Complexity smell**: >8 files or 2+ new classes = challenge it.
- **Existing code**: for each pattern, does the framework have a built-in?
- **Architecture**: system design, dependency graph, data flow, failure scenarios.
- **Test coverage**: trace every codepath → check against tests → flag gaps.

For each gap, note the quality level needed:
- ★★★ = Tests behavior with edge cases AND error paths
- ★★ = Tests correct behavior, happy path only
- ★ = Smoke test / existence check

Present findings as: **AUTO-FIX** (mechanical, do it) or **ASK** (needs user judgment).

---

## Step 4: UI Contract (conditional)

**Skip this step if no UI files are in the plan.**

Detect: do any planned tasks touch UI? (Check file paths for components, pages, layouts, styles.)

If yes:
1. Read `.avner/3_contracts/UI_SPEC.md` — check if in-scope screens are defined.
2. If screens are missing from spec → run the `/ui` workflow:
   - Add sections for affected screens to UI_SPEC.md.
   - Define all 5 states, copy, layout, components per screen.
   - Validate against 6 pillars.
3. If screens exist in spec → confirm spec is current.
4. Get user approval before proceeding to implementation.

---

## Step 5: Execute

### 5a. Vision Evidence
Before first commit, establish evidence:
- If this is /new or /core: invoke verify-vision agent.
  - If APPROVE: `echo "APPROVE $(date +%s)" > .avner/4_operations/last_vision_check.txt`
  - If HALT: stop and resolve.
  - If SOLVE-BY-REMOVAL: redirect to /prune.
- If this is /fix: `echo "FIX-BYPASS $(date +%s)" > .avner/4_operations/last_vision_check.txt`

### 5b. Implement Each Task
For each task from the Plan (Step 2b):

1. **Implement** the change.
2. **Run verify command** from the plan.
3. **Run lint/typecheck** if available.
4. **Stage and commit** using AVNER commit format:
   ```
   feat(scope): description

   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
5. If verify fails → debug (max 3 attempts with evidence):
   - Attempt 1: collect error, form hypothesis, fix.
   - Attempt 2: different approach, collect evidence.
   - Attempt 3: escalate to user with all evidence collected.

### 5c. Spec Check (after implementation)
If changes touched DB schema, API signatures, or global state:
- Invoke verify-spec agent.
- If ESCALATE-TO-CORE → pause and inform user.
- If FAIL → fix the spec violation before continuing.

---

## Step 6: UI Review (conditional)

**Skip if Step 4 was skipped (no UI work).**

After implementation, audit the UI:

1. Score 6 pillars (1–4 each):
   - Copywriting, Visuals, Color, Typography, Spacing, Experience Design
2. For each pillar below 3, identify specific fixes.
3. Present **Top 3 Priority Fixes** to the user.
4. If user approves fixes → implement as additional atomic commits.
5. Append review entry to `.avner/4_operations/UI_REVIEW.md` (with user approval).

---

## Step 7: Review & Ship

### 7a. Verification Artifact
Produce the mandatory block:
```
Commands run:    [exact commands executed during this flow]
Expected result: [what passing looks like for each task]
Observed result: [what actually happened]
Remaining risk:  [known gaps + why accepted]
```

### 7b. Pre-Ship Review
Review the full diff (all commits from this flow):

**Critical pass:**
- SQL & data safety
- Race conditions & concurrency
- Auth/trust boundary violations
- Enum & value completeness

**Informational pass:**
- Conditional side effects
- Magic numbers & string coupling
- Dead code & consistency
- Test gaps

### 7c. Deploy Gates (if shipping)
If the user wants to deploy:
1. Invoke verify-ops (Yossi) → GO / NO-GO / CONDITIONAL-GO
2. Invoke verify-security (Shimon) → GO / NO-GO / NEEDS-MITIGATION
3. Both must pass. Shimon has veto.
4. If CONDITIONAL-GO → get explicit human sign-off.

### 7d. Update Project State
With user approval (DNA Safety Rule):
- Update `STATE.md`: mark tasks as ✅ DONE, update session continuity.
- Update relevant `LESSONS_*.md` if insights were gained.
- Update `RUNBOOK.md` if deploy procedures changed.

### 7e. Handoff
Produce the handoff block:
1. What changed: files, features, commits.
2. What did NOT change: deferred items.
3. Validation results: commands + outcomes.
4. Remaining risks: bugs, untested paths.
5. Next recommended action: exact first step for next session.
