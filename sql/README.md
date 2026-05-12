# SQL

## DDL (Data Definition Language)
State tables, exception tables, and snapshot tables.

## Procs (Stored Procedures)
- `usp_state_refresh` — Refresh state tables from MED/GP source
- `usp_exception_*` — Exception detection and flagging
- `usp_snapshot_daily` — Daily snapshot of analytical state

## Views
- `v_adapter_*` — Adapter views over state tables (thin layer)
- `v_decision` — Decision-support view
- `v_audit` — Audit trail view