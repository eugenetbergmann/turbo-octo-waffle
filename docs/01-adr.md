# Architecture Decision Record — Solid Waddle Carlsbad State Engine

## Status: Approved for Implementation

## Core Decision
Build Carlsbad as the authoritative compute layer for Solid Waddle procurement decisions.

- MED/GP remains transactional source of truth
- Carlsbad becomes analytical operating layer
- No write-back to MED. No external orchestration. SQL Server Agent only.

## What This Replaces
- Long chained view recomputation → Materialized state tables refreshed on schedule
- Logic scattered across GP views → Thin adapter views → state procs → decision layer
- No restart safety → IF NOT EXISTS append pattern throughout
- Exceptions implicit in view logic → First-class exception bucket tables
- No audit trail → decision_audit_log, append-only snapshots
- Magic number thresholds → Named config CTE in every proc
- Schema drift risk → Validation pack runs after every refresh

## Layer Map
```
MED (GP) → SQL Agent replication jobs → Carlsbad Landing (h_/d_ prefix)
  → usp_state_refresh (scheduled) → Carlsbad State tables
    → Adapter views (v_adapter_*) → Decision view (v_decision)
    → Audit view (v_audit) → Exception buckets → Snapshot tables
```

## Decision Vocabulary
- DO_NOTHING
- WAIT
- INVESTIGATE
- CHASE
- BUY

## Supply Credibility Tiers
1. On-hand physical inventory (Certain)
2. Open PO / in-transit (Conditional on vendor delivery)
3. Quarantine / WFQ (Binary: releases or it doesn't)
4. Cross-suffix / substitution (Requires business sign-off)

## Refresh Cadence
- SW_Hourly_Replication: Every 60 min, 06:00–20:00 weekdays
- SW_Daily_Replication: 02:00 daily
- SW_State_Refresh: Every 60 min, 10 min after replication
- SW_Exception_Refresh: 06:30 daily
- SW_Snapshot: 03:00 daily
- SW_Validation: 03:30 daily

## Governance Rules (Non-Negotiable)
- ALTER VIEW only via SSMS query window. View Designer banned.
- No Friday deploys.
- Validate deployed truth against source files before any change.
- Every proc ends with a replication_log write.
- Snapshots are append-only. Never update or delete from snapshot tables.
- No magic numbers. All thresholds in named config CTE.
- NONINVEN = 0 filter on all receipt/cost queries.
- TRY_CAST over ISNUMERIC everywhere.
- Explicit column lists. No SELECT *.