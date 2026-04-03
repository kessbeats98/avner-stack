# Gate Protocols — avner-stack v10

Defines when Council agents fire, what they check, and how their verdicts gate the pipeline.

## When Gates Run

Gates only fire during **Step 7 of /one-flow** (Council Gate), and only for:
- HIGH risk tasks (always)
- User-requested council review (any risk)

LOW/MEDIUM tasks skip Council entirely unless the user asks.

## Council Agents

### verify-vision (Elazar)
- **Triggers**: /new, /core, HIGH risk
- **Checks**: REQ alignment with VISION.md, GAP_ANALYSIS.md. Is this task moving toward the product vision?
- **Outputs**: APPROVE | HALT | NEEDS-CLARIFICATION | SOLVE-BY-REMOVAL
- **Blocks on**: HALT (task contradicts vision), NEEDS-CLARIFICATION (ambiguous scope)
- **Model**: opus

### verify-spec (Eliezer)
- **Triggers**: /core (always), any task touching DB_SCHEMA.md or API_CONTRACTS.md
- **Checks**: Schema compatibility, API contract adherence, global state mutations
- **Outputs**: PASS | FAIL | ESCALATE-TO-CORE
- **Blocks on**: FAIL (breaks contract), ESCALATE-TO-CORE (needs /core mode instead)
- **Model**: sonnet

### verify-security (Shimon)
- **Triggers**: HIGH risk, /deploy, any task touching auth/credentials/encryption
- **Checks**: Threat model — injection, auth bypass, race conditions, secrets in code, data loss
- **Outputs**: PASS | FAIL
- **Blocks on**: FAIL (security flaw found). Has **veto power** on /deploy.
- **Model**: opus

### verify-ops (Yossi)
- **Triggers**: /deploy (always), HIGH risk
- **Checks**: Env vars set, build passes, migrations safe, monitoring in place, integration tests
- **Outputs**: PASS | FAIL
- **Blocks on**: FAIL (not deploy-ready)
- **Model**: sonnet

### verify-integration (Yehoshua)
- **Triggers**: Tasks touching cross-system boundaries (API caller/callee, event producers/consumers)
- **Checks**: Caller-callee compatibility, event schema alignment, timeout/retry consistency
- **Outputs**: PASS | FAIL
- **Blocks on**: FAIL (integration mismatch)
- **Model**: sonnet

## Verdict Aggregation

After all required Council agents return:

| Condition | Result | Action |
|-----------|--------|--------|
| All PASS | PROCEED | Write gate_pass.txt, proceed to merge |
| Any HOLD | HELD | Present hold reason to human for resolution |
| Any BLOCK | BLOCKED | Log to COUNCIL_LOG.md, alert human, task stops |

See `docs/verdict-protocol.md` for raw verdict → normalized mapping.

## gate_pass.txt

Written after all verdicts PASS + merge approved:
```
GATE_PASS [TASK-ID] [ISO-8601] [risk-tier] [agent-names]
```
Deleted at start of next task cycle.

## Fallback (no Council)

When Council is skipped (LOW/MEDIUM risk, no user request):
- Codex Review verdict alone gates the merge
- No gate_pass.txt written (not needed for non-Council path)
- PreToolUse hook still enforces vision evidence for commits
