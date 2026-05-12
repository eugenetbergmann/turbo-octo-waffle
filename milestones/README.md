# Milestones — Solid Waddle Carlsbad State Engine

## Build Plan

| #  | Milestone                          | Status |
|----|------------------------------------|--------|
| 01 | Landing tables + replication jobs  | ✅ Complete |
| 02 | Core state tables + usp_state_refresh | 🔨 In Progress |
| 03 | Exception buckets                  | Pending |
| 04 | Snapshots + time-travel            | Pending |
| 05 | Adapter views + buyer surface      | Pending |
| 06 | Pricing / actual cost layer        | Pending |
| 07 | Historical backfill (360+ days)    | Pending |
| 08 | Volume projections                 | Pending |
| 09 | Validation pack + alerts           | Pending |
| 10 | Deprecate old MED view chain       | Pending |

## Completed — Milestone 01: Landing Tables + Replication Jobs

### Files
- `sql/ddl/01_landing_tables.sql` — 12 landing tables (h_ prefix)
- `sql/procs/usp_rep_log.sql` — Shared replication audit log
- `sql/procs/usp_replicate_mo_picklist.sql` — MO picklist replication
- `sql/procs/usp_replicate_mo_header.sql` — MO header replication
- `sql/procs/usp_replicate_po_header.sql` — PO header replication
- `sql/procs/usp_replicate_po_detail.sql` — PO detail replication
- `sql/procs/usp_replicate_items.sql` — Items + qty + vendor xref replication
- `sql/procs/usp_replicate_bom.sql` — BOM master + components replication
- `sql/procs/usp_replicate_vendor.sql` — Vendor replication
- `sql/procs/usp_replicate_lots.sql` — Lot master replication
- `sql/procs/usp_state_refresh_full.sql` — Full orchestration proc
- `milestones/01_landing/01_smoke_test.sql` — Smoke test (5 tests)

### Key Decisions
- Landing tables use `h_` prefix, append-only pattern
- Every table has a `DATETIMESTAMP` column for replication tracking
- Active MOs filtered via `MANUFACTUREORDERST_I IN (2, 3)`
- PO open qty uses `QTYUNCMTBASE` (not computed)
- Lot master filtered on `NONINVEN = 0`
- All procs end with `EXEC dbo.usp_rep_log`
- No magic numbers — config CTEs in every proc