# Synthesis — Solid Waddle Carlsbad State Engine

## Problem Statement
The existing MED/GP environment relies on chained views for procurement analytics.
These views are fragile, opaque, and lack auditability. Refresh logic is implicit,
exceptions are buried in WHERE clauses, and there is no historical record of state changes.

## Solution Overview
Carlsbad introduces a structured analytical layer between MED/GP and the consumer:
1. **Landing tables** (h_*) receive replicated data from MED via scheduled jobs
2. **State tables** (st_*) hold the current analytical snapshot, refreshed on schedule
3. **Adapter views** (v_adapter_*) provide a stable interface to downstream consumers
4. **Decision view** (v_decision) delivers the final procurement recommendation
5. **Exception buckets** capture anomalies for buyer review
6. **Snapshot tables** preserve historical state for time-travel queries

## Architecture Principles
- Read-only to MED — no write-back
- Append-only pattern — never UPDATE or DELETE from state
- Idempotent refresh — safe to re-run
- Explicit column lists — no SELECT *
- Named config CTEs — no magic numbers
- Replication audit log on every proc execution

## Data Flow
```
Source (MED/GP)
  → Replication Jobs (usp_replicate_*)
    → Landing Tables (h_*)
      → State Refresh (usp_state_refresh)
        → State Tables (st_*)
          → Adapter Views (v_adapter_*)
            → Decision View (v_decision)
          → Exception Classification
            → Exception Buckets
          → Snapshot Capture
            → Snapshot Tables
```