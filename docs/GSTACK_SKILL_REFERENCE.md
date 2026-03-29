# GStack Skill Reference — AVNER v8

<!-- Source: /home/user/workspace/avner-stack/vendor/gstack/*/SKILL.md -->
<!-- Generated: 2026-03-29 -->
<!-- Annotations: [CONFIRMED] = seen in source, [INFERRED] = reasoned, [MISSING] = not found -->

---

## Master Table of All Skills

| Skill | Version | Preamble Tier | Caller | Hooks | Browser ($B) | Category |
|-------|---------|--------------|--------|-------|-------------|----------|
| `/review` | 1.0.0 | 4 | Claude Code | None | No | Code Quality |
| `/qa` | 2.0.0 | 4 | Claude Code | None | Yes | Testing |
| `/qa-only` | 1.0.0 | 4 | Claude Code | None | Yes | Testing |
| `/ship` | 1.0.0 | 4 | Claude Code | None | No | Shipping |
| `/codex` | 1.0.0 | 3 | Claude Code | None | No | AI Second Opinion |
| `/autoplan` | 1.0.0 | 3 | Claude Code | None | No | Planning |
| `/careful` | 0.1.0 | — | Claude Code | PreToolUse:Bash | No | Safety |
| `/freeze` | 0.1.0 | — | Claude Code | PreToolUse:Edit/Write | No | Safety |
| `/guard` | 0.1.0 | — | Claude Code | PreToolUse:Bash+Edit+Write | No | Safety |
| `/unfreeze` | 0.1.0 | — | Claude Code | None | No | Safety |
| `/cso` | 2.0.0 | 2 | Claude Code | None | No | Security |
| `/canary` | 1.0.0 | 2 | Claude Code | None | Yes | Deploy |
| `/benchmark` | 1.0.0 | 1 | Claude Code | None | Yes | Performance |
| `/land-and-deploy` | 1.0.0 | 4 | Claude Code | None | Yes | Deploy |
| `/document-release` | 1.0.0 | 2 | Claude Code | None | No | Documentation |
| `/retro` | 2.0.0 | 2 | Claude Code | None | No | Analytics |
| `/plan-eng-review` | 2.0.0 | 3 | Claude Code | None | No | Planning |
| `/plan-design-review` | 2.0.0 | 3 | Claude Code | None | No | Planning |
| `/design-review` | 2.0.0 | 4 | Claude Code | None | Yes | Design |
| `/design-consultation` | 1.0.0 | 3 | Claude Code | None | Yes (optional) | Design |
| `/investigate` | 1.0.0 | 2 | Claude Code | PreToolUse:Edit/Write | No | Debugging |
| `/office-hours` | [large] | — | Claude Code | None | No | Planning |
| `/plan-ceo-review` | [large] | — | Claude Code | None | No | Planning |

> **Preamble Tier** controls which boilerplate sections are included. Higher number = more shared preamble blocks included. Skills without a tier (careful, freeze, guard, unfreeze) have minimal preamble. [CONFIRMED]

---

## Section 1: Shared Preamble System

All standard skills share a common preamble block (auto-generated from `SKILL.md.tmpl`). [CONFIRMED]

### Preamble Bash Block (runs at skill start)

```bash
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
echo '{"skill":"SKILL_NAME","ts":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","repo":"'$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "unknown")'"}'  >> ~/.gstack/analytics/skill-usage.jsonl 2>/dev/null || true
for _PF in $(find ~/.gstack/analytics -maxdepth 1 -name '.pending-*' 2>/dev/null); do [ -f "$_PF" ] && ~/.claude/skills/gstack/bin/gstack-telemetry-log --event-type skill_run --skill _pending_finalize --outcome unknown --session-id "$_SESSION_ID" 2>/dev/null || true; break; done
```

### Preamble Variables

| Variable | Values | Meaning |
|----------|--------|---------|
| `_BRANCH` | string | Current git branch name |
| `REPO_MODE` | `solo` / `collaborative` / `unknown` | Who owns the repo |
| `_PROACTIVE` | `true` / `false` | Whether to auto-suggest skills |
| `_LAKE_SEEN` | `yes` / `no` | Whether "Boil the Lake" intro was shown |
| `_CONTRIB` | `true` / (empty) | Contributor mode active |
| `_TEL` | `community` / `anonymous` / `off` | Telemetry level |
| `_TEL_PROMPTED` | `yes` / `no` | Whether user was asked about telemetry |
| `_PROACTIVE_PROMPTED` | `yes` / `no` | Whether user was asked about proactive behavior |
| `_TEL_START` | unix timestamp | Used for duration tracking |
| `_SESSION_ID` | `PID-timestamp` | Unique session identifier |

### Preamble Behaviors (in order) [CONFIRMED]

1. **Update check** — if `UPGRADE_AVAILABLE <old> <new>`, read gstack-upgrade/SKILL.md and follow inline upgrade flow. If `JUST_UPGRADED`, inform user.
2. **Session tracking** — touch `~/.gstack/sessions/$PPID`, expire sessions older than 120 minutes.
3. **Proactive mode** — if `PROACTIVE=false`, never auto-invoke skills; instead say "I think /skill might help — want me to run it?"
4. **Lake intro** — if `LAKE_INTRO=no`, introduce the "Boil the Lake" completeness principle (once only). Offer to open `https://garryslist.org/posts/boil-the-ocean` in browser.
5. **Telemetry prompt** — if `TEL_PROMPTED=no` AND lake intro already shown: ask user about telemetry (community/anonymous/off). Runs once. Touch `~/.gstack/.telemetry-prompted`.
6. **Proactive prompt** — if `PROACTIVE_PROMPTED=no` AND telemetry already prompted: ask user about proactive mode. Runs once. Touch `~/.gstack/.proactive-prompted`.

### Shared Preamble Sections (across all tier-≥1 skills) [CONFIRMED]

#### AskUserQuestion Format
Every AskUserQuestion must follow this structure:
1. **Re-ground** — state project, current branch (from `_BRANCH`, not from history), and current task
2. **Simplify** — plain English, no jargon, no raw function names
3. **Recommend** — `RECOMMENDATION: Choose [X] because [reason]` with `Completeness: X/10` for each option
4. **Options** — lettered A) B) C)..., effort shown as `(human: ~X / CC: ~Y)`

#### Completeness Principle (Boil the Lake)
- "AI makes completeness near-free. Always recommend the complete option over shortcuts."
- Lake = 100% coverage, all edge cases (boilable). Ocean = full rewrite/migration (not boilable).
- Effort reference table:

| Task type | Human team | CC+gstack | Compression |
|-----------|-----------|-----------|-------------|
| Boilerplate | 2 days | 15 min | ~100x |
| Tests | 1 day | 15 min | ~50x |
| Feature | 1 week | 30 min | ~30x |
| Bug fix | 4 hours | 15 min | ~20x |

#### Repo Ownership (REPO_MODE)
- `solo` — fix issues proactively
- `collaborative` / `unknown` — flag but don't fix (may be someone else's work)

#### Search Before Building
Consult `~/.claude/skills/gstack/ETHOS.md`. Three layers: Layer 1 (tried/true, don't reinvent), Layer 2 (new/popular, scrutinize), Layer 3 (first principles, prize above all).

**Eureka logging**: when first-principles reasoning contradicts conventional wisdom, log to `~/.gstack/analytics/eureka.jsonl`.

#### Contributor Mode
If `_CONTRIB=true`: rate gstack experience 0-10 after each major step. File bugs to `~/.gstack/contributor-logs/{slug}.md` (max 3/session).

#### Completion Status Protocol
- **DONE** — all steps complete, evidence provided
- **DONE_WITH_CONCERNS** — completed with issues to note
- **BLOCKED** — cannot proceed; use escalation format
- **NEEDS_CONTEXT** — missing information

#### Telemetry (run last, always)
```bash
_TEL_END=$(date +%s)
_TEL_DUR=$(( _TEL_END - _TEL_START ))
rm -f ~/.gstack/analytics/.pending-"$_SESSION_ID" 2>/dev/null || true
~/.claude/skills/gstack/bin/gstack-telemetry-log \
  --skill "SKILL_NAME" --duration "$_TEL_DUR" --outcome "OUTCOME" \
  --used-browse "USED_BROWSE" --session-id "$_SESSION_ID" 2>/dev/null &
```
Runs in background, never blocks. OUTCOME = success/error/abort/unknown.

#### Plan Status Footer
When in plan mode before calling `ExitPlanMode`:
1. Check if plan file has `## GSTACK REVIEW REPORT` already → skip if yes
2. If not: run `~/.claude/skills/gstack/bin/gstack-review-read`
3. Write `## GSTACK REVIEW REPORT` table to end of plan file

---

## Section 2: Browse ($B) Command Reference

The `$B` variable holds the path to the gstack browse binary, found at:
- `{repo-root}/.claude/skills/gstack/browse/dist/browse` (project-local, preferred)
- `~/.claude/skills/gstack/browse/dist/browse` (global fallback)

Built with bun. Requires one-time setup (`cd <SKILL_DIR> && ./setup`) if binary is missing. [CONFIRMED]

### Setup Check (run before any $B command) [CONFIRMED]
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

### $B Command Reference Table [CONFIRMED from qa-only, canary, benchmark, design-consultation, land-and-deploy]

| Command | Example | Description |
|---------|---------|-------------|
| `goto <url>` | `$B goto http://localhost:3000` | Navigate to a URL |
| `screenshot <path>` | `$B screenshot /tmp/out.png` | Take a screenshot to file |
| `snapshot` | `$B snapshot` | Structured DOM snapshot (accessibility tree) |
| `snapshot -i` | `$B snapshot -i` | Interactive snapshot — shows clickable elements |
| `snapshot -a` | `$B snapshot -a` | Annotated screenshot (visual annotations) |
| `snapshot -D` | `$B snapshot -D` | Diff snapshot — shows what changed since last snapshot |
| `snapshot -C` | `$B snapshot -C` | Clickable-div scan — finds non-standard clickables |
| `snapshot -i -a -o <path>` | `$B snapshot -i -a -o out.png` | Combined: interactive + annotated + save to file |
| `links` | `$B links` | Extract all navigation links from current page |
| `console --errors` | `$B console --errors` | Show JS console errors only |
| `click @e5` | `$B click @e5` | Click element by accessibility ID from snapshot |
| `fill @e3 "text"` | `$B fill @e3 "user@example.com"` | Fill a form field |
| `viewport WxH` | `$B viewport 375x812` | Set viewport size (mobile/desktop testing) |
| `cookie-import <file>` | `$B cookie-import cookies.json` | Import cookies from JSON file |
| `perf` | `$B perf` | Page performance metrics |
| `text` | `$B text` | Extract visible text content from page |
| `eval "<js>"` | `$B eval "JSON.stringify(performance.getEntriesByType('navigation')[0])"` | Execute JavaScript in page context |
| `responsive` | `$B responsive` | Take screenshots at 3 viewport sizes |
| `js "<js>"` | `$B js "await fetch('/api/...')"` | Execute JS async expression |

### Browser Usage Rules [CONFIRMED]
- Show screenshots to user: after every `$B screenshot`, `$B snapshot -a -o`, or `$B responsive`, use the Read tool on the output file so user sees it inline
- Never refuse to use the browser when /qa or /qa-only is invoked
- For SPAs: use `snapshot -i` for navigation instead of `links` (client-side routes not captured by `links`)
- `snapshot -C` for tricky UIs with non-semantic clickables

---

## Section 3: Detailed Skill Documentation

---

### `/review` — Pre-Landing PR Review

**Version:** 1.0.0 | **Preamble Tier:** 4 | **Caller:** Claude Code [CONFIRMED]

**Description:** Pre-landing PR review. Analyzes diff against the base branch for SQL safety, LLM trust boundary violations, conditional side effects, and other structural issues.

**Allowed Tools:** Bash, Read, Edit, Write, Grep, Glob, Agent, AskUserQuestion, WebSearch [CONFIRMED]

**Trigger:** "review this PR", "code review", "pre-landing review", "check my diff". Proactively suggest when user is about to merge or land. [CONFIRMED]

**Key Inputs:**
- Current branch diff vs base branch
- PR description (`gh pr view --json body`)
- TODOS.md (if present)
- Plan file (auto-discovered)

**Key Outputs:**
- Review findings in conversation
- Review log written via `gstack-review-log` (JSONL to `~/.gstack/analytics/`)
- Plan file updated with `## GSTACK REVIEW REPORT` section

**Workflow Steps:**
1. **Step 0**: Detect platform (GitHub/GitLab/unknown) and base branch
2. **Step 1**: Validate branch (abort if on base branch, abort if no diff)
3. **Step 1.5**: Scope drift detection — compare stated intent (TODOS.md + PR desc + commits) vs actual files changed. Discovers plan file via conversation context or content-based search in `~/.claude/plans/*.md`
4. **Step 2+**: Core review checks for SQL safety, LLM trust boundaries, conditional side effects, N+1 queries, hardcoded secrets, dead code

**Handoff:** Feeds results into the gstack review dashboard (read by `/ship`). Cross-model comparison if `/codex review` also ran. [CONFIRMED]

---

### `/qa` — Test → Fix → Verify Loop

**Version:** 2.0.0 | **Preamble Tier:** 4 | **Caller:** Claude Code [CONFIRMED]

**Description:** Systematically QA test a web application and fix bugs found. Iteratively fixes bugs in source code, committing each fix atomically and re-verifying. Three tiers: Quick (critical/high only), Standard (+ medium, default), Exhaustive (+ cosmetic).

**Allowed Tools:** Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion, WebSearch [CONFIRMED]

**Trigger:** "qa", "QA", "test this site", "find bugs", "test and fix", "fix what's broken". Proactively suggest when user says a feature is ready for testing or asks "does this work?" [CONFIRMED]

**Key Inputs:**
- Target URL (auto-detect from local ports 3000/4000/8080 if not given)
- Tier (--quick / --exhaustive, default Standard)
- Mode (--regression for before/after diff)
- Auth credentials or cookie file (optional)
- Branch diff (for diff-aware mode when on feature branch without URL)

**Key Outputs:**
- `.gstack/qa-reports/qa-report-{domain}-{YYYY-MM-DD}.md`
- `.gstack/qa-reports/screenshots/*.png`
- `.gstack/qa-reports/baseline.json`
- `~/.gstack/projects/{slug}/{user}-{branch}-test-outcome-{datetime}.md`
- Atomic fix commits in git

**Modes:**
- **Diff-aware** (auto when on feature branch with no URL): analyze branch diff → identify affected routes → find running app → test affected pages
- **Full** (when URL given): systematic exploration of all pages
- **Quick** (`--quick`): 30s smoke test, homepage + top 5 nav targets
- **Regression** (`--regression <baseline>`): compare against prior baseline

**Health Score Rubric (weighted average):**
| Category | Weight |
|----------|--------|
| Console errors | 15% |
| Links | 10% |
| Visual | 10% |
| Functional | 20% |
| UX | 15% |
| Performance | 10% |
| Content | 5% |
| Accessibility | 15% |

Deductions: Critical = -25, High = -15, Medium = -8, Low = -3 per category.

**Important Rules:**
- Needs clean working tree (requires commit or stash first)
- Includes test framework bootstrap if no tests detected
- Never read source code during browser testing (test as a user)
- Show screenshots inline after every capture command

**Handoff:** Bug fix commits are atomic, each with a re-verify step. Produces baseline.json for future regression runs.

---

### `/qa-only` — Report-Only QA Testing

**Version:** 1.0.0 | **Preamble Tier:** 4 | **Caller:** Claude Code [CONFIRMED]

**Description:** Same as `/qa` but NEVER fixes anything. Produces structured report only.

**Allowed Tools:** Bash, Read, Write, AskUserQuestion, WebSearch [CONFIRMED]

**Trigger:** "just report bugs", "qa report only", "test but don't fix". Proactively suggest when user wants a bug report without code changes. [CONFIRMED]

**Same workflow as `/qa`** through all phases, except:
- No fix/commit phase
- Rule 11: Never fix bugs — report only
- Rule 12: Never refuse to use the browser

**Handoff:** Report goes to `.gstack/qa-reports/`. User then decides what to fix.

---

### `/ship` — Fully Automated Ship Workflow

**Version:** 1.0.0 | **Preamble Tier:** 4 | **Caller:** Claude Code [CONFIRMED]

**Description:** End-to-end ship workflow: detect + merge base branch, run tests, review diff, bump VERSION, update CHANGELOG, commit, push, create PR.

**Allowed Tools:** Bash, Read, Write, Edit, Grep, Glob, Agent, AskUserQuestion, WebSearch [CONFIRMED]

**Trigger:** "ship", "deploy", "push to main", "create a PR", "merge and push". Proactively suggest when user says code is ready. [CONFIRMED]

**Philosophy:** Non-interactive by default. Only stops for the conditions listed below.

**Always stops for:**
- On base branch (abort)
- Merge conflicts that can't be auto-resolved
- In-branch test failures
- Review findings with items requiring user judgment
- MINOR or MAJOR version bump needed
- AI coverage below minimum threshold
- Plan items NOT DONE with no user override

**Never stops for:**
- Uncommitted changes (always includes them)
- Version bump choice (auto-picks MICRO or PATCH)
- CHANGELOG content (auto-generates)
- Commit message approval (auto-commits)
- Multi-file changesets (auto-splits into bisectable commits)
- Auto-fixable review findings

**Key Steps:**
1. **Step 0**: Platform and base branch detection
2. **Step 1**: Pre-flight, review readiness dashboard (reads `gstack-review-read`)
3. **Step 1.5**: Distribution pipeline check for new artifacts
4. **Step 2**: Merge base branch (before tests)
5. **Step 2.5**: Test framework bootstrap (if needed)
6. **Step 3**: Run tests
7. **Step 3.4**: AI coverage assessment
8. **Step 3.45**: Plan completion audit
9. **Step 3.5**: Design review lite (for frontend changes)
10. **Step 4**: VERSION bump (auto MICRO/PATCH, ask for MINOR/MAJOR)
11. **Step 5**: CHANGELOG update (from diff + commits)
12. **Step 5.5**: TODOS.md cleanup
13. **Step 6**: Commit and push
14. **Step 7**: Create PR (GitHub: `gh pr create`, GitLab: `glab mr create`)

**Review Readiness Dashboard** (shown at Step 1):
```
+====================================================================+
|                    REVIEW READINESS DASHBOARD                       |
+====================================================================+
| Review          | Runs | Last Run            | Status    | Required |
|-----------------|------|---------------------|-----------|----------|
| Eng Review      |  1   | 2026-03-16 15:00    | CLEAR     | YES      |
| CEO Review      |  0   | —                   | —         | no       |
| Design Review   |  0   | —                   | —         | no       |
| Adversarial     |  0   | —                   | —         | no       |
+====================================================================+
```
- **Eng Review is the only required gate** (can be disabled with `gstack-config set skip_eng_review true`)
- Adversarial review auto-scales: small diffs (<50 lines) skip it; medium (50-199) get cross-model; large (200+) get all 4 passes

**Key Outputs:**
- Git commits (one per logical change)
- PR/MR created with full description
- CHANGELOG entry added
- VERSION bumped
- TODOS.md updated

**Handoff:** PR created, hands off to `/land-and-deploy` for merge+deploy.

---

### `/codex` — Multi-AI Second Opinion

**Version:** 1.0.0 | **Preamble Tier:** 3 | **Caller:** Claude Code [CONFIRMED]

**Description:** OpenAI Codex CLI wrapper in three modes: code review (pass/fail gate), challenge (adversarial), consult (session continuity).

**Allowed Tools:** Bash, Read, Write, Glob, Grep, AskUserQuestion [CONFIRMED]

**Trigger:** "codex review", "codex challenge", "ask codex", "second opinion", "consult codex" [CONFIRMED]

**Prerequisite:** Codex CLI must be installed (`npm install -g @openai/codex`). Checks via `which codex`. [CONFIRMED]

**Modes:**
1. **`/codex review`** — `codex review --base <base> -c 'model_reasoning_effort="xhigh"' --enable web_search_cached`. Gate: PASS if no [P1] findings, FAIL otherwise. Shows cross-model comparison if Claude's `/review` also ran.
2. **`/codex challenge`** — Adversarial mode. `codex exec "<adversarial prompt>" -s read-only`. Streams JSONL output showing `[codex thinking]` reasoning traces.
3. **`/codex <prompt>`** — Consult mode. Session continuity via `.context/codex-session-id`. Can resume prior sessions.

**All modes use:**
- `model_reasoning_effort="xhigh"` (maximum reasoning)
- `--enable web_search_cached` (Codex can look up docs)
- 5-minute timeout (timeout: 300000)
- Read-only sandbox (`-s read-only`)

**Key Outputs:**
- Codex output verbatim in `CODEX SAYS:` block
- Gate verdict (PASS/FAIL with [P1] marker count)
- Review log: `gstack-review-log '{"skill":"codex-review",...}'`
- Session file: `.context/codex-session-id` (for consult mode)

**Rules:**
- Never modify files (read-only skill)
- Present output verbatim — never truncate or summarize
- Claude commentary comes after the full output, not instead of it

---

### `/autoplan` — Auto-Review Pipeline

**Version:** 1.0.0 | **Preamble Tier:** 3 | **Caller:** Claude Code [CONFIRMED]

**Description:** Runs CEO, design, and eng review skills sequentially with auto-decisions using 6 decision principles. Surfaces taste decisions at a final approval gate. Benefits from `/office-hours` context.

**Allowed Tools:** Bash, Read, Write, Edit, Glob, Grep, WebSearch, AskUserQuestion [CONFIRMED]

**Trigger:** "auto review", "autoplan", "run all reviews", "review this plan automatically", "make the decisions for me". Proactively suggest when user has a plan file and wants the full review gauntlet. [CONFIRMED]

**How it works:**
- Reads all three review skill SKILL.md files from disk at runtime
- Runs plan-ceo-review, plan-eng-review, and plan-design-review sequentially
- Makes most decisions autonomously using 6 principles (auto-pick the more complete option, prefer reversible choices, etc.)
- Surfaces only genuine "taste" decisions (close aesthetic calls, borderline scope, Codex disagreements) at final gate

**Key Outputs:**
- Updated plan file with `## GSTACK REVIEW REPORT` section
- All three review logs written to `~/.gstack/analytics/`

**Handoff:** After autoplan, plan is ready for implementation via Claude Code.

---

### `/careful` — Destructive Command Guardrails

**Version:** 0.1.0 | **No preamble tier** | **Caller:** Claude Code [CONFIRMED]

**Description:** Safety mode — warns before destructive bash commands. User can override each warning.

**Allowed Tools:** Bash, Read [CONFIRMED]

**Trigger:** "be careful", "safety mode", "prod mode", "careful mode" [CONFIRMED]

**Hooks:**
```yaml
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/check-careful.sh"
          statusMessage: "Checking for destructive commands..."
```
[CONFIRMED]

**Protected Patterns:**
| Pattern | Risk |
|---------|------|
| `rm -rf` / `rm -r` / `rm --recursive` | Recursive delete |
| `DROP TABLE` / `DROP DATABASE` | Data loss |
| `TRUNCATE` | Data loss |
| `git push --force` / `-f` | History rewrite |
| `git reset --hard` | Uncommitted work loss |
| `git checkout .` / `git restore .` | Uncommitted work loss |
| `kubectl delete` | Production impact |
| `docker rm -f` / `docker system prune` | Container/image loss |

**Safe Exceptions:** `rm -rf node_modules`, `.next`, `dist`, `__pycache__`, `.cache`, `build`, `.turbo`, `coverage`

**How it works:** Hook reads the command from tool input JSON, checks patterns, returns `permissionDecision: "ask"` on match. [CONFIRMED]

**Deactivation:** End the conversation or start a new one. Hooks are session-scoped.

---

### `/freeze` — Restrict Edits to a Directory

**Version:** 0.1.0 | **No preamble tier** | **Caller:** Claude Code [CONFIRMED]

**Description:** Locks Edit and Write tools to a specific directory. Edits outside are blocked (not warned — hard deny).

**Allowed Tools:** Bash, Read, AskUserQuestion [CONFIRMED]

**Trigger:** "freeze", "restrict edits", "only edit this folder", "lock down edits" [CONFIRMED]

**Hooks:**
```yaml
hooks:
  PreToolUse:
    - matcher: "Edit"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/check-freeze.sh"
          statusMessage: "Checking freeze boundary..."
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/check-freeze.sh"
          statusMessage: "Checking freeze boundary..."
```
[CONFIRMED]

**State file:** `${CLAUDE_PLUGIN_DATA:-$HOME/.gstack}/freeze-dir.txt` — stores the frozen directory path with trailing slash. [CONFIRMED]

**Notes:**
- Trailing `/` prevents `/src` from matching `/src-old`
- Read, Bash, Glob, Grep are NOT restricted — only Edit and Write
- Not a security boundary — bash `sed` can still modify files outside the freeze

---

### `/guard` — Full Safety Mode

**Version:** 0.1.0 | **No preamble tier** | **Caller:** Claude Code [CONFIRMED]

**Description:** Combines `/careful` (destructive command warnings) and `/freeze` (directory-scoped edits) in a single activation.

**Allowed Tools:** Bash, Read, AskUserQuestion [CONFIRMED]

**Trigger:** "guard mode", "full safety", "lock it down", "maximum safety" [CONFIRMED]

**Hooks:** References sibling skill hook scripts — `../careful/bin/check-careful.sh` and `../freeze/bin/check-freeze.sh`. All three hooks registered (Bash, Edit, Write). [CONFIRMED]

**Dependency:** Requires both `/careful` and `/freeze` to be installed (installed together by gstack setup). [CONFIRMED]

---

### `/unfreeze` — Clear Freeze Boundary

**Version:** 0.1.0 | **No preamble tier** | **Caller:** Claude Code [CONFIRMED]

**Description:** Removes the edit restriction set by `/freeze`, allowing edits everywhere again.

**Allowed Tools:** Bash, Read [CONFIRMED]

**Trigger:** "unfreeze", "unlock edits", "remove freeze", "allow all edits" [CONFIRMED]

**Action:** Deletes `${CLAUDE_PLUGIN_DATA:-$HOME/.gstack}/freeze-dir.txt`. [CONFIRMED]

**Note:** `/freeze` hooks remain registered but do nothing once the state file is removed.

---

### `/cso` — Chief Security Officer Mode

**Version:** 2.0.0 | **Preamble Tier:** 2 | **Caller:** Claude Code [CONFIRMED]

**Description:** Infrastructure-first security audit. Two modes: daily (zero-noise, 8/10 confidence gate) and comprehensive (monthly deep scan, 2/10 confidence bar). Trend tracking across audit runs.

**Allowed Tools:** Bash, Read, Grep, Glob, Write, Agent, WebSearch, AskUserQuestion [CONFIRMED]

**Trigger:** "security audit", "threat model", "pentest review", "OWASP", "CSO review" [CONFIRMED]

**Audit Coverage:**
- Secrets archaeology (git history for leaked secrets)
- Dependency supply chain audit
- CI/CD pipeline security
- LLM/AI security boundaries
- Skill supply chain scanning
- OWASP Top 10
- STRIDE threat modeling
- Active verification (not just static analysis)

**Modes:**
- **Daily**: 8/10 confidence gate (zero noise — only high-confidence findings)
- **Comprehensive**: 2/10 confidence bar (monthly deep scan, surfaces everything)

**Key Outputs:**
- Security report in `.gstack/security-reports/`
- Findings logged to review dashboard

---

### `/canary` — Post-Deploy Visual Monitor

**Version:** 1.0.0 | **Preamble Tier:** 2 | **Caller:** Claude Code [CONFIRMED]

**Description:** Watches the live app for console errors, performance regressions, and page failures using the browse daemon. Alerts on anomalies vs. baselines.

**Allowed Tools:** Bash, Read, Write, Glob, AskUserQuestion [CONFIRMED]

**Trigger:** "monitor deploy", "canary", "post-deploy check", "watch production", "verify deploy" [CONFIRMED]

**Arguments:**
- `/canary <url>` — monitor for 10 minutes (default)
- `/canary <url> --duration 5m` — custom duration (1-30m)
- `/canary <url> --baseline` — capture baseline BEFORE deploying
- `/canary <url> --pages /,/dashboard` — specify pages
- `/canary <url> --quick` — single-pass health check

**Alert Levels:**
- **CRITICAL** — page load failure
- **HIGH** — new console errors vs. baseline
- **MEDIUM** — load time exceeds 2x baseline
- **LOW** — new 404s not in baseline

**Alert Logic:** Only alert on patterns persisting across 2+ consecutive checks (avoids transient noise). [CONFIRMED]

**Key Outputs:**
- `.gstack/canary-reports/{date}-canary.md`
- `.gstack/canary-reports/{date}-canary.json`
- `~/.gstack/projects/{slug}/` JSONL entry
- Screenshots in `.gstack/canary-reports/screenshots/`

**Phases:**
1. Setup (output dirs, parse args)
2. Baseline capture (`--baseline` mode) — stop after capture
3. Page discovery (auto-discover top 5 nav links)
4. Pre-deploy snapshot (if no baseline)
5. Continuous monitoring loop (every 60s)
6. Health report
7. Baseline update (offer if healthy)

---

### `/benchmark` — Performance Regression Detection

**Version:** 1.0.0 | **Preamble Tier:** 1 | **Caller:** Claude Code [CONFIRMED]

**Description:** Establishes page load baselines (TTFB, FCP, LCP, DOM metrics, bundle sizes), compares before/after on PRs, tracks trends over time.

**Allowed Tools:** Bash, Read, Write, Glob, AskUserQuestion [CONFIRMED]

**Trigger:** "performance", "benchmark", "page speed", "lighthouse", "web vitals", "bundle size", "load time" [CONFIRMED]

**Arguments:**
- `/benchmark <url>` — full audit with baseline comparison
- `/benchmark <url> --baseline` — capture baseline
- `/benchmark <url> --quick` — single-pass timing check
- `/benchmark <url> --pages /,/dashboard` — specific pages
- `/benchmark --diff` — only pages affected by current branch
- `/benchmark --trend` — show performance trends from history

**Metrics Collected:**
- TTFB (Time to First Byte)
- FCP (First Contentful Paint)
- LCP (Largest Contentful Paint)
- DOM Interactive, DOM Complete, Full Load
- Total requests, transfer size
- JS bundle size, CSS bundle size

**Regression Thresholds:**
- Timing: >50% increase OR >500ms absolute = REGRESSION; >20% = WARNING
- Bundle size: >25% increase = REGRESSION; >10% = WARNING
- Request count: >30% increase = WARNING

**Key Outputs:**
- `.gstack/benchmark-reports/{date}-benchmark.md`
- `.gstack/benchmark-reports/{date}-benchmark.json`
- `.gstack/benchmark-reports/baselines/baseline.json`

---

### `/land-and-deploy` — Merge, Deploy, Verify

**Version:** 1.0.0 | **Preamble Tier:** 4 | **Caller:** Claude Code [CONFIRMED]

**Description:** Picks up after `/ship` creates the PR. Merges it, waits for CI and deploy, verifies production health.

**Allowed Tools:** Bash, Read, Write, Glob, AskUserQuestion [CONFIRMED]

**Trigger:** "merge", "land", "deploy", "merge and verify", "land it", "ship it to production" [CONFIRMED]

**Supported Platforms:** GitHub only (GitLab: STOP with explanation). [CONFIRMED]

**Steps:**
1. **Step 1**: Pre-flight (verify `gh auth status`, detect PR)
2. **Step 2**: Pre-merge checks (CI status, merge conflicts)
3. **Step 3**: Wait for CI (15-minute timeout with `gh pr checks --watch`)
4. **Step 3.5**: Pre-merge readiness gate (critical — one confirmation before irreversible merge)
5. **Step 4**: Merge (`gh pr merge --auto --delete-branch` → fallback `--squash`)
6. **Step 5**: Deploy strategy detection (detect platform: Fly.io, Render, Vercel, Netlify, Heroku, Railway, GitHub Actions)
7. **Step 6**: Wait for deploy (per-platform strategies A-D)
8. **Step 7**: Canary verification (depth depends on diff scope: DOCS=skip, CONFIG=smoke, BACKEND=console+perf, FRONTEND=full)
9. **Step 8**: Revert option (always available via `git revert <merge-sha>`)
10. **Step 9**: Deploy report
11. **Step 10**: Suggest follow-ups (/canary, /benchmark, /document-release)

**Pre-merge readiness gate checks:**
- a. Review staleness (0 commits since review = CURRENT; 4+ = STALE)
- b. Test results (free tests + E2E from `~/.gstack-dev/evals/` + LLM judge evals)
- c. PR body accuracy (commits vs. description match)
- d. Document-release check (CHANGELOG + VERSION updated?)

**Deploy Report Format:**
```
LAND & DEPLOY REPORT
═════════════════════
PR: #NNN — title
Branch: feature → main
Merged: timestamp
Timing: CI wait / Queue / Deploy / Canary / Total
CI: PASSED | Deploy: PASSED | Verification: HEALTHY
VERDICT: DEPLOYED AND VERIFIED
```

**Key Outputs:**
- `.gstack/deploy-reports/{date}-pr{number}-deploy.md`
- JSONL entry in `~/.gstack/projects/{slug}/`
- Post-deploy screenshot: `.gstack/deploy-reports/post-deploy.png`

---

### `/document-release` — Post-Ship Documentation Update

**Version:** 1.0.0 | **Preamble Tier:** 2 | **Caller:** Claude Code [CONFIRMED]

**Description:** Runs after `/ship`. Reads all project docs, cross-references the diff, updates README/ARCHITECTURE/CONTRIBUTING/CLAUDE.md, polishes CHANGELOG voice, cleans TODOS, optionally bumps VERSION.

**Allowed Tools:** Bash, Read, Write, Edit, Grep, Glob, AskUserQuestion [CONFIRMED]

**Trigger:** "update the docs", "sync documentation", "post-ship docs". Proactively suggest after PR merge. [CONFIRMED]

**Auto-updates (no confirmation needed):**
- Factual corrections clearly from the diff
- Adding items to tables/lists
- Updating paths, counts, version numbers
- Fixing stale cross-references
- CHANGELOG voice polish (minor wording)
- Marking TODOS complete

**Never auto-updates:**
- README introduction or positioning
- ARCHITECTURE philosophy
- Security model descriptions
- Full section removal

**Critical rules:**
- **NEVER clobber CHANGELOG** — polish voice only, never replace entries. Use Edit with exact `old_string`, never Write on CHANGELOG.md
- **NEVER bump VERSION without asking** — always AskUserQuestion

**Steps:**
1. Pre-flight & diff analysis (find all .md files)
2. Per-file audit (README, ARCHITECTURE, CONTRIBUTING, CLAUDE.md, others)
3. Apply auto-updates directly
4. Ask about risky/narrative changes
5. CHANGELOG voice polish
6. Cross-doc consistency check (discoverability: every doc reachable from README or CLAUDE.md)
7. TODOS.md cleanup
8. VERSION bump question
9. Commit + push + update PR/MR body with `## Documentation` section

**Key Outputs:**
- Documentation files updated in-place
- Commit: `docs: update project documentation for vX.Y.Z.W`
- PR/MR body updated with doc diff preview

---

### `/retro` — Weekly Engineering Retrospective

**Version:** 2.0.0 | **Preamble Tier:** 2 | **Caller:** Claude Code [CONFIRMED]

**Description:** Analyzes commit history, work patterns, and code quality metrics. Team-aware: per-person contributions with praise and growth areas. Persistent history and trend tracking.

**Allowed Tools:** Bash, Read, Write, Glob, AskUserQuestion [CONFIRMED]

**Trigger:** "weekly retro", "what did we ship", "engineering retrospective". Proactively suggest at end of work week or sprint. [CONFIRMED]

**Key Analysis Areas:**
- Commit volume and velocity by author
- PR cycle time (open → merge)
- Files with most churn (potential instability)
- Test coverage trends
- Recurring bugs in same files (architectural signal)
- Completeness of work (were plans fully executed?)

**Key Outputs:**
- `~/.gstack/retros/{YYYY-WW}-retro.md` (persistent, one per week)
- Trend data from comparing to prior retros

---

### `/plan-eng-review` — Architecture & Engineering Plan Review

**Version:** 2.0.0 | **Preamble Tier:** 3 | **Caller:** Claude Code [CONFIRMED]

**Description:** Interactive engineering review of a plan file — like a senior engineer doing a design review. Rates architecture dimensions 0-10, proposes test plans, identifies missing edge cases.

**Allowed Tools:** Read, Edit, Grep, Glob, Bash, AskUserQuestion [CONFIRMED]

**Trigger:** "engineering review", "plan review", "review the plan", "arch review". Proactively suggest when user has a plan file. [CONFIRMED]

**Key Coverage:**
- Architecture and component design
- Data model and migration safety
- Test plan (generates concrete test cases)
- Performance considerations
- Security implications
- Implementation sequencing
- Missing edge cases and error states

**Key Outputs:**
- Plan file updated with eng review section
- Test plan artifact (referenced by `/qa` and `/ship`)
- Review logged to `~/.gstack/analytics/` via `gstack-review-log`

**Handoff:** Review result consumed by `/ship` readiness dashboard and `/land-and-deploy` readiness gate.

---

### `/plan-design-review` — Designer's Eye Plan Review

**Version:** 2.0.0 | **Preamble Tier:** 3 | **Caller:** Claude Code [CONFIRMED]

**Description:** Design review of a plan file (before implementation). Rates each design dimension 0-10, explains what would make it a 10, then fixes the plan. For live-site visual audits, use `/design-review`.

**Allowed Tools:** Read, Edit, Grep, Glob, Bash, AskUserQuestion [CONFIRMED]

**Trigger:** "review the design plan", "design critique". Proactively suggest when plan has UI/UX components. [CONFIRMED]

**Key Coverage:**
- Visual hierarchy and layout approach
- Color and typography decisions
- Component consistency
- Empty/loading/error states
- Accessibility
- Mobile/responsive considerations

**Key Outputs:**
- Plan file updated with design review section
- Review logged to `~/.gstack/analytics/`

---

### `/design-review` — Live Site Visual QA

**Version:** 2.0.0 | **Preamble Tier:** 4 | **Caller:** Claude Code [CONFIRMED]

**Description:** Designer's eye QA on a live site — finds visual inconsistencies, spacing issues, hierarchy problems, AI slop patterns, slow interactions, then fixes them with atomic commits.

**Allowed Tools:** Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion, WebSearch [CONFIRMED]

**Trigger:** "audit the design", "visual QA", "check if it looks good", "design polish". Proactively suggest when user mentions visual inconsistencies. [CONFIRMED]

**Key Analysis:**
- Spacing consistency (8px grid adherence)
- Color consistency (palette violations)
- Typography hierarchy (too many sizes/weights)
- AI slop patterns: purple gradients, 3-column icon grids, uniform border-radius, centered everything
- Interaction slowness (animation jank, layout shift)
- Before/after screenshots for every fix

**Key Outputs:**
- Before/after screenshots for each fix
- Atomic fix commits
- Review logged to `gstack-review-log` (design-review-lite)

---

### `/design-consultation` — Design System Creation

**Version:** 1.0.0 | **Preamble Tier:** 3 | **Caller:** Claude Code [CONFIRMED]

**Description:** Understands your product, researches the landscape (optional), proposes a complete design system, generates font+color preview HTML page, creates DESIGN.md as project design source of truth.

**Allowed Tools:** Bash, Read, Write, Edit, Glob, Grep, AskUserQuestion, WebSearch [CONFIRMED]

**Trigger:** "design system", "brand guidelines", "create DESIGN.md". Proactively suggest when starting a new project's UI with no DESIGN.md. [CONFIRMED]

**Phases:**
1. **Pre-checks** — look for existing DESIGN.md, gather product context from codebase, find office-hours output
2. **Product context** — single AskUserQuestion covering product type, research preference
3. **Research** (if user says yes) — WebSearch + browse 3-5 competitor sites; 3-layer synthesis (tried-and-true / new-and-popular / first-principles)
4. **Outside voices** (optional) — Codex design voice + Claude subagent design voice simultaneously
5. **Complete proposal** — aesthetic direction, color, typography, spacing, layout, motion; SAFE vs RISK breakdown
6. **Drill-downs** — if user wants adjustments to specific sections
7. **Preview page** — single self-contained HTML with font specimens, color swatches, realistic product mockups, light/dark toggle
8. **Write DESIGN.md + update CLAUDE.md**

**Anti-slop rules:** Never recommend purple/violet gradients, 3-column icon grids, centered everything, uniform bubbly border-radius, gradient buttons. [CONFIRMED]

**Never recommend these fonts as primary:** Inter, Roboto, Arial, Helvetica, Open Sans, Lato, Montserrat, Poppins. [CONFIRMED]

**Key Outputs:**
- `DESIGN.md` in repo root
- `/tmp/design-consultation-preview-{timestamp}.html` (opened in browser)
- `CLAUDE.md` updated with `## Design System` section

---

### `/investigate` — Systematic Debugging

**Version:** 1.0.0 | **Preamble Tier:** 2 | **Caller:** Claude Code [CONFIRMED]

**Description:** Four-phase systematic debugging with Iron Law: no fixes without root cause investigation first.

**Allowed Tools:** Bash, Read, Write, Edit, Grep, Glob, AskUserQuestion, WebSearch [CONFIRMED]

**Trigger:** "debug this", "fix this bug", "why is this broken", "investigate this error", "root cause analysis". Proactively suggest when user reports errors. [CONFIRMED]

**Hooks:**
```yaml
hooks:
  PreToolUse:
    - matcher: "Edit"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/../freeze/bin/check-freeze.sh"
          statusMessage: "Checking debug scope boundary..."
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/../freeze/bin/check-freeze.sh"
          statusMessage: "Checking debug scope boundary..."
```
[CONFIRMED] — Uses freeze's check-freeze.sh to scope lock edits to affected module.

**Iron Law:** NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST. [CONFIRMED]

**Phases:**
1. **Root Cause Investigation** — collect symptoms, read code, check recent changes, reproduce
2. **Pattern Analysis** — match against: race conditions, nil propagation, state corruption, integration failure, configuration drift, stale cache
3. **Hypothesis Testing** — verify before fixing; 3-strike rule (3 failures → stop, ask user)
4. **Implementation** — smallest fix for root cause; regression test (fails without fix, passes with fix); if >5 files touched → AskUserQuestion about blast radius
5. **Verification & Report** — reproduce bug scenario, run test suite, produce DEBUG REPORT

**Scope Lock:** Auto-sets freeze boundary to narrowest affected directory after forming root cause hypothesis. [CONFIRMED]

**Output Format:**
```
DEBUG REPORT
════════════════════════════
Symptom:         [observed]
Root cause:      [actual problem]
Fix:             [files:lines changed]
Evidence:        [test output]
Regression test: [file:line]
Related:         [TODOS, prior bugs, arch notes]
Status:          DONE | DONE_WITH_CONCERNS | BLOCKED
```

---

### `/office-hours` — [Large Skill — Summary Only]

**Preamble Tier:** Not specified in available preview | **Caller:** Claude Code [INFERRED]

**Description:** Office hours / product consultation skill. Helps define product direction, strategy, and decisions before planning. Likely produces structured output consumed by `/design-consultation` (which checks for `office-hours` output in `.context/` and `~/.gstack/projects/{slug}/`). [INFERRED from references in design-consultation]

**Key Outputs:** `*-office-hours-*.md` files in `~/.gstack/projects/{slug}/` or `.context/` [CONFIRMED from design-consultation references]

---

### `/plan-ceo-review` — [Large Skill — Summary Only]

**Preamble Tier:** Not specified in available preview | **Caller:** Claude Code [INFERRED]

**Description:** CEO-perspective plan review. Covers scope & strategy, business value, user impact. Optional (never gates shipping). Produces scope proposals (accepted/deferred). [CONFIRMED from review dashboard references]

**Review Log Fields:** `status`, `unresolved`, `critical_gaps`, `mode`, `scope_proposed`, `scope_accepted`, `scope_deferred`, `commit` [CONFIRMED from codex skill's review report generation]

---

## Section 4: Skill Interaction Map

```
/office-hours ──────┐
                    ▼
/plan-ceo-review ───┐
/plan-eng-review ───┼──▶ /autoplan ──▶ [plan ready]
/plan-design-review─┘
                    │
                    ▼ (plan → implementation)
             [Claude Code implements]
                    │
                    ▼
/review ────────────┐
/codex review ──────┼──▶ /ship ──────▶ [PR created]
/design-review ─────┘         │
                               ▼
                    /document-release
                               │
                               ▼
                    /land-and-deploy ──▶ [merged + deployed]
                               │
                    ┌──────────┴──────────┐
                    ▼                     ▼
                /canary              /benchmark
```

**QA can run at any point during development:**
```
/qa-only ──▶ [report only — no fixes]
/qa     ──▶ [test → fix → commit → re-verify loop]
```

**Safety skills (session-scoped):**
```
/careful ──▶ /unfreeze (not needed, just end session)
/freeze  ──▶ /unfreeze
/guard   ──▶ /unfreeze (removes freeze; careful stays until session ends)
```

---

## Section 5: Review Log System

Skills write results to a shared JSONL store via `gstack-review-log`. [CONFIRMED]

**Read command:** `~/.claude/skills/gstack/bin/gstack-review-read` [CONFIRMED]

**JSONL fields by skill:**

| Skill | Key Fields |
|-------|-----------|
| `plan-ceo-review` | status, unresolved, critical_gaps, mode, scope_proposed, scope_accepted, scope_deferred, commit |
| `plan-eng-review` | status, unresolved, critical_gaps, issues_found, mode, commit |
| `plan-design-review` | status, initial_score, overall_score, unresolved, decisions_made, commit |
| `codex-review` | status, gate, findings, findings_fixed |
| `design-review-lite` | status, commit |
| `review` | status, commit |

**Staleness detection:** Compare stored `commit` field vs current HEAD via `git rev-list --count STORED_COMMIT..HEAD`. 0 = CURRENT, 1-3 = RECENT, 4+ = STALE, missing = NOT RUN. [CONFIRMED from ship skill]

---

## Section 6: Analytics Files

| File | Purpose |
|------|---------|
| `~/.gstack/analytics/skill-usage.jsonl` | Per-skill invocation log |
| `~/.gstack/analytics/eureka.jsonl` | First-principles insights |
| `~/.gstack/analytics/.pending-{session}` | In-progress session markers |
| `~/.gstack/sessions/{PPID}` | Active session tracking (2h TTL) |
| `~/.gstack/contributor-logs/{slug}.md` | Contributor bug reports |
| `~/.gstack/projects/{slug}/` | Per-project cross-session context |
| `~/.gstack/.proactive-prompted` | One-time flag |
| `~/.gstack/.telemetry-prompted` | One-time flag |
| `~/.gstack/.completeness-intro-seen` | One-time flag |
| `~/.gstack/freeze-dir.txt` | Freeze state (or `$CLAUDE_PLUGIN_DATA/freeze-dir.txt`) |

---

## Section 7: SKILL.md Template System

Files are auto-generated from `SKILL.md.tmpl`. [CONFIRMED — comment at top of every file]

Regenerate: `bun run gen:skill-docs` [CONFIRMED]

Skills without a `preamble-tier` field (careful, freeze, guard, unfreeze) are lightweight safety tools with no standard preamble boilerplate. [INFERRED]

The `benefits-from: [office-hours]` field on `/autoplan` indicates optional dependencies between skills. [CONFIRMED]
