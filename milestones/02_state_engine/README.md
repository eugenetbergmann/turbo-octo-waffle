# Milestone 02 — Core State Tables + usp_state_refresh

## Status: 🔨 In Progress

## Scope
Transform landing (h_) tables into analytical state (st_) tables for the Carlsbad decision layer.

## Files
- `sql/ddl/02_state_tables.sql` — State table DDL
- `sql/procs/usp_state_refresh.sql` — State refresh procedure
- `milestones/02_state_engine/02_smoke_test.sql` — Smoke test

## Key Decisions
- State tables use `st_` prefix
- Refresh appends; never updates or deletes
- Config CTE drives all threshold logic
- Non-inventory items excluded (NONINVEN = 0)