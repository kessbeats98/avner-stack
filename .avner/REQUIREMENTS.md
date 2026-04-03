# REQUIREMENTS.md — avner-stack framework

## Purpose
Reusable governance framework for autonomous AI development in Claude Code.
Primary consumer: Akivot SaaS (Next.js 16). Generic enough for any solo-dev project.

## Requirements

| ID | Requirement | Status |
|----|------------|--------|
| R-01 | 3-role execution model (CEO CODEX, Claude Code, Codex Review) with clear separation | DONE |
| R-02 | Council of 5 verification agents for HIGH-risk gating | DONE |
| R-03 | /one-flow as single entry point: REQ -> PLAN -> review -> execute -> review -> ship | DONE |
| R-04 | File-based coordination via .avner/ directory (no external DB) | DONE |
| R-05 | Anti-loop guarantees: hard caps on plan rounds (3), fix attempts (2), debug loops (3) | DONE |
| R-06 | Paperclip integration: heartbeats, approvals, budget checks, cost events w/ dry-run | DONE |
| R-07 | DNA Safety: CLAUDE.md never auto-modified without human approval + visible diffs | DONE |
| R-08 | avner-init scaffolding for new and existing projects | DONE |
| R-09 | Graceful degradation: all external deps (Paperclip, Council) optional | DONE |
| R-10 | Self-governance: framework uses its own .avner/ for tracking | IN-PROGRESS |

## Non-Goals
- Multi-user / team collaboration (single-operator model)
- Cloud-hosted control plane (file-based only)
- Auto-merging to main without human gate on HIGH risk
