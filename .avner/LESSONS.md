# LESSONS.md — avner-stack framework

## Patterns (do more of this)
- [2026-04-03] PATTERN: Single entry point (/one-flow) eliminated confusion about which workflow to use
- [2026-04-03] PATTERN: Anti-loop caps (3/2/3) prevent infinite revision — forces "good enough" decisions
- [2026-04-03] PATTERN: Dry-run default for external integrations — safe to develop without live services
- [2026-04-03] PATTERN: Archiving instead of deleting preserves history without polluting active code
- [2026-04-03] PATTERN: Surgical fix protocol (1 file, 20 lines) is a good escape valve for review deadlocks

## Antipatterns (never again)
- [2026-04-03] ANTIPATTERN: Dual execution paths (v9 Manager + v10 one-flow) caused 6 duplicate agents/skills and split maintenance
- [2026-04-03] ANTIPATTERN: Empty .avner/ stubs in governance framework — "do as I say not as I do" destroys credibility
- [2026-04-03] ANTIPATTERN: codex-review vs codex-reviewer naming — near-identical agents with slightly different tool access caused wiring confusion

## Fixes Applied
- [2026-04-03] FIX: Archived all v9 agents/skills, unified on v10 /one-flow as sole execution path
- [2026-04-03] FIX: Populated .avner/ with real framework content (dogfooding)
- [2026-04-03] FIX: Paperclip integration centralized in lib/paperclip.sh with dry-run + graceful degradation
