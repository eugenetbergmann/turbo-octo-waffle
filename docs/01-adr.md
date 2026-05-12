# 01 — Architecture Decision Record

## Status: Accepted

## Context
Turbo-Octo-Waffle is a transient task and project management system. It separates
planning concerns into three layers: Grid (spatial organization), Flow (state
transitions), and History (audit trail).

## Decision
The backend is a SQL Server analytical state engine ("Carlsbad") built on top of
MED/GP as the transactional source of truth. All data is read from MED/GP via
adapter views; no writes go back to the source.

## Consequences
- State tables are materialized and refreshed on schedule via SQL Agent jobs.
- Snapshots are append-only — never UPDATE or DELETE.
- Every stored procedure terminates with `usp_rep_log` for audit.
- Schema guardrails are enforced via `.gastown-context.md`.