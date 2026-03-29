# UI_SKILL_SPEC.md — AVNER v8 Reference Document
# Phase C: GSD UI + AVNER UI Skill Specification

> **Sources**: `avner-stack/skills/ui/SKILL.md`, `avner-stack/skills/ui-review/SKILL.md`,
> `avner-stack/vendor/gsd/agents/gsd-ui-researcher.md`, `gsd-ui-checker.md`, `gsd-ui-auditor.md`,
> `avner-stack/vendor/gsd/get-shit-done/workflows/ui-phase.md`, `ui-review.md`,
> `avner-stack/vendor/gsd/get-shit-done/templates/UI-SPEC.md`,
> `avner-stack/vendor/gsd/get-shit-done/references/ui-brand.md`
>
> **Annotation key**: [CONFIRMED] = directly read in source files · [INFERRED] = reasoned from multiple sources · [MISSING] = not found, proposed for v8

---

## Table of Contents

1. [Design Contract Questions — What Must Be Answered](#1-design-contract-questions)
2. [Canonical `/ui` SKILL.md for AVNER v8](#2-canonical-ui-skillmd)
3. [Canonical `/ui-review` SKILL.md for AVNER v8](#3-canonical-ui-review-skillmd)
4. [Full Canonical UI_SPEC.md Format](#4-canonical-ui_specmd-format)
5. [Full Canonical UI_REVIEW.md Format](#5-canonical-ui_reviewmd-format)
6. [6-Pillar Scoring Scheme — Complete Reference](#6-6-pillar-scoring-scheme)
7. [UI Work → Business Requirements Traceability](#7-ui-business-traceability)
8. [GSD vs AVNER Comparison Notes](#8-gsd-vs-avner-comparison)

---

## 1. Design Contract Questions

These questions MUST be answered before any UI work begins. [CONFIRMED]

### 1a. Scope Questions (asked of the user)

| # | Question | Why It Matters |
|---|----------|----------------|
| 1 | Which feature/task is in scope? | Prevents gold-plating and scope creep |
| 2 | Which UI surfaces are affected (screens, modals, flows)? | Defines the audit boundary |
| 3 | Which R-ids from REQUIREMENTS.md does this satisfy? | Ties UI to business requirements |

If the user is unsure of scope, run the **Six Forcing Questions** (from GSD office-hours): [CONFIRMED]

1. **Demand Reality**: What's the strongest evidence someone wants this?
2. **Status Quo**: What are users doing right now to solve this?
3. **Desperate Specificity**: Name the actual human who needs this most.
4. **Narrowest Wedge**: What's the smallest version someone would use — this week?
5. **Observation**: Have you watched someone try to do this without help?
6. **Future-Fit**: In 3 years, does this become more essential or less?

### 1b. Design System Detection Questions

Scan the codebase first. Only ask what isn't already answerable: [CONFIRMED]

```bash
# Detect design system state
ls components.json tailwind.config.* postcss.config.* 2>/dev/null
grep -r "spacing\|fontSize\|colors\|fontFamily" tailwind.config.* 2>/dev/null
find src -name "*.tsx" -path "*/components/*" 2>/dev/null | head -20
test -f components.json && npx shadcn info 2>/dev/null
```

If no design system found, ask:

| # | Question | Options |
|---|----------|---------|
| 4 | Component library? | shadcn/ui, Radix, MUI, Headless UI, custom |
| 5 | Color palette direction? | Light/dark preference, brand colors available? |
| 6 | Typography preference? | System font vs custom (e.g. Inter, Geist) |

### 1c. Per-Screen Contract Questions

For each in-scope screen, the spec MUST define: [CONFIRMED]

| # | Contract Item | What to Specify |
|---|--------------|-----------------|
| 7 | Layout zones | Header / sidebar / main / footer hierarchy |
| 8 | Default state | What the user sees on first load |
| 9 | Loading state | Skeleton / spinner / progressive / none |
| 10 | Error state | Inline / toast / full-page + copy |
| 11 | Empty state | Illustration + CTA / minimal text + copy |
| 12 | Disabled state | Which elements, under what conditions |
| 13 | Primary CTA | Verb + object (never generic) |
| 14 | Empty state copy | What's missing + how to fix |
| 15 | Error copy | What went wrong + what to do |
| 16 | Destructive confirm copy | Consequence + action |
| 17 | Components | Library + variants to use |
| 18 | Accessibility | Keyboard nav, screen reader labels, contrast |
| 19 | Responsive breakpoints | Layout shifts per viewport |

---

## 2. Canonical `/ui` SKILL.md

> Ready-to-use. Drop in `.claude/skills/ui/SKILL.md` for any AVNER v8 project.

```markdown
---
name: ui
description: Create or update .avner/3_contracts/UI_SPEC.md before UI work.
invocation: manual
model: sonnet
---

# /ui — UI Design Contract

Create or update the UI design contract before implementing UI changes.
This ensures all screens have defined states, copy, layout, and pillar compliance.

## Preconditions
- `.avner/1_vision/REQUIREMENTS.md` must exist. If missing, tell the user to run onboarding.
- Run this BEFORE `/new` or `/one-flow` executes UI changes.
- If `.avner/3_contracts/UI_SPEC.md` already has sections for in-scope screens,
  confirm with the user whether to update or skip.

## When Invoked

### Step 1: Scope
Ask the user:
- Which feature/task is in scope?
- Which UI surfaces are affected (screens, modals, flows)?
- Which R-ids from REQUIREMENTS.md does this deliver?

If user is unsure of need, run the Six Forcing Questions:
1. Demand Reality — strongest evidence someone wants this?
2. Status Quo — what are users doing right now without this?
3. Desperate Specificity — name one real human who needs this most.
4. Narrowest Wedge — smallest version someone would actually use this week?
5. Observation — have you watched someone try to do this without help?
6. Future-Fit — in 3 years, more essential or less?

Push once on each answer. First answers are polished; real answers come after follow-up.

### Step 2: Load Context
- Read `.avner/1_vision/REQUIREMENTS.md` — extract relevant R-ids.
- Read `.avner/2_architecture/ARCHITECTURE.md` — understand component structure.
- Read `.avner/3_contracts/UI_SPEC.md` if it exists — check what's already defined.
- Read `.avner/2_architecture/TECHSTACK.md` — detect component library, design tokens.

### Step 3: Detect Design System State

Scan the codebase before asking:
```bash
ls components.json tailwind.config.* postcss.config.* 2>/dev/null
grep -r "spacing\|fontSize\|colors\|fontFamily" tailwind.config.* 2>/dev/null
find src -name "*.tsx" -path "*/components/*" 2>/dev/null | head -20
test -f components.json && npx shadcn info 2>/dev/null
```

If **no design system detected** and project is React/Next.js/Vite:
Recommend shadcn/ui initialization. Ask: "Initialize shadcn now? [Y/n]"
- If Y: instruct user to configure preset at ui.shadcn.com/create, then `npx shadcn init`.
- If N: document "custom design system" in spec.

If design system **already exists**: extract tokens and confirm with user
(don't re-ask what's already answerable from code).

### Step 4: Build Spec Sections

For each in-scope screen, create or update a section in UI_SPEC.md:

**Per screen (all items are mandatory):**
1. **Screen name and description**
2. **Related R-ids** (from REQUIREMENTS.md)
3. **Layout** — zones (header/sidebar/main/footer), hierarchy, key components
4. **States** — all 5 are mandatory:
   - Default: what the user sees on first load
   - Loading: skeleton / spinner / progressive
   - Error: inline / toast / full-page + copy
   - Empty: illustration + CTA / minimal text + copy
   - Disabled: which elements, when, why
5. **Copy** — all 4 are mandatory:
   - Primary CTA: verb + object, NEVER generic "Submit", "OK", "Save"
   - Empty state: [what's missing] + [how to fix]
   - Error state: [what went wrong] + [what to do]
   - Destructive confirmation: [consequence] + [action name]
6. **Components and variants** — library name + specific variants
7. **Accessibility** — keyboard nav, screen reader labels, WCAG contrast level
8. **Responsive** — breakpoints (mobile/tablet/desktop), layout shifts

### Step 5: Validate — 6-Pillar Checker

Before finishing, check the spec against all 6 pillars:

| # | Pillar | Pass Criteria |
|---|--------|---------------|
| 1 | Copywriting | No generic labels ("Submit", "Click here"). All states have copy. CTAs are verb+noun. |
| 2 | Visuals | Focal point declared. Visual hierarchy explicit. Icons have accessible labels. |
| 3 | Color | 60/30/10 split declared. Accent reserved for specific elements (never "all interactive"). |
| 4 | Typography | Max 4 font sizes. Max 2 font weights. Roles defined (body/label/heading/display). |
| 5 | Spacing | All values multiples of 4. Token scale used. No arbitrary px values. |
| 6 | Experience Design | All 5 states (default/loading/error/empty/disabled) defined per screen. |

If any pillar has gaps → fix them before marking the spec complete.
If checker returns BLOCK → do not proceed to implementation.

### Step 6: Write

- Open or create `.avner/3_contracts/UI_SPEC.md`.
- Add or update sections for in-scope screens.
- Ensure clear mapping: R-ids → screens → states.
- Update the Checker Sign-Off section at the bottom.

**DNA Safety Rule**: `.avner/3_contracts/UI_SPEC.md` is a contract file.
Show the user the proposed changes and get approval before writing.

### Output

Confirm to the user:
- Which screens were added/updated.
- Which R-ids are now covered.
- Any design decisions that need human input (flag as open questions).
- Next step: "UI_SPEC is ready. Proceed with /new or /one-flow to implement."

## Parsing Rules (R-ids from REQUIREMENTS.md)

R-ids are in the format `R1`, `R2`, etc. from the V1 table in REQUIREMENTS.md.
When referencing R-ids in UI_SPEC.md, use exact IDs as they appear in that table.
```

---

## 3. Canonical `/ui-review` SKILL.md

> Ready-to-use. Drop in `.claude/skills/ui-review/SKILL.md` for any AVNER v8 project.

```markdown
---
name: ui-review
description: Review implemented UI against UI_SPEC and record pillar scores + top fixes.
invocation: manual
model: sonnet
---

# /ui-review — 6-Pillar UI Audit

Retroactive visual audit of implemented UI. Compares code to UI_SPEC.md,
scores 6 pillars, and records findings in UI_REVIEW.md.

## Preconditions
- `.avner/3_contracts/UI_SPEC.md` must exist. If missing, tell the user to run `/ui` first.
- `.avner/1_vision/REQUIREMENTS.md` must exist for R-id traceability.

## When Invoked

### Step 1: Scope
Ask the user:
- Which screens/flows to audit?
- Input mode (pick one):
  - Screenshots or live URLs (if dev server running at localhost:3000 / :5173 / :8080)
  - Detailed textual description of current UI
  - "Code-only audit" (inspects source, no visual)

### Step 2: Load Spec
- Read `.avner/3_contracts/UI_SPEC.md` — load the design contract for in-scope screens.
- Read `.avner/1_vision/REQUIREMENTS.md` — understand which R-ids apply.

### Step 3: Audit Method

**If screenshots/URLs provided:**
- Compare visual output to spec definitions.
- Check each state (default, loading, error, empty, disabled) visually.
- Take desktop (1440px), tablet (768px), and mobile (375px) views if possible.

**If code-only mode:**
- Locate UI components related to in-scope screens via glob/grep.
- Run targeted scans:

```bash
# Generic labels (Pillar 1)
grep -rn "\"Submit\"\|\"Click here\"\|\"OK\"\|\"Cancel\"\|\"Save\"" src --include="*.tsx" --include="*.jsx"

# Missing states (Pillar 6)
grep -rn "loading\|isLoading\|skeleton\|Spinner" src --include="*.tsx" --include="*.jsx"
grep -rn "error\|isError\|ErrorBoundary" src --include="*.tsx" --include="*.jsx"
grep -rn "empty\|isEmpty\|length === 0" src --include="*.tsx" --include="*.jsx"

# Hardcoded colors (Pillar 3)
grep -rn "#[0-9a-fA-F]\{3,8\}\|rgb(" src --include="*.tsx" --include="*.jsx"

# Spacing violations (Pillar 5)
grep -rn "\[.*px\]\|\[.*rem\]" src --include="*.tsx" --include="*.jsx"

# Typography violations (Pillar 4)
grep -rohn "text-\(xs\|sm\|base\|lg\|xl\|2xl\|3xl\|4xl\|5xl\)" src --include="*.tsx" --include="*.jsx" | sort -u
grep -rohn "font-\(thin\|light\|normal\|medium\|semibold\|bold\|extrabold\)" src --include="*.tsx" --include="*.jsx" | sort -u
```

### Step 4: Score 6 Pillars

Rate each pillar 1–4:
- **4** — Production-ready, no issues found
- **3** — Minor polish needed (1-2 small issues)
- **2** — Several gaps, needs work before ship
- **1** — Major issues, not shippable

| # | Pillar | What to Check |
|---|--------|---------------|
| 1 | **Copywriting** | Generic labels? Empty/error copy present and specific? CTAs verb+object? Destructive confirm specific? |
| 2 | **Visuals** | Clear focal point? Visual hierarchy matches spec? Icon-only elements have aria-labels? |
| 3 | **Color** | 60/30/10 discipline? Accent only on declared elements? No hardcoded hex/rgb outside tokens? |
| 4 | **Typography** | ≤4 font sizes? ≤2 weights? Consistent role usage (body/label/heading/display)? |
| 5 | **Spacing** | All values multiples of 4? Token scale used? No arbitrary `[Npx]` values? Grid alignment? |
| 6 | **Experience Design** | All 5 states present? Disabled states handled? Loading indicators? Destructive confirmation? |

For each pillar, provide:
- Score (1–4)
- Brief rationale (what's good, what's missing)
- Specific file:line references where issues found

### Step 5: Top 3 Fixes

Identify the 3 highest-impact improvements. Format:

| # | Pillar | Description | Related R-ids | Suggested Next Step |
|---|--------|-------------|---------------|---------------------|
| 1 | [pillar] | [what to fix — specific] | [R-ids] | [concrete action] |
| 2 | [pillar] | [what to fix — specific] | [R-ids] | [concrete action] |
| 3 | [pillar] | [what to fix — specific] | [R-ids] | [concrete action] |

Fixes must be specific: "Change button label from 'Submit' to 'Create Project'" not "improve labels".

### Step 6: Record

Append a new entry to `.avner/4_operations/UI_REVIEW.md`:
- Date and reviewer (human / Claude)
- Scope (screens/flows audited)
- 6-pillar scores table with rationale
- Top 3 fixes table
- Remaining risk and tradeoffs
- Registry audit results (if shadcn + third-party blocks present)

**DNA Safety Rule**: `.avner/4_operations/UI_REVIEW.md` is protected.
Show the user the proposed entry and get approval before writing.

### Step 7: Suggest Tasks

For each of the top 3 fixes, suggest:
- Open as a new task (TASK-XX in STATE.md)
- Bundle into current work
- Defer to backlog with rationale

Map each fix to the relevant R-ids from REQUIREMENTS.md.
```

---

## 4. Canonical UI_SPEC.md Format

> This is the exact file format for `.avner/3_contracts/UI_SPEC.md`.
> Generated by `/ui` skill. Consumed by `/one-flow` Step 4 and `/ui-review`.

```markdown
---
status: draft | approved
reviewed_at: YYYY-MM-DD | pending
---

# UI Spec — [PROJECT_NAME]

This is the UI design contract. Update before UI-heavy work via `/ui`.
Audit implementation via `/ui-review`.

---

## Design System

| Property | Value |
|----------|-------|
| Component library | [shadcn/ui / Radix / MUI / Headless UI / custom] |
| shadcn preset | [preset string / not applicable] |
| Icon set | [Lucide / Heroicons / custom] |
| Font | [Inter / Geist / system-ui / custom] |
| Tailwind config | [path to tailwind.config.ts] |

---

## Spacing Scale (4-point grid — all values must be multiples of 4)

| Token | Value | Usage |
|-------|-------|-------|
| xs | 4px | Icon gaps, tight inline padding |
| sm | 8px | Related element gaps, compact spacing |
| md | 16px | Default section padding |
| lg | 24px | Card padding, section internal margins |
| xl | 32px | Section margins, layout gaps |
| 2xl | 48px | Major page sections |
| 3xl | 64px | Hero spacing, full-page sections |

Exceptions: [list any non-4-multiple values and their justification, or "none"]

---

## Typography (max 4 sizes, max 2 weights)

| Role | Size | Weight | Line Height | Usage |
|------|------|--------|-------------|-------|
| Body | 14–16px | 400 | 1.5 | Paragraphs, descriptions |
| Label | 12–14px | 500 | 1.4 | Form labels, captions, secondary info |
| Heading | 20–24px | 600 | 1.2 | Section headers, card titles |
| Display | 32–48px | 700 | 1.1 | Page titles, hero text |

---

## Color System (60/30/10)

| Role | Proportion | Value | Usage |
|------|-----------|-------|-------|
| Dominant | 60% | [hex] | Backgrounds, page surface, panels |
| Secondary | 30% | [hex] | Text, borders, cards, sidebar |
| Accent | 10% | [hex] | [LIST EXACT ELEMENTS — never "all interactive"] |
| Destructive | — | [hex] | Delete actions, error states only |

**Accent is reserved for**: [exact list — e.g., "primary CTA button, active nav item, focus ring, selected state"]

---

## Copywriting Contract

| Pattern | Template | Concrete Example |
|---------|----------|-----------------|
| Primary CTA | [verb] + [object] | "Create project" / "Send message" |
| Secondary CTA | [verb] | "Cancel" / "Go back" |
| Empty state heading | [what's missing] | "No projects yet" |
| Empty state body | [what's missing] + [how to fix] | "No projects yet. Create your first one to get started." |
| Error state | [what went wrong] + [what to do] | "Could not save. Check your connection and try again." |
| Destructive confirm | [consequence] + [action] | "This will permanently delete all project data. Delete project?" |

---

## Screens

<!-- One section per screen. Add more as needed. -->

### [Screen Name]

- **Description**: [What this screen does and when the user sees it]
- **Related R-ids**: [R1, R2]
- **Layout**:
  - Zones: [header / sidebar / main content / footer]
  - Hierarchy: [primary focus element] → [secondary] → [tertiary]
  - Key components: [list components used in this screen]
- **States**:
  - **Default**: [what the user sees on successful load]
  - **Loading**: [skeleton / spinner / progressive reveal — which elements]
  - **Error**: [inline / toast / full-page — copy: "X went wrong. Y to fix."]
  - **Empty**: [illustration? / minimal text — copy: "Nothing yet. Do X to start."]
  - **Disabled**: [which elements, when disabled, visual indicator]
- **Copy**:
  - Primary CTA: "[Specific verb + noun]"
  - Empty state: "[Specific message]"
  - Error: "[Specific message + action]"
  - Destructive confirm: "[Consequence + action label]"
- **Components**: [List with variants — e.g., "Button (primary, destructive), Card, Input (text, error state)"]
- **Accessibility**:
  - Keyboard nav: [tab order, focus trapping for modals]
  - Screen reader: [aria-labels for icon-only buttons, live regions for dynamic content]
  - Contrast: [WCAG AA minimum — 4.5:1 for body text]
- **Responsive**:
  - Mobile (< 768px): [layout shift description]
  - Tablet (768–1024px): [layout shift description]
  - Desktop (> 1024px): [default layout]

---

## Registry Safety (shadcn only — skip if not using shadcn)

| Registry | Blocks Used | Safety Gate |
|----------|-------------|-------------|
| shadcn official | [list blocks] | not required |
| [third-party name] | [list blocks] | view passed — no flags — [YYYY-MM-DD] |

---

## Checker Sign-Off

- [ ] Pillar 1 Copywriting: no generic labels, all states have specific copy
- [ ] Pillar 2 Visuals: focal point declared, hierarchy explicit, icons labeled
- [ ] Pillar 3 Color: 60/30/10 declared, accent elements listed specifically
- [ ] Pillar 4 Typography: max 4 sizes, max 2 weights, roles defined
- [ ] Pillar 5 Spacing: all values multiples of 4, token scale used
- [ ] Pillar 6 Experience Design: all 5 states defined per screen
```

---

## 5. Canonical UI_REVIEW.md Format

> This is the exact file format for `.avner/4_operations/UI_REVIEW.md`.
> Append an entry after each `/ui-review` audit. Never delete previous entries.

```markdown
# UI Review Log — [PROJECT_NAME]

Append an entry after each `/ui-review` audit. Do not delete previous entries.
Managed by: `/ui-review` skill. Protected by DNA Safety Rule.

---

## Review: [YYYY-MM-DD]

- **Reviewer**: [human name / Claude]
- **Scope**: [screens/flows audited — list specifically]
- **Audit method**: [screenshots at localhost:3000 / code-only / textual description]
- **Baseline**: [UI_SPEC.md revision / abstract 6-pillar standards]

### 6-Pillar Scores

| # | Pillar | Score (1–4) | Key Finding |
|---|--------|-------------|-------------|
| 1 | Copywriting | [1-4] | [one-line summary of finding] |
| 2 | Visuals | [1-4] | [one-line summary] |
| 3 | Color | [1-4] | [one-line summary] |
| 4 | Typography | [1-4] | [one-line summary] |
| 5 | Spacing | [1-4] | [one-line summary] |
| 6 | Experience Design | [1-4] | [one-line summary] |

**Overall: [total]/24**

**Scoring guide**:
- 4 = Production-ready, no issues
- 3 = Minor polish needed
- 2 = Several gaps, needs work
- 1 = Major issues, not shippable

### Detailed Findings

#### Pillar 1: Copywriting ([score]/4)
[Findings with file:line references for any issues]

#### Pillar 2: Visuals ([score]/4)
[Findings]

#### Pillar 3: Color ([score]/4)
[Findings with class usage counts and hardcoded color refs]

#### Pillar 4: Typography ([score]/4)
[Findings with size/weight distribution]

#### Pillar 5: Spacing ([score]/4)
[Findings with spacing class analysis, arbitrary value list]

#### Pillar 6: Experience Design ([score]/4)
[Findings with state coverage analysis — which states are missing]

### Top 3 Priority Fixes

| # | Pillar | Description | Related R-ids | Suggested Next Step |
|---|--------|-------------|---------------|---------------------|
| 1 | [pillar] | [specific issue] | [R-ids] | [concrete action] |
| 2 | [pillar] | [specific issue] | [R-ids] | [concrete action] |
| 3 | [pillar] | [specific issue] | [R-ids] | [concrete action] |

### Task Recommendations

| Fix # | Recommended Action | Task ID (if created) |
|-------|-------------------|----------------------|
| 1 | [Open as TASK-XX / Bundle into current / Defer: reason] | [TASK-XX or —] |
| 2 | [Open as TASK-XX / Bundle / Defer] | [TASK-XX or —] |
| 3 | [Open as TASK-XX / Bundle / Defer] | [TASK-XX or —] |

### Remaining Risk & Tradeoffs

- [Known issues accepted for this release and why]
- [Areas not audited and why (e.g., "no dev server available — code-only audit")]
- [Registry audit: N third-party blocks checked, [no flags / flags — see above]]

---
```

---

## 6. 6-Pillar Scoring Scheme — Complete Reference

[CONFIRMED from `skills/ui/SKILL.md`, `skills/ui-review/SKILL.md`, `vendor/gsd/agents/gsd-ui-checker.md`, `gsd-ui-auditor.md`]

### Scoring Scale

| Score | Label | Definition |
|-------|-------|------------|
| 4 | Production-ready | No issues found. Meets or exceeds contract. |
| 3 | Minor polish | 1–2 small issues. Contract substantially met. |
| 2 | Needs work | Notable gaps. Contract partially met. |
| 1 | Not shippable | Major issues. Contract not met. |

### Pillar 1: Copywriting

**What it measures**: All user-facing text is specific, actionable, and contextual.

**Spec-phase check (AVNER /ui)**:
- No CTA label is "Submit", "OK", "Click Here", "Cancel", "Save" (generic)
- Empty state copy is present and specific ("No projects yet. Create your first one.")
- Error state copy is present and includes a solution path
- Destructive confirmation is specific about consequence

**Audit-phase check (AVNER /ui-review)**:
```bash
grep -rn "\"Submit\"\|\"Click here\"\|\"OK\"\|\"Cancel\"\|\"Save\"" src --include="*.tsx" --include="*.jsx"
grep -rn "No data\|No results\|Nothing here" src --include="*.tsx" --include="*.jsx"
grep -rn "went wrong\|try again\|error occurred" src --include="*.tsx" --include="*.jsx"
```

**BLOCK conditions (from GSD gsd-ui-checker)**: [CONFIRMED]
- CTA is any of: Submit, OK, Click Here, Cancel, Save
- Empty state is missing or says "No data found" / "No results" / "Nothing here"
- Error state has no solution path (just "Something went wrong")

**FLAG conditions**:
- Destructive action has no confirmation approach
- CTA is a single word without a noun (e.g. "Create" instead of "Create Project")

### Pillar 2: Visuals

**What it measures**: Clear focal point, visual hierarchy, accessible icons.

**Spec-phase check**:
- Focal point declared for primary screen
- Visual hierarchy described (what draws eye first/second/third)
- Icon-only buttons have label fallback specified

**Audit-phase check**:
- Is there a clear primary visual anchor?
- Are icon-only buttons paired with aria-labels or tooltips?
- Does visual hierarchy match spec?

**BLOCK conditions**: [MISSING — not defined in GSD checker; proposed for v8]
- No focal point declared AND no visual hierarchy described

**FLAG conditions**: [CONFIRMED]
- No focal point declared for primary screen
- Icon-only actions declared without label fallback

### Pillar 3: Color

**What it measures**: 60/30/10 discipline, accent constraint, no hardcoded values.

**Spec-phase check**:
- 60/30/10 split explicitly declared with hex values
- Accent reserved-for list is specific (never "all interactive elements")
- Destructive color declared when destructive actions exist

**Audit-phase check**:
```bash
# Count accent usage
grep -rn "text-primary\|bg-primary\|border-primary" src --include="*.tsx" --include="*.jsx" | wc -l
# Check for hardcoded colors
grep -rn "#[0-9a-fA-F]\{3,8\}\|rgb(" src --include="*.tsx" --include="*.jsx"
```

**BLOCK conditions**: [CONFIRMED]
- Accent reserved-for list is empty or says "all interactive elements"
- More than one accent color declared without semantic justification

**FLAG conditions**: [CONFIRMED]
- 60/30/10 split not explicitly declared
- No destructive color declared when destructive actions exist in copy contract

### Pillar 4: Typography

**What it measures**: Type scale is constrained to prevent visual noise.

**Spec-phase check**:
- Maximum 4 font sizes declared
- Maximum 2 font weights declared
- Roles defined (body / label / heading / display)
- Line height declared for body text

**Audit-phase check**:
```bash
grep -rohn "text-\(xs\|sm\|base\|lg\|xl\|2xl\|3xl\|4xl\|5xl\)" src --include="*.tsx" --include="*.jsx" | sort -u
grep -rohn "font-\(thin\|light\|normal\|medium\|semibold\|bold\|extrabold\)" src --include="*.tsx" --include="*.jsx" | sort -u
```

**BLOCK conditions**: [CONFIRMED]
- More than 4 font sizes in use
- More than 2 font weights in use

**FLAG conditions**: [CONFIRMED]
- No line height declared for body text
- Font sizes are not in a clear hierarchical scale (e.g., 14, 15, 16 are too close)

### Pillar 5: Spacing

**What it measures**: All spacing is on a 4-point grid, using token scale.

**Spec-phase check**:
- All declared spacing values are multiples of 4
- Token names are used (xs/sm/md/lg/xl/2xl/3xl)
- No arbitrary px values without justification

**Audit-phase check**:
```bash
grep -rohn "p-\|px-\|py-\|m-\|mx-\|my-\|gap-\|space-" src --include="*.tsx" --include="*.jsx" | sort | uniq -c | sort -rn | head -20
grep -rn "\[.*px\]\|\[.*rem\]" src --include="*.tsx" --include="*.jsx"
```

**BLOCK conditions**: [CONFIRMED]
- Any spacing value that is not a multiple of 4
- Spacing scale contains values outside the standard set (4, 8, 16, 24, 32, 48, 64)

**FLAG conditions**: [CONFIRMED]
- Spacing scale not confirmed (section empty or says "default")
- Exceptions declared without justification

### Pillar 6: Experience Design

**What it measures**: All 5 interaction states are present, interactions are intentional.

**The 5 mandatory states**: [CONFIRMED]
1. Default — what the user sees on first load
2. Loading — skeleton / spinner / progressive reveal
3. Error — inline / toast / full-page
4. Empty — illustration + CTA or minimal text with CTA
5. Disabled — which elements, when, visual indicator

**Audit-phase check**:
```bash
grep -rn "loading\|isLoading\|pending\|skeleton\|Spinner" src --include="*.tsx" --include="*.jsx"
grep -rn "error\|isError\|ErrorBoundary\|catch" src --include="*.tsx" --include="*.jsx"
grep -rn "empty\|isEmpty\|no.*found\|length === 0" src --include="*.tsx" --include="*.jsx"
```

**BLOCK conditions**: [INFERRED — proposed for v8]
- Data-fetching component has no loading state
- Data-fetching component has no error state

**FLAG conditions**: [CONFIRMED]
- No empty state for lists/collections
- No disabled state for submit buttons during loading

---

## 7. UI Work → Business Requirements Traceability

[CONFIRMED from `skills/ui/SKILL.md` Step 4, `skills/one-flow/SKILL.md` Step 4, REQUIREMENTS.md template]

### The Traceability Chain

```
R-id (REQUIREMENTS.md)
  └─→ Screen (UI_SPEC.md)
        └─→ State (UI_SPEC.md per-screen)
              └─→ Component (implementation)
                    └─→ Audit finding (UI_REVIEW.md)
                          └─→ Fix task (STATE.md TASK-XX)
```

### Rules

1. Every screen in UI_SPEC.md MUST reference at least one R-id. [CONFIRMED]
2. Every `/ui-review` top-3 fix MUST reference the R-ids it addresses. [CONFIRMED]
3. In `/one-flow` Step 4 (UI Contract): if screens are missing from spec → run `/ui` before implementation. [CONFIRMED]
4. If a task doesn't map to an R-id → HALT (scope creep or missing requirement). [CONFIRMED]
5. UI_SPEC is a contract file (`.avner/3_contracts/`) — it is a HOW document. Changes require `/core` escalation if they touch the design system itself. [INFERRED]

### Integration with /one-flow

In `/one-flow` Step 4 (UI Contract): [CONFIRMED]
- Detect: do any planned tasks touch UI files (components, pages, layouts, styles)?
- If yes: check if in-scope screens are already defined in UI_SPEC.md.
- If missing: run the `/ui` workflow inline, get user approval, then proceed to Step 5.
- If present: confirm spec is current before proceeding.

---

## 8. GSD vs AVNER Comparison Notes

[CONFIRMED from reading both systems]

| Feature | GSD (vendor/gsd) | AVNER (avner-stack skills) | v8 Recommendation |
|---------|-----------------|---------------------------|-------------------|
| Orchestration | Multi-agent (researcher + checker + auditor as separate Task subagents) | Single-agent skill (Claude handles all steps in one pass) | AVNER single-agent is simpler; adopt GSD multi-agent only for large teams [INFERRED] |
| Pillar count | 6 (same) | 6 (same) | Same [CONFIRMED] |
| Scoring scale | 1–4 per pillar, total /24 | 1–4 per pillar | Add /24 total in AVNER v8 [INFERRED] |
| Checker verdicts | BLOCK / FLAG / PASS per dimension | Pass/fail per pillar | AVNER v8 should adopt BLOCK/FLAG/PASS vocabulary [INFERRED] |
| shadcn gate | Explicit init gate + registry safety check | Detect state, recommend shadcn | Add registry safety dimension to AVNER /ui-review [INFERRED] |
| Screenshot capture | Playwright CLI (desktop/tablet/mobile) | Not in AVNER skills | [MISSING] — add as optional step in /ui-review v8 |
| Revision loop | Max 2 researcher → checker iterations | Single pass + flag-to-fix loop | AVNER can add max-2 revision guard [INFERRED] |
| State persistence | GSD state.json via gsd-tools CLI | .avner/4_operations/STATE.md | AVNER pattern is simpler, no CLI needed [CONFIRMED] |
| R-id traceability | Maps to REQUIREMENTS.md R-ids | Maps to REQUIREMENTS.md R-ids | Identical [CONFIRMED] |
| DNA Safety Rule | Not present (GSD writes freely) | Explicit: show diff + approval | AVNER DNA Safety Rule applies to UI_SPEC and UI_REVIEW [CONFIRMED] |
| Registry safety | Dimension 6 with BLOCK/FLAG verdicts | Not present | [MISSING] — add as optional Pillar 6b in v8 |

### Key GSD Patterns Worth Adopting in AVNER v8

1. **Checker verdict format**: `Dimension N — Name: BLOCK / FLAG / PASS` with exact fix descriptions [CONFIRMED from gsd-ui-checker]
2. **Registry safety gate**: Check `npx shadcn view {block}` for third-party components [CONFIRMED from gsd-ui-checker Dimension 6]
3. **Aggregate score `/24`**: GSD scores sum to /24 total; makes regression visible [CONFIRMED from gsd-ui-auditor]
4. **Screenshot storage gate**: Ensure `/.planning/ui-reviews/.gitignore` excludes `*.png` before any capture [CONFIRMED from gsd-ui-auditor]
5. **Six Forcing Questions**: Push once on each to get real answers vs. polished answers [CONFIRMED from one-flow.md Step 1a]
