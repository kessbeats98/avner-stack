# GStack Integration Hooks — AVNER

<!-- Source files: GSTACK_SKILL_REFERENCE.md, ARCHITECTURE.md, ETHOS.md, SKILL.md, SKILL.md.tmpl, CLAUDE.md -->
<!-- Generated: 2026-03-29 -->
<!-- Annotations: [CONFIRMED] = seen in source, [INFERRED] = reasoned from context, [MISSING] = not found in any source -->

---

## 1. Skill-to-Skill Data Flow

Maps the full standard workflow pipeline from initial brainstorm through post-ship retrospective. Each row documents what artifact the upstream skill produces, where it lives, and how the downstream skill reads it.

### 1.1 Full Pipeline Chain

```
/office-hours
     │
     ▼
/plan-ceo-review
     │
     ▼
/plan-eng-review
     │
     ▼
/plan-design-review
     │
     ▼
[Claude Code implementation]
     │
     ▼
/review ──── /codex review (optional parallel)
     │
     ▼
/qa
     │
     ▼
/ship
     │
     ▼
/land-and-deploy
     │
     ├──▶ /canary
     │
     ▼
/document-release
     │
     ▼
/retro
```

### 1.2 Transition Details

---

#### `/office-hours` → `/plan-ceo-review`

**What is produced:** A design document capturing product direction, target user, narrowest wedge, demand evidence, and premises. [CONFIRMED]

**Where it is stored:**
- `~/.gstack/projects/{slug}/{user}-{branch}-design-{datetime}.md` [CONFIRMED — from office-hours/SKILL.md write block]
- Design lineage: if a prior design doc exists on the same branch, the new doc gets a `Supersedes:` field referencing it. [CONFIRMED]

**What the receiving skill reads:**
```bash
DESIGN=$(ls -t ~/.gstack/projects/$SLUG/*-$BRANCH-design-*.md 2>/dev/null | head -1)
[ -z "$DESIGN" ] && DESIGN=$(ls -t ~/.gstack/projects/$SLUG/*-design-*.md 2>/dev/null | head -1)
```
`/plan-ceo-review` reads the most recent branch-scoped design doc, falling back to any design doc for the project. [CONFIRMED — from plan-ceo-review/SKILL.md]

**Also consumed by:** `/plan-eng-review` (same glob pattern), `/plan-design-review` [CONFIRMED], `/autoplan` [CONFIRMED], `/design-consultation` [CONFIRMED — checks `~/.gstack/projects/$SLUG/*office-hours*`]

---

#### `/plan-ceo-review` → `/plan-eng-review`

**What is produced:**
1. Plan file updated with a CEO review section (scope proposals: accepted/deferred). [CONFIRMED]
2. A CEO plan artifact: `~/.gstack/projects/{slug}/ceo-plans/{date}-{feature-slug}.md` (stale plans archived to `ceo-plans/archive/`). [CONFIRMED]
3. A "handoff note" for inter-skill context: `~/.gstack/projects/{slug}/{user}-{branch}-ceo-handoff-{datetime}.md` (removed by `/ship` after use). [CONFIRMED — plan-ceo-review/SKILL.md line 1229]
4. Review log entry via `gstack-review-log`: `{"skill":"plan-ceo-review","timestamp":"...","status":"...","unresolved":N,"critical_gaps":N,"mode":"MODE","scope_proposed":N,"scope_accepted":N,"scope_deferred":N,"commit":"COMMIT"}` [CONFIRMED]

**Where it is stored:**
- Plan file: in-place edit. [CONFIRMED]
- CEO plan: `~/.gstack/projects/{slug}/ceo-plans/{date}-{feature-slug}.md` [CONFIRMED]
- Handoff note: `~/.gstack/projects/{slug}/` [CONFIRMED]
- Review log: `~/.gstack/projects/{slug}/{branch}-reviews.jsonl` [CONFIRMED — gstack-review-log binary]

**What `/plan-eng-review` reads:**
- The plan file directly (passed as argument or discovered in `.claude/plans/*.md`). [CONFIRMED]
- Optional: the design doc (same glob as CEO review). [CONFIRMED]
- Review log (via `gstack-review-read`) to display existing review context. [CONFIRMED]

---

#### `/plan-eng-review` → `/plan-design-review`

**What is produced:**
1. Plan file updated with an engineering review section (architecture ratings, test plan, edge cases). [CONFIRMED]
2. Test plan artifact: `~/.gstack/projects/{slug}/{user}-{branch}-test-plan-{datetime}.md` [CONFIRMED — autoplan/SKILL.md line 746; inferred pattern consistent with other artifacts]
3. Review log entry: `{"skill":"plan-eng-review","timestamp":"...","status":"...","unresolved":N,"critical_gaps":N,"issues_found":N,"mode":"MODE","commit":"COMMIT"}` [CONFIRMED]

**Where it is stored:**
- Plan file: in-place edit. [CONFIRMED]
- Test plan: `~/.gstack/projects/{slug}/` [CONFIRMED]
- Review log: `~/.gstack/projects/{slug}/{branch}-reviews.jsonl` [CONFIRMED]

**What `/plan-design-review` reads:**
- The plan file (reads for UI/UX components, applies design ratings). [CONFIRMED]
- Review log (via `gstack-review-read`) for existing review context. [CONFIRMED]

---

#### `/plan-design-review` → `[implementation]`

**What is produced:**
1. Plan file updated with design review section (dimension ratings 0-10, design decisions made). [CONFIRMED]
2. Review log entry: `{"skill":"plan-design-review","timestamp":"...","status":"...","initial_score":N,"overall_score":N,"unresolved":N,"decisions_made":N,"commit":"COMMIT"}` [CONFIRMED]
3. Optional: `design-outside-voices` review log entry from Codex/subagent review. [CONFIRMED]

**Where it is stored:**
- Plan file: in-place edit. [CONFIRMED]
- Review log: `~/.gstack/projects/{slug}/{branch}-reviews.jsonl` [CONFIRMED]

**What implementation reads:**
- The plan file (Claude Code reads it directly). [CONFIRMED]
- DESIGN.md (if created by `/design-consultation` in an earlier step). [CONFIRMED]

**Shortcut — `/autoplan`:** Runs all three plan reviews (CEO → eng → design) sequentially with auto-decisions, writes all three review log entries, produces a unified plan. [CONFIRMED]

---

#### `[implementation]` → `/review`

**What is produced by implementation:**
- Git commits on a feature branch. [CONFIRMED]
- TODOS.md updates (tasks marked done). [INFERRED]
- SOURCE CODE ONLY — no structured artifact handed to `/review`.

**What `/review` reads:**
- `git diff <base>...HEAD` — the full diff. [CONFIRMED]
- `gh pr view --json body` — PR description. [CONFIRMED]
- `TODOS.md` (if present). [CONFIRMED]
- Plan file (discovered via conversation context or content-based search in `~/.claude/plans/*.md`). [CONFIRMED]
- Review log (via `gstack-review-read`) to cross-reference prior reviews. [CONFIRMED]

**What `/review` produces:**
- Review findings displayed in conversation. [CONFIRMED]
- Review log entry: `{"skill":"review","status":"...","commit":"..."}` written via `gstack-review-log`. [CONFIRMED — GSTACK_SKILL_REFERENCE.md section 5]
- Plan file updated with `## GSTACK REVIEW REPORT` section (if in plan mode). [CONFIRMED]

---

#### `/review` → `/qa`

**Artifact passed:** Review findings are in the review log (`{branch}-reviews.jsonl`). No direct file handoff. [CONFIRMED]

**What `/qa` reads:**
- Target URL (auto-detects from local ports 3000/4000/8080). [CONFIRMED]
- Project test plans: `~/.gstack/projects/{slug}/*-test-plan-*.md` (from `/plan-eng-review`). [CONFIRMED — qa/SKILL.md line 558]
- Branch diff (for diff-aware mode). [CONFIRMED]

**What `/qa` produces:**
- `.gstack/qa-reports/qa-report-{domain}-{YYYY-MM-DD}.md` [CONFIRMED]
- `.gstack/qa-reports/screenshots/*.png` [CONFIRMED]
- `.gstack/qa-reports/baseline.json` [CONFIRMED]
- `~/.gstack/projects/{slug}/{user}-{branch}-test-outcome-{datetime}.md` [CONFIRMED]
- Atomic fix commits in git. [CONFIRMED]

---

#### `/qa` → `/ship`

**Artifact passed:** QA reports in `.gstack/qa-reports/`, atomic fix commits in git. [CONFIRMED]

**What `/ship` reads:**
- Review log (via `gstack-review-read`) → displays Review Readiness Dashboard. [CONFIRMED]
- `git diff <base>...HEAD --stat` and `git log <base>..HEAD --oneline`. [CONFIRMED]
- QA report files (referenced in plan status). [INFERRED — /ship checks plan items]
- TODOS.md (for plan completion audit). [CONFIRMED]

**What `/ship` produces:**
- Git commits (one per logical change). [CONFIRMED]
- PR/MR created via `gh pr create` or `glab mr create`. [CONFIRMED]
- CHANGELOG entry added. [CONFIRMED]
- VERSION bumped. [CONFIRMED]
- TODOS.md updated (completed items marked). [CONFIRMED]
- Review log entry: `{"skill":"design-review-lite","timestamp":"...","status":"...","findings":N,"auto_fixed":M,"commit":"..."}` (from Step 3.5 design-review-lite). [CONFIRMED]
- Review log entry: `{"skill":"adversarial-review",...}` (if diff ≥ 50 lines). [CONFIRMED]

---

#### `/ship` → `/land-and-deploy`

**Artifact passed:** PR number and branch in the git remote. [CONFIRMED]

**What `/land-and-deploy` reads:**
- PR number (auto-detected via `gh pr view`). [CONFIRMED]
- Review log (via `gstack-review-read`) for readiness gate. [CONFIRMED]
- CI/CD status (polled via `gh run list` or `glab pipeline list`). [CONFIRMED]

**What `/land-and-deploy` produces:**
- Merged PR (via `gh pr merge`). [CONFIRMED]
- `.gstack/deploy-reports/{date}-pr{number}-deploy.md` [CONFIRMED]
- `.gstack/deploy-reports/post-deploy.png` (post-deploy screenshot). [CONFIRMED]
- JSONL entry in `~/.gstack/projects/{slug}/`: `{"skill":"land-and-deploy","timestamp":"...","status":"...","pr":N,"merge_sha":"...","deploy_status":"...","ci_wait_s":N,...}` [CONFIRMED]

---

#### `/land-and-deploy` → `/canary`

**What is passed:** Deployed production URL (known from deploy reports or PR). [CONFIRMED]

**What `/canary` reads:**
- Production URL (passed as argument). [CONFIRMED]
- `.gstack/qa-reports/baseline.json` (for comparison, if captured pre-deploy). [CONFIRMED]

**What `/canary` produces:**
- `.gstack/canary-reports/{date}-canary.md` [CONFIRMED]
- `.gstack/canary-reports/{date}-canary.json` [CONFIRMED]
- `.gstack/canary-reports/screenshots/` [CONFIRMED]
- JSONL entry in `~/.gstack/projects/{slug}/`: `{"skill":"canary","timestamp":"...","status":"HEALTHY/DEGRADED/BROKEN","url":"...","duration_min":N,"alerts":N}` [CONFIRMED]

---

#### `/canary` → `/document-release`

**What is passed:** No direct artifact. `/document-release` is triggered after merge, reads the diff. [CONFIRMED]

**What `/document-release` reads:**
- `git diff <base>..HEAD` against merged branch. [CONFIRMED]
- All `.md` files in the repo (README, ARCHITECTURE, CONTRIBUTING, CLAUDE.md, etc.). [CONFIRMED]
- CHANGELOG.md and VERSION (for voice polish and reference). [CONFIRMED]
- TODOS.md (for cleanup). [CONFIRMED]

**What `/document-release` produces:**
- Documentation files updated in-place. [CONFIRMED]
- Commit: `docs: update project documentation for vX.Y.Z.W`. [CONFIRMED]
- PR/MR body updated with `## Documentation` section. [CONFIRMED]

---

#### `/document-release` → `/retro`

**What is passed:** No direct artifact. `/retro` reads git history. [CONFIRMED]

**What `/retro` reads:**
- `git log --since=<window>` (commit history for the time window). [CONFIRMED]
- Prior retro snapshots: `.context/retros/*.json` (per-project, normal mode). [CONFIRMED]
- Prior retro snapshots: `~/.gstack/retros/global-*.json` (global mode). [CONFIRMED]

**What `/retro` produces:**
- Retro narrative output to conversation (not a file). [CONFIRMED]
- `.context/retros/{YYYY-MM-DD}-{N}.json` — per-project retro snapshot. [CONFIRMED]
- `~/.gstack/retros/global-{YYYY-MM-DD}-{N}.json` — global mode only. [CONFIRMED]

---

### 1.3 Review Log as Cross-Cutting Artifact

The review log (`~/.gstack/projects/{slug}/{branch}-reviews.jsonl`) acts as a shared state store that every skill in the pipeline can read and write. It is the backbone of the Review Readiness Dashboard shown by `/ship`. [CONFIRMED]

Skills that **write** to it: `/review`, `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/codex` (codex-review), `/design-review` (design-review-lite), `/ship` (adversarial-review, ship-review-override), `/land-and-deploy` (via projects JSONL), `/canary` (via projects JSONL), `/autoplan`, `/design-consultation` (design-outside-voices). [CONFIRMED]

Skills that **read** it: every skill with `gstack-review-read` in its preamble, including `/ship`, `/land-and-deploy`, `/qa-only`, `/benchmark`, `/canary`, `/cso`, `/investigate`, `/document-release`, `/codex`, `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/design-review`, `/design-consultation`, `/autoplan`, `/office-hours`. [CONFIRMED]

---

## 2. Generic Preamble Block for AVNER

This is a ready-to-paste block for embedding into any AVNER SKILL.md file. It provides update checking, session tracking, REPO_MODE detection, proactive suggestions, and hooks into AVNER's STATE.md for session continuity. Adapt `SKILL_NAME` for each skill.

```markdown
## Preamble (run first, before any skill logic)

\```bash
_UPD=$(~/.claude/skills/gstack/bin/gstack-update-check 2>/dev/null || .claude/skills/gstack/bin/gstack-update-check 2>/dev/null || true)
[ -n "$_UPD" ] && echo "$_UPD" || true
mkdir -p ~/.gstack/sessions
touch ~/.gstack/sessions/"$PPID"
_SESSIONS=$(find ~/.gstack/sessions -mmin -120 -type f 2>/dev/null | wc -l | tr -d ' ')
find ~/.gstack/sessions -mmin +120 -type f -delete 2>/dev/null || true
_CONTRIB=$(~/.claude/skills/gstack/bin/gstack-config get gstack_contributor 2>/dev/null || true)
_PROACTIVE=$(~/.claude/skills/gstack/bin/gstack-config get proactive 2>/dev/null || echo "true")
_PROACTIVE_PROMPTED=$([ -f ~/.gstack/.proactive-prompted ] && echo "yes" || echo "no")
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "BRANCH: $_BRANCH"
echo "PROACTIVE: $_PROACTIVE"
echo "PROACTIVE_PROMPTED: $_PROACTIVE_PROMPTED"
source <(~/.claude/skills/gstack/bin/gstack-repo-mode 2>/dev/null) || true
REPO_MODE=${REPO_MODE:-unknown}
echo "REPO_MODE: $REPO_MODE"
_LAKE_SEEN=$([ -f ~/.gstack/.completeness-intro-seen ] && echo "yes" || echo "no")
echo "LAKE_INTRO: $_LAKE_SEEN"
_TEL=$(~/.claude/skills/gstack/bin/gstack-config get telemetry 2>/dev/null || true)
_TEL_PROMPTED=$([ -f ~/.gstack/.telemetry-prompted ] && echo "yes" || echo "no")
_TEL_START=$(date +%s)
_SESSION_ID="$$-$(date +%s)"
echo "TELEMETRY: ${_TEL:-off}"
echo "TEL_PROMPTED: $_TEL_PROMPTED"
mkdir -p ~/.gstack/analytics
echo '{"skill":"SKILL_NAME","ts":"'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'","repo":"'"$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")"'"}'  >> ~/.gstack/analytics/skill-usage.jsonl 2>/dev/null || true
for _PF in $(find ~/.gstack/analytics -maxdepth 1 -name '.pending-*' 2>/dev/null); do [ -f "$_PF" ] && ~/.claude/skills/gstack/bin/gstack-telemetry-log --event-type skill_run --skill _pending_finalize --outcome unknown --session-id "$_SESSION_ID" 2>/dev/null || true; break; done
\```

### AVNER STATE.md session continuity hook

After the preamble bash block, immediately read AVNER state:

\```bash
cat .avner/4_operations/STATE.md 2>/dev/null || echo "NO_STATE"
\```

If STATE.md shows an IN PROGRESS task and this skill would start a new task, enforce Gate G1 (Finish Before Start). Exception: P0 bugs, /deploy, /sec modes. [CONFIRMED — avner/SKILL.md]

### Update check behavior

If output contains `UPGRADE_AVAILABLE <old> <new>`: read `~/.claude/skills/gstack/gstack-upgrade/SKILL.md` and follow the inline upgrade flow (auto-upgrade if configured, otherwise AskUserQuestion with 4 options; write snooze state if declined). [CONFIRMED]

If output contains `JUST_UPGRADED <from> <to>`: tell user "Running gstack v{to} (just updated!)" and continue. [CONFIRMED]

### Session state variables

| Variable | Values | Meaning |
|----------|--------|---------|
| `_BRANCH` | string | Current git branch name [CONFIRMED] |
| `REPO_MODE` | `solo` / `collaborative` / `unknown` | Repo ownership [CONFIRMED] |
| `_PROACTIVE` | `true` / `false` | Whether to auto-suggest skills [CONFIRMED] |
| `_SESSIONS` | integer | Active Claude Code windows (2h window) [CONFIRMED] |
| `_LAKE_SEEN` | `yes` / `no` | Whether Boil the Lake intro was shown [CONFIRMED] |
| `_CONTRIB` | `true` / (empty) | Contributor mode active [CONFIRMED] |
| `_TEL` | `community` / `anonymous` / `off` | Telemetry level [CONFIRMED] |
| `_TEL_PROMPTED` | `yes` / `no` | Whether user was asked about telemetry [CONFIRMED] |
| `_PROACTIVE_PROMPTED` | `yes` / `no` | Whether user was asked about proactive behavior [CONFIRMED] |
| `_SESSION_ID` | `PID-timestamp` | Unique session identifier [CONFIRMED] |
| `_TEL_START` | unix timestamp | Used for duration tracking [CONFIRMED] |

### Proactive suggestions

If `PROACTIVE` is `false`: do NOT auto-invoke any skill. If you would have suggested one, say: "I think /skillname might help here — want me to run it?" and wait. [CONFIRMED]

If `PROACTIVE` is `true` (default): suggest adjacent gstack skills when relevant:
- Brainstorming → /office-hours
- Strategy → /plan-ceo-review
- Architecture → /plan-eng-review
- Design → /plan-design-review or /design-consultation
- Auto-review → /autoplan
- Debugging → /investigate
- QA → /qa
- Code review → /review
- Visual audit → /design-review
- Shipping → /ship
- Docs → /document-release
- Retro → /retro
- Second opinion → /codex
- Prod safety → /careful or /guard
- Scoped edits → /freeze or /unfreeze

If `_SESSIONS` ≥ 3: enter ELI16 mode — every AskUserQuestion must re-ground the user on the current project, branch, and task before asking anything. [CONFIRMED — ARCHITECTURE.md]

### REPO_MODE behavior

- `solo`: fix issues proactively when found.
- `collaborative` / `unknown`: flag issues but do not fix — another contributor may own the affected code. [CONFIRMED]

### One-time intro sequence (first-run only, in order)

1. **Lake intro** (if `LAKE_INTRO=no`): Introduce the Completeness Principle ("Boil the Lake"). Offer to open `https://garryslist.org/posts/boil-the-ocean`. Always run: `touch ~/.gstack/.completeness-intro-seen`. [CONFIRMED]
2. **Telemetry prompt** (if `TEL_PROMPTED=no` AND `LAKE_INTRO=yes`): Ask about telemetry — community/anonymous/off. Always run: `touch ~/.gstack/.telemetry-prompted`. [CONFIRMED]
3. **Proactive prompt** (if `PROACTIVE_PROMPTED=no` AND `TEL_PROMPTED=yes`): Ask about proactive mode — on/off. Always run: `touch ~/.gstack/.proactive-prompted`. [CONFIRMED]

### Contributor mode (if `_CONTRIB=true`)

At the end of each major workflow step, rate the gstack experience 0-10. If not a 10 and there is an actionable bug, file a field report to `~/.gstack/contributor-logs/{slug}.md`. Format:
```
# {Title}
**What I tried:** {action} | **What happened:** {result} | **Rating:** {0-10}
## Repro
1. {step}
## What would make this a 10
{one sentence}
**Date:** {YYYY-MM-DD} | **Version:** {version} | **Skill:** /{skill}
```
Max 3 field reports per session. Skip if file already exists. File inline — do not stop. [CONFIRMED]

### Completion status protocol

Report one of:
- **DONE** — all steps complete, evidence provided for each claim.
- **DONE_WITH_CONCERNS** — completed with issues to note (list each).
- **BLOCKED** — cannot proceed. Use escalation format.
- **NEEDS_CONTEXT** — missing information required to continue.

Escalation format:
```
STATUS: BLOCKED | NEEDS_CONTEXT
REASON: [1-2 sentences]
ATTEMPTED: [what you tried]
RECOMMENDATION: [what the user should do next]
```
[CONFIRMED]

### AskUserQuestion format (all questions must follow this)

1. **Re-ground** — state project, current branch (from `_BRANCH`, not from history), and current task.
2. **Simplify** — plain English, no jargon, no raw function names.
3. **Recommend** — `RECOMMENDATION: Choose [X] because [reason]` with `Completeness: X/10` for each option.
4. **Options** — lettered A) B) C)..., effort shown as `(human: ~X / CC: ~Y)`.
[CONFIRMED]

### Telemetry (run last, always — including on error or abort)

\```bash
_TEL_END=$(date +%s)
_TEL_DUR=$(( _TEL_END - _TEL_START ))
rm -f ~/.gstack/analytics/.pending-"$_SESSION_ID" 2>/dev/null || true
~/.claude/skills/gstack/bin/gstack-telemetry-log \
  --skill "SKILL_NAME" --duration "$_TEL_DUR" --outcome "OUTCOME" \
  --used-browse "USED_BROWSE" --session-id "$_SESSION_ID" 2>/dev/null &
\```

Replace `SKILL_NAME` with the skill's name field, `OUTCOME` with success/error/abort/unknown, `USED_BROWSE` with true/false. Runs in background, never blocks. [CONFIRMED]

### Plan Status Footer (only in plan mode)

When about to call `ExitPlanMode`:
1. Check if the plan file already has `## GSTACK REVIEW REPORT` → skip if yes.
2. If not, run `~/.claude/skills/gstack/bin/gstack-review-read`.
3. Write `## GSTACK REVIEW REPORT` table to end of the plan file.

If `gstack-review-read` returns review entries (JSONL lines before `---CONFIG---`): format the standard table with runs/status/findings per skill. If it returns `NO_REVIEWS`: write the placeholder table with 0 runs and `VERDICT: NO REVIEWS YET`. [CONFIRMED]
```

---

## 3. CLAUDE.md Integration Requirements

The following must be present in any project's `CLAUDE.md` for gstack to operate correctly across all skills.

### 3.1 Skill Directory Paths

```markdown
## GStack Skills

Skills are installed at one of two locations (checked in this order):
1. `{repo-root}/.claude/skills/gstack/` — project-local install (preferred, checked first)
2. `~/.claude/skills/gstack/` — global install (fallback)

All skill preambles use the global path. The project-local path is preferred when it exists.
```
[CONFIRMED — SKILL.md binary discovery block; ARCHITECTURE.md vendored symlink section]

### 3.2 Browse Binary Path

```markdown
## Browse Binary

gstack browse is a compiled Bun binary. Find it:
```bash
_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
B=""
[ -n "$_ROOT" ] && [ -x "$_ROOT/.claude/skills/gstack/browse/dist/browse" ] && B="$_ROOT/.claude/skills/gstack/browse/dist/browse"
[ -z "$B" ] && B=~/.claude/skills/gstack/browse/dist/browse
if [ -x "$B" ]; then
  echo "READY: $B"
else
  echo "NEEDS_SETUP"
fi
```

If `NEEDS_SETUP`: tell user "gstack browse needs a one-time build (~10 seconds). OK to proceed?" then run: `cd <SKILL_DIR> && ./setup`

If `bun` is missing: `curl -fsSL https://bun.sh/install | bash`

**NEVER use `mcp__claude-in-chrome__*` tools — they are slow and unreliable.**
```
[CONFIRMED — SKILL.md Setup section; ARCHITECTURE.md binary model section]

### 3.3 Required Environment Variables

```markdown
## Environment Variables

| Variable | Required by | Notes |
|----------|-------------|-------|
| `ANTHROPIC_API_KEY` | test:evals (dev only) | Not needed for end users |
| `CLAUDE_SKILL_DIR` | careful, freeze, guard, investigate hook scripts | Set automatically by Claude Code |
| `CLAUDE_PLUGIN_DATA` | freeze, guard, unfreeze (state file) | Falls back to `$HOME/.gstack` if unset |
| `GSTACK_HOME` | gstack-review-log, gstack-review-read | Falls back to `$HOME/.gstack` if unset |
```

Notes:
- `CLAUDE_SKILL_DIR` and `CLAUDE_PLUGIN_DATA` are injected by Claude Code automatically; never hardcode them. [CONFIRMED]
- `GSTACK_HOME` is read by `gstack-review-log` and `gstack-review-read` binaries. [CONFIRMED — gstack-review-log source]
- No `OPENAI_API_KEY` is needed — Codex E2E tests use `~/.codex/` config directly. [CONFIRMED — CLAUDE.md]

### 3.4 Test / Build / Deploy Commands

gstack is platform-agnostic. Skills read `CLAUDE.md` to find project-specific commands rather than hardcoding them. [CONFIRMED — CLAUDE.md "Platform-agnostic design" section]

The following table shows what each skill looks for in CLAUDE.md. If a command is missing, the skill either asks the user once via AskUserQuestion or searches the repo for detection signals.

```markdown
## Commands

```bash
# Test commands (read by /qa, /ship, /land-and-deploy)
<test_command>          # e.g., bun test, npm test, pytest
<eval_command>          # e.g., bun run test:evals (paid, diff-based)

# Build command (read by /ship, /document-release)
<build_command>         # e.g., bun run build, npm run build

# Deploy command (read by /land-and-deploy)
<deploy_command>        # e.g., vercel --prod, fly deploy, railway up

# Dev server (read by /qa, /canary for URL auto-detection)
<dev_command>           # e.g., bun run dev, npm start
```
```
[CONFIRMED — CLAUDE.md; GSTACK_SKILL_REFERENCE.md /ship and /qa sections]

After a skill asks the user for a missing command, it persists the answer to `CLAUDE.md` so it is never asked again. [CONFIRMED — CLAUDE.md "Platform-agnostic design"]

### 3.5 Design System Reference

Written by `/design-consultation` after creating `DESIGN.md`. [CONFIRMED]

```markdown
## Design System
Always read DESIGN.md before making any visual or UI decisions.
All font choices, colors, spacing, and aesthetic direction are defined there.
Do not deviate without explicit user approval.
In QA mode, flag any code that doesn't match DESIGN.md.
```
[CONFIRMED — design-consultation/SKILL.md Phase 6]

### 3.6 Commit Conventions

```markdown
## Commit Conventions

**Always bisect commits.** Every commit is one logical change — independently understandable and revertable.

Good bisection examples:
- Rename/move separate from behavior changes
- Test infrastructure separate from test implementations
- Template changes separate from generated file regeneration
- Mechanical refactors separate from new features

**VERSION and CHANGELOG are branch-scoped.** Every branch that ships gets its own version bump and CHANGELOG entry covering all commits on the branch vs base. Never fold work into an existing entry from a prior version already on main.

**CHANGELOG is for users, not contributors:**
- Lead with what the user can now DO.
- Plain language, no implementation details.
- Never mention TODOS.md, internal tracking, or contributor-facing details.
- Separate "For contributors" section at the bottom if needed.

**NEVER stage browse/dist/ binaries.** Use specific filenames when staging (`git add file1 file2`), never `git add .` or `git add -A`.
```
[CONFIRMED — CLAUDE.md "Commit style" and "CHANGELOG + VERSION style" sections]

### 3.7 Full Minimal CLAUDE.md Template for AVNER Projects

```markdown
# CLAUDE.md — [Project Name]

## Commands

```bash
# Run before every commit (free, <5s)
<test_command>

# Run before shipping (paid, diff-based)
<eval_command>

# Build
<build_command>

# Dev server
<dev_command>

# Deploy
<deploy_command>
```

## GStack Skills

Project-local: `.claude/skills/gstack/`
Global fallback: `~/.claude/skills/gstack/`
Browse binary: `.claude/skills/gstack/browse/dist/browse` (or global path)

## Design System
Always read DESIGN.md before making any visual or UI decisions.
All font choices, colors, spacing, and aesthetic direction are defined there.
Do not deviate without explicit user approval.
In QA mode, flag any code that doesn't match DESIGN.md.

## Commit Conventions
Always bisect commits. Every commit is one logical change.
VERSION and CHANGELOG are branch-scoped.
CHANGELOG is for users — lead with what they can now DO.
Never stage browse/dist/ binaries.

## Search Before Building
Before building anything involving unfamiliar patterns or infrastructure:
1. Search for "{runtime} {thing} built-in"
2. Search for "{thing} best practice {current year}"
3. Check official runtime/framework docs
Three layers: tried-and-true (Layer 1), new-and-popular (Layer 2), first-principles (Layer 3).

## AI Effort Compression

| Task type | Human team | CC+gstack | Compression |
|-----------|-----------|-----------|-------------|
| Boilerplate / scaffolding | 2 days | 15 min | ~100x |
| Test writing | 1 day | 15 min | ~50x |
| Feature implementation | 1 week | 30 min | ~30x |
| Bug fix + regression test | 4 hours | 15 min | ~20x |
| Architecture / design | 2 days | 4 hours | ~5x |
| Research / exploration | 1 day | 3 hours | ~3x |
```
[CONFIRMED — CLAUDE.md; ETHOS.md]

---

## 4. Review Log System

### 4.1 Overview

The review log system is a JSONL-based shared state store that tracks which reviews have been run on the current branch, their outcomes, and the git commit at which they ran. It is the single source of truth for the Review Readiness Dashboard displayed by `/ship`. [CONFIRMED]

### 4.2 Storage Location

```
~/.gstack/projects/{slug}/{branch}-reviews.jsonl
```

- `{slug}` is derived from the git remote URL: `git remote get-url origin` → strips host/protocol → formats as `owner-repo` (sanitized to `[a-zA-Z0-9._-]`). [CONFIRMED — gstack-slug binary]
- `{branch}` is the current branch name from `git rev-parse --abbrev-ref HEAD` (with `/` replaced by `-`, sanitized). [CONFIRMED — gstack-slug binary]
- The file is **append-only** — each review run appends a new JSONL line. [CONFIRMED — gstack-review-log binary: `echo "$1" >> ...`]

### 4.3 Write Mechanism

All writes use `gstack-review-log`:

```bash
~/.claude/skills/gstack/bin/gstack-review-log '{"skill":"...","timestamp":"...","status":"...",...}'
```

The binary sources `gstack-slug` to get `$SLUG` and `$BRANCH`, creates the directory if needed, and appends the JSON object as a single line. [CONFIRMED — gstack-review-log source]

Security: slug and branch are sanitized to `[a-zA-Z0-9._-]` only, preventing shell injection. [CONFIRMED — gstack-slug binary]

### 4.4 JSONL Schema by Skill

Each line is a complete JSON object. The `skill` field identifies which review wrote it.

```jsonl
{"skill":"plan-ceo-review","timestamp":"2026-03-29T10:00:00Z","status":"clean","unresolved":0,"critical_gaps":0,"mode":"SELECTIVE_EXPANSION","scope_proposed":3,"scope_accepted":2,"scope_deferred":1,"commit":"abc1234"}
{"skill":"plan-eng-review","timestamp":"2026-03-29T10:15:00Z","status":"clean","unresolved":0,"critical_gaps":0,"issues_found":2,"mode":"FULL_REVIEW","commit":"abc1234"}
{"skill":"plan-design-review","timestamp":"2026-03-29T10:30:00Z","status":"clean","initial_score":6,"overall_score":8,"unresolved":0,"decisions_made":4,"commit":"abc1234"}
{"skill":"codex-review","timestamp":"2026-03-29T11:00:00Z","status":"pass","gate":"PASS","findings":0,"findings_fixed":0}
{"skill":"review","timestamp":"2026-03-29T11:30:00Z","status":"clean","commit":"def5678"}
{"skill":"design-review-lite","timestamp":"2026-03-29T12:00:00Z","status":"clean","findings":3,"auto_fixed":3,"commit":"def5678"}
{"skill":"adversarial-review","timestamp":"2026-03-29T12:05:00Z","status":"pass","source":"codex","tier":"medium","commit":"def5678"}
{"skill":"ship-review-override","timestamp":"2026-03-29T12:10:00Z","decision":"not_relevant"}
{"skill":"autoplan-voices","timestamp":"2026-03-29T10:20:00Z","status":"clean","source":"codex","phase":"eng","via":"autoplan","consensus_confirmed":4,"consensus_disagree":1,"commit":"abc1234"}
{"skill":"codex-plan-review","timestamp":"2026-03-29T10:10:00Z","status":"pass","source":"codex","commit":"abc1234"}
{"skill":"design-outside-voices","timestamp":"2026-03-29T10:25:00Z","status":"pass","source":"claude-subagent","commit":"abc1234"}
```
[CONFIRMED — from each skill's SKILL.md `gstack-review-log` call sites and GSTACK_SKILL_REFERENCE.md Section 5]

| Field | Present in | Meaning |
|-------|-----------|---------|
| `skill` | All | Which skill wrote this entry |
| `timestamp` | All | ISO 8601 UTC |
| `status` | All | `clean` / `pass` / `issues` / `fail` (skill-specific) |
| `commit` | Most | Short SHA of HEAD when review ran |
| `unresolved` | plan-* | Count of open items |
| `critical_gaps` | plan-ceo, plan-eng | Count of critical gaps |
| `mode` | plan-ceo, plan-eng | Review mode used |
| `scope_proposed/accepted/deferred` | plan-ceo-review | Scope decision counts |
| `issues_found` | plan-eng-review | Count of issues found |
| `initial_score`, `overall_score` | plan-design-review | Design score 0-10 before/after |
| `decisions_made` | plan-design-review | Count of design decisions applied |
| `gate` | codex-review | `PASS` / `FAIL` |
| `findings`, `findings_fixed` | codex-review, design-review-lite | Bug counts |
| `auto_fixed` | design-review-lite | Auto-applied fixes |
| `source` | autoplan-voices, outside-voices, adversarial | `codex` / `claude-subagent` |
| `phase` | autoplan-voices | `ceo` / `eng` / `design` |
| `via` | autoplan-* | `autoplan` (ran as part of autoplan pipeline) |
| `consensus_confirmed`, `consensus_disagree` | autoplan-voices | Cross-model consensus counts |
| `tier` | adversarial-review | `medium` / `large` |
| `decision` | ship-review-override | `ship_anyway` / `not_relevant` |

[CONFIRMED — from individual skill SKILL.md files]

### 4.5 Read Mechanism

```bash
~/.claude/skills/gstack/bin/gstack-review-read
```

Output format:
```
{"skill":"plan-eng-review","timestamp":"2026-03-29T10:15:00Z","status":"clean",...}
{"skill":"review","timestamp":"2026-03-29T11:30:00Z","status":"clean","commit":"def5678"}
---CONFIG---
false
---HEAD---
def5678
```

Three sections, always in this order: [CONFIRMED — gstack-review-read source]
1. **JSONL lines** — all entries in `{branch}-reviews.jsonl`, or `NO_REVIEWS` if file doesn't exist.
2. `---CONFIG---` — the value of `skip_eng_review` from `gstack-config` (`true` / `false`).
3. `---HEAD---` — current `git rev-parse --short HEAD`.

### 4.6 GSTACK REVIEW REPORT Table Generation

Skills generate this table at two points:
1. **In plan mode** — written to end of plan file before `ExitPlanMode`. [CONFIRMED]
2. **In `/ship` pre-flight** — displayed as the Review Readiness Dashboard. [CONFIRMED]

**Parsing rules for dashboard generation:**
- Find the most recent entry for each skill. [CONFIRMED — ship/SKILL.md]
- Ignore entries older than 7 days. [CONFIRMED — ship/SKILL.md]
- For **Eng Review**: show whichever is more recent between `review` (diff-scoped) and `plan-eng-review` (plan-stage). Append `(DIFF)` or `(PLAN)` to distinguish. [CONFIRMED]
- For **Adversarial**: show whichever is more recent between `adversarial-review` and `codex-review` (legacy). [CONFIRMED]
- For **Design Review**: show whichever is more recent between `plan-design-review` (full) and `design-review-lite` (code-level). Append `(FULL)` or `(LITE)`. [CONFIRMED]

**Staleness detection (post-display):**
- For each entry with a `commit` field: run `git rev-list --count {STORED_COMMIT}..HEAD`.
  - 0 commits ahead = `CURRENT`
  - 1-3 commits ahead = `RECENT`
  - 4+ commits ahead = `STALE`
- For entries without a `commit` field (legacy): display "no commit tracking — consider re-running". [CONFIRMED — ship/SKILL.md staleness detection section]

**Verdict logic:**
- `CLEARED`: Eng Review has ≥ 1 entry within 7 days from `review` or `plan-eng-review` with status `clean`, OR `skip_eng_review=true`. [CONFIRMED]
- `NOT CLEARED`: Eng Review missing, stale (>7 days), or has open issues. [CONFIRMED]
- CEO, Design, Codex reviews are informational — never block shipping. [CONFIRMED]

**Dashboard format:**
```
+====================================================================+
|                    REVIEW READINESS DASHBOARD                       |
+====================================================================+
| Review          | Runs | Last Run            | Status    | Required |
|-----------------|------|---------------------|-----------|----------|
| Eng Review      |  1   | 2026-03-16 15:00    | CLEAR (DIFF) | YES   |
| CEO Review      |  0   | —                   | —         | no       |
| Design Review   |  0   | —                   | —         | no       |
| Adversarial     |  0   | —                   | —         | no       |
| Outside Voice   |  0   | —                   | —         | no       |
+--------------------------------------------------------------------+
| VERDICT: CLEARED — Eng Review passed                                |
+====================================================================+
```
[CONFIRMED — ship/SKILL.md Review Readiness Dashboard section]

**Placeholder table (when no reviews have run):**

```markdown
## GSTACK REVIEW REPORT

| Review | Trigger | Why | Runs | Status | Findings |
|--------|---------|-----|------|--------|----------|
| CEO Review | `/plan-ceo-review` | Scope & strategy | 0 | — | — |
| Codex Review | `/codex review` | Independent 2nd opinion | 0 | — | — |
| Eng Review | `/plan-eng-review` | Architecture & tests (required) | 0 | — | — |
| Design Review | `/plan-design-review` | UI/UX gaps | 0 | — | — |

**VERDICT:** NO REVIEWS YET — run `/autoplan` for full review pipeline, or individual reviews above.
```
[CONFIRMED — SKILL.md Plan Status Footer section]

---

## 5. Storage Layout

All gstack file I/O is split across two scopes: **home-scoped** (`~/.gstack/`) for persistent cross-session state, and **project-scoped** (`.gstack/` relative to repo root) for per-project artifacts that belong with the code.

### 5.1 Home-Scoped: `~/.gstack/`

#### `~/.gstack/projects/{slug}/`

Per-project cross-session context. Slug is derived from git remote URL (owner-repo format, sanitized). [CONFIRMED — gstack-slug]

| File pattern | Written by | Read by | Purpose |
|-------------|-----------|---------|---------|
| `{branch}-reviews.jsonl` | All review skills via `gstack-review-log` | `/ship`, every preamble via `gstack-review-read` | Review log — Review Readiness Dashboard source [CONFIRMED] |
| `{user}-{branch}-design-{datetime}.md` | `/office-hours` | `/plan-ceo-review`, `/plan-eng-review`, `/plan-design-review`, `/autoplan`, `/design-consultation` | Design document from office hours session [CONFIRMED] |
| `{user}-{branch}-ceo-handoff-{datetime}.md` | `/plan-ceo-review` | `/plan-eng-review` (optional context) | CEO review handoff note, deleted by `/ship` after use [CONFIRMED] |
| `ceo-plans/{date}-{feature-slug}.md` | `/plan-ceo-review` | Human review | CEO plan artifact [CONFIRMED] |
| `ceo-plans/archive/` | `/plan-ceo-review` | — | Stale CEO plans archived here [CONFIRMED] |
| `{user}-{branch}-test-plan-{datetime}.md` | `/plan-eng-review` (via `/autoplan`) | `/qa` | Test plan artifact [CONFIRMED] |
| `{user}-{branch}-test-outcome-{datetime}.md` | `/qa` | Human review | QA test outcome report [CONFIRMED] |
| `{user}-{branch}-design-audit-{datetime}.md` | `/design-review` | Human review | Full design audit report [CONFIRMED] |
| `{user}-{branch}-autoplan-restore-{datetime}.md` | `/autoplan` | `/autoplan` (restore on interruption) | Autoplan session restore checkpoint [CONFIRMED] |

Canary and land-and-deploy also write JSONL entries directly to `~/.gstack/projects/{slug}/` (not to `{branch}-reviews.jsonl`): [CONFIRMED]
- `/canary`: `{"skill":"canary","timestamp":"...","status":"...","url":"...","duration_min":N,"alerts":N}`
- `/land-and-deploy`: `{"skill":"land-and-deploy","timestamp":"...","status":"...","pr":N,"merge_sha":"...","deploy_status":"...","ci_wait_s":N,...}`

#### `~/.gstack/analytics/`

Telemetry and usage data. [CONFIRMED]

| File | Written by | Purpose |
|------|-----------|---------|
| `skill-usage.jsonl` | Every skill preamble | Per-skill invocation log: `{"skill":"...","ts":"...","repo":"..."}` [CONFIRMED] |
| `eureka.jsonl` | Any skill when Layer 3 reasoning contradicts convention | First-principles insight log [CONFIRMED — GSTACK_SKILL_REFERENCE.md "Eureka logging"] |
| `.pending-{session-id}` | Skill preamble (start-of-session marker) | In-progress session marker — removed on normal completion, triggers pending-finalize on next preamble run [CONFIRMED] |

#### `~/.gstack/sessions/`

Active session tracking. [CONFIRMED]

| File | Written by | Purpose |
|------|-----------|---------|
| `{PPID}` (touch file) | Every skill preamble | Marks an active Claude Code session; TTL = 120 minutes; files older than 120 min are purged by the next preamble run [CONFIRMED] |

Session count (`_SESSIONS`) = number of files modified in the last 120 minutes. When `_SESSIONS ≥ 3`, skills enter ELI16 mode (every question re-grounds context). [CONFIRMED — ARCHITECTURE.md]

#### `~/.gstack/contributor-logs/`

Contributor field reports (only when `gstack_contributor=true`). [CONFIRMED]

| File | Written by | Purpose |
|------|-----------|---------|
| `{slug}.md` | Any skill in contributor mode | Bug/improvement report. Slug = lowercase hyphens, max 60 chars. Max 3 per session. Skipped if already exists. [CONFIRMED] |

Format:
```markdown
# {Title}
**What I tried:** {action} | **What happened:** {result} | **Rating:** {0-10}
## Repro
1. {step}
## What would make this a 10
{one sentence}
**Date:** {YYYY-MM-DD} | **Version:** {version} | **Skill:** /{skill}
```
[CONFIRMED — SKILL.md Contributor Mode section]

#### `~/.gstack/retros/`

Global cross-project retro snapshots (only when running `/retro global`). [CONFIRMED]

| File | Written by | Purpose |
|------|-----------|---------|
| `global-{YYYY-MM-DD}-{N}.json` | `/retro global` | Cross-project retro snapshot; compared against prior global retros for trend tracking [CONFIRMED] |

#### One-time flag files in `~/.gstack/`

| File | Set by | Meaning |
|------|--------|---------|
| `.completeness-intro-seen` | Skill preamble (first run) | Boil the Lake intro has been shown [CONFIRMED] |
| `.telemetry-prompted` | Skill preamble (first run after lake intro) | Telemetry question has been asked [CONFIRMED] |
| `.proactive-prompted` | Skill preamble (first run after telemetry) | Proactive behavior question has been asked [CONFIRMED] |

#### `~/.gstack/freeze-dir.txt` (or `$CLAUDE_PLUGIN_DATA/freeze-dir.txt`)

| File | Written by | Read by | Purpose |
|------|-----------|---------|---------|
| `freeze-dir.txt` | `/freeze`, `/guard` | `check-freeze.sh` hook (invoked by `/freeze`, `/guard`, `/investigate` PreToolUse hooks) | Stores frozen directory path with trailing `/`. Removed by `/unfreeze`. Absence = no freeze active. [CONFIRMED] |

---

### 5.2 Project-Scoped: `.gstack/` (relative to repo root)

These directories live inside the project repository. They are typically gitignored. [INFERRED — consistent with gstack's separation of project artifacts from home state; [MISSING] explicit gitignore instructions in source files reviewed]

#### `.gstack/qa-reports/`

Written by `/qa` and `/qa-only`. [CONFIRMED]

| File | Purpose |
|------|---------|
| `qa-report-{domain}-{YYYY-MM-DD}.md` | Full QA report with health score, bugs by severity, recommendations [CONFIRMED] |
| `screenshots/*.png` | Evidence screenshots from QA session [CONFIRMED] |
| `baseline.json` | Baseline captured for regression comparisons (`--regression` mode) [CONFIRMED] |

#### `.gstack/design-reports/`

Written by `/design-review`. [CONFIRMED]

| File | Purpose |
|------|---------|
| `design-audit-{domain}-{YYYY-MM-DD}.md` | Full design audit report with dimension ratings and before/after diffs [CONFIRMED] |

Note: `/design-review` also writes detailed per-issue files with before/after screenshots. [CONFIRMED — design-review/SKILL.md `REPORT_DIR` references]

#### `.gstack/canary-reports/`

Written by `/canary`. [CONFIRMED]

| File | Purpose |
|------|---------|
| `{date}-canary.md` | Human-readable canary monitoring report [CONFIRMED] |
| `{date}-canary.json` | Machine-readable canary results (for scripted comparison) [CONFIRMED] |
| `screenshots/` | Screenshots captured during monitoring passes [CONFIRMED] |

#### `.gstack/deploy-reports/`

Written by `/land-and-deploy`. [CONFIRMED]

| File | Purpose |
|------|---------|
| `{date}-pr{number}-deploy.md` | Full deploy report with timing breakdown and health verdict [CONFIRMED] |
| `post-deploy.png` | Screenshot of live app immediately after deploy [CONFIRMED] |

#### `.gstack/security-reports/`

Written by `/cso`. [CONFIRMED]

| File | Purpose |
|------|---------|
| Security report (filename not confirmed) | OWASP + STRIDE audit findings [CONFIRMED that directory exists; [MISSING] exact filename pattern] |

#### `.gstack/benchmark-reports/`

Written by `/benchmark`. [CONFIRMED]

| File | Purpose |
|------|---------|
| `{date}-benchmark.md` | Human-readable performance audit report [CONFIRMED] |
| `{date}-benchmark.json` | Machine-readable metrics (TTFB, FCP, LCP, DOM, bundle sizes) [CONFIRMED] |
| `baselines/baseline.json` | Performance baseline for regression detection [CONFIRMED] |

#### `.gstack/browse.json`

Written by the browse daemon server on startup. [CONFIRMED — ARCHITECTURE.md]

```json
{ "pid": 12345, "port": 34567, "token": "uuid-v4", "startedAt": "...", "binaryVersion": "abc123" }
```

The CLI reads this file to find the running server. Written atomically (tmp file + rename). Mode 0o600 (owner-read only). [CONFIRMED]

#### `.context/`

Miscellaneous per-project context files used by several skills. [CONFIRMED from multiple skill references]

| File | Written by | Read by | Purpose |
|------|-----------|---------|---------|
| `codex-session-id` | `/codex` (consult mode) | `/codex` | Session continuity for `/codex <prompt>` mode [CONFIRMED] |
| `retros/{YYYY-MM-DD}-{N}.json` | `/retro` | `/retro` | Per-project retro snapshot for trend comparison [CONFIRMED] |

---

### 5.3 Global Fallback: `~/.gstack-dev/` (contributors only)

Used during gstack development itself, not in end-user projects. [CONFIRMED — CLAUDE.md]

| Path | Purpose |
|------|---------|
| `evals/` | E2E eval run results (`_partial-e2e.json`, `e2e-{timestamp}.json`, per-run dirs) [CONFIRMED] |
| `evals/e2e-runs/{runId}/` | Per-run observability files (heartbeat, progress log, NDJSON transcript) [CONFIRMED] |
| `plans/` | Local long-range vision docs and design documents (not checked in) [CONFIRMED] |

---

### 5.4 Summary Annotation Table

| Path | Scope | [CONFIRMED/INFERRED/MISSING] |
|------|-------|-------------------------------|
| `~/.gstack/projects/{slug}/{branch}-reviews.jsonl` | Home | [CONFIRMED] |
| `~/.gstack/projects/{slug}/{user}-{branch}-design-{datetime}.md` | Home | [CONFIRMED] |
| `~/.gstack/projects/{slug}/ceo-plans/` | Home | [CONFIRMED] |
| `~/.gstack/projects/{slug}/{user}-{branch}-test-plan-{datetime}.md` | Home | [CONFIRMED] |
| `~/.gstack/projects/{slug}/{user}-{branch}-test-outcome-{datetime}.md` | Home | [CONFIRMED] |
| `~/.gstack/projects/{slug}/{user}-{branch}-design-audit-{datetime}.md` | Home | [CONFIRMED] |
| `~/.gstack/analytics/skill-usage.jsonl` | Home | [CONFIRMED] |
| `~/.gstack/analytics/eureka.jsonl` | Home | [CONFIRMED] |
| `~/.gstack/analytics/.pending-{session}` | Home | [CONFIRMED] |
| `~/.gstack/sessions/{PPID}` | Home | [CONFIRMED] |
| `~/.gstack/contributor-logs/{slug}.md` | Home | [CONFIRMED] |
| `~/.gstack/retros/global-{date}-{N}.json` | Home | [CONFIRMED] |
| `~/.gstack/.completeness-intro-seen` | Home | [CONFIRMED] |
| `~/.gstack/.telemetry-prompted` | Home | [CONFIRMED] |
| `~/.gstack/.proactive-prompted` | Home | [CONFIRMED] |
| `~/.gstack/freeze-dir.txt` | Home | [CONFIRMED] |
| `.gstack/qa-reports/qa-report-{domain}-{date}.md` | Project | [CONFIRMED] |
| `.gstack/qa-reports/screenshots/` | Project | [CONFIRMED] |
| `.gstack/qa-reports/baseline.json` | Project | [CONFIRMED] |
| `.gstack/design-reports/design-audit-{domain}-{date}.md` | Project | [CONFIRMED] |
| `.gstack/canary-reports/{date}-canary.md` | Project | [CONFIRMED] |
| `.gstack/canary-reports/{date}-canary.json` | Project | [CONFIRMED] |
| `.gstack/canary-reports/screenshots/` | Project | [CONFIRMED] |
| `.gstack/deploy-reports/{date}-pr{N}-deploy.md` | Project | [CONFIRMED] |
| `.gstack/deploy-reports/post-deploy.png` | Project | [CONFIRMED] |
| `.gstack/security-reports/` | Project | [CONFIRMED directory; [MISSING] filename pattern] |
| `.gstack/benchmark-reports/{date}-benchmark.md` | Project | [CONFIRMED] |
| `.gstack/benchmark-reports/{date}-benchmark.json` | Project | [CONFIRMED] |
| `.gstack/benchmark-reports/baselines/baseline.json` | Project | [CONFIRMED] |
| `.gstack/browse.json` | Project | [CONFIRMED] |
| `.context/codex-session-id` | Project | [CONFIRMED] |
| `.context/retros/{date}-{N}.json` | Project | [CONFIRMED] |
| `~/.gstack-dev/evals/` | Dev-only | [CONFIRMED] |
| `~/.gstack-dev/plans/` | Dev-only | [CONFIRMED] |
