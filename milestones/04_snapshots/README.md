# Snapshots

## Status: TBD

Append-only daily snapshots of the analytical state.

## Rules
- Never UPDATE or DELETE from snapshot tables.
- Every snapshot row includes `snapshot_date` and `snapshot_batch_id`.
- Snapshots are taken by SQL Agent on a daily schedule.