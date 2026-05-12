# Milestone 02 — Core State Tables + usp_state_refresh

## Status: ✅ Complete

## Scope
Transform landing (h_) tables into analytical state (st_) tables for the Carlsbad decision layer.

## Files
- `sql/ddl/02_state_tables.sql` — 5 state tables (st_ prefix)
- `sql/procs/usp_state_refresh.sql` — State refresh procedure
- `milestones/02_state_engine/02_smoke_test.sql` — Smoke test (9 tests)

## Key Decisions
- State tables use `st_` prefix
- Refresh appends; never updates or deletes
- Config CTE drives all threshold logic (no magic numbers)
- Non-inventory items excluded (NONINVEN = 0)
- Active MOs filtered via MANUFACTUREORDERT IN (2, 3)
- `usp_state_refresh` called from `usp_state_refresh_full`

## Tables

| Table | Description |
|-------|-------------|
| st_mo_active | Active MO summary with picklist counts |
| st_po_line | PO detail enriched with header data |
| st_item_master | Items enriched with vendor + BOM context |
| st_lot_status | Lots enriched with item + vendor context |
| st_vendor_perf | Vendor performance summary with PO aggregates |