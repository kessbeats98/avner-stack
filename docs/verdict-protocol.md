# Verdict Parsing Protocol

Standard for parsing and normalizing verdicts from all AVNER agents.

## Parsing Rules

All Council and reviewer agents output a verdict line. Parse in order:

1. **Primary**: scan for line matching `^Verdict:\s*(.+)$` (case-insensitive)
2. **Fallback**: scan for `^## Verdict\n(.+)$` (markdown heading format)
3. **Strip** leading/trailing whitespace from captured value

If no verdict line found → treat as `BLOCK` with reason "no verdict in agent output."

## Normalization Map

| Raw Verdict | Normalized | Meaning |
|-------------|-----------|---------|
| APPROVE | PASS | Agent approves |
| PASS | PASS | Agent approves |
| GO | PASS | Agent approves |
| HALT | BLOCK | Hard stop, cannot proceed |
| FAIL | BLOCK | Hard stop, cannot proceed |
| NO-GO | BLOCK | Hard stop, cannot proceed |
| NEEDS-CLARIFICATION | HOLD | Human input needed |
| NEEDS-MITIGATION | HOLD | Human input needed |
| NEEDS-REVISION | HOLD | Re-dispatch or human input |
| NEEDS-REVIEW | HOLD | Human input needed |
| ESCALATE-TO-CORE | HOLD | Mode change needed |
| CONDITIONAL-GO | HOLD | Human sign-off needed |
| SOLVE-BY-REMOVAL | HOLD | Redirect to /prune |

## Aggregation

After collecting all required Council verdicts for a task:

- **Any BLOCK** → task BLOCKED. Log to COUNCIL_LOG.md. Alert human.
- **Any HOLD** → task HELD. Present hold reason to human for resolution.
- **All PASS** → proceed to merge decision.

## COUNCIL_LOG.md Entry Schema

Each entry appended by Manager after a Council agent runs:

```markdown
### [ISO-8601] — [TASK-ID] — [agent-name]
- Verdict: [raw verdict from agent]
- Normalized: [PASS | BLOCK | HOLD]
- Risk: [LOW | MEDIUM | HIGH]
- Evidence: [1-line summary or "see REVIEW.md"]
- Action: [PROCEED | BLOCKED | HUMAN-REVIEW]
---
```

## gate_pass.txt Format

Written by Manager after all Council verdicts PASS and merge decision approved:

```
GATE_PASS [TASK-ID] [ISO-8601-timestamp] [risk-tier] [comma-separated-agent-names]
```

Example: `GATE_PASS TASK-07 2026-04-01T14:30:00Z MEDIUM verify-spec,verify-security`

Deleted at start of next dispatch cycle.

## last_vision_check.txt Format

Written by /dispatch skill during vision gate:

```
APPROVE [unix-timestamp]
```
or
```
FIX-BYPASS [unix-timestamp]
```

Deleted at start of next dispatch cycle alongside gate_pass.txt.
