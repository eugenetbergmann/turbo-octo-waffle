# Solid Waddle Carlsbad State Engine

An analytical operating layer for Solid Waddle procurement decisions, built on Microsoft SQL Server.

Carlsbad reads from MED/GP (the transactional source of truth) and provides structured, auditable procurement analytics — landing tables, state snapshots, exception classification, and decision views.

## Architecture

```
MED (GP) → SQL Agent replication jobs → Landing Tables (h_ prefix)
  → usp_state_refresh (scheduled) → State Tables (st_ prefix)
    → Adapter Views (v_adapter_*) → Decision View (v_decision)
    → Exception Classification → Exception Buckets
    → Snapshot Capture → Snapshot Tables
```

## Decision Vocabulary

- **DO_NOTHING** — No action required
- **WAIT** — Monitor for changes
- **INVESTIGATE** — Requires buyer review
- **CHASE** — Expedite or follow up
- **BUY** — Authorize procurement

## Supply Credibility Tiers

1. On-hand physical inventory (Certain)
2. Open PO / in-transit (Conditional on vendor delivery)
3. Quarantine / WFQ (Binary: releases or it doesn't)
4. Cross-suffix / substitution (Requires business sign-off)

## Refresh Cadence

| Schedule               | Frequency          | Window             |
|------------------------|--------------------|--------------------|
| SW_Hourly_Replication  | Every 60 min       | 06:00–20:00 weekdays |
| SW_Daily_Replication   | Once daily         | 02:00              |
| SW_State_Refresh       | Every 60 min       | 10 min after replication |
| SW_Exception_Refresh   | Once daily         | 06:30              |
| SW_Snapshot            | Once daily         | 03:00              |
| SW_Validation          | Once daily         | 03:30              |

## Repository Structure

```
├── .gastown-context.md              ← Schema guardrails and hard rules
├── docs/
│   ├── 01-adr.md                    ← Architecture Decision Record
│   ├── 02-synthesis.md              ← System synthesis and data flow
│   ├── 03-gp-discovery.md           ← MED/GP source table mapping
│   └── 04-schema-mapping-master.md  ← Landing → State table mappings
├── milestones/
│   ├── 01_landing/                  ← Landing tables + replication jobs
│   ├── 02_state_engine/             ← Core state tables + usp_state_refresh
│   ├── 03_exceptions/               ← Exception buckets
│   ├── 04_snapshots/                ← Snapshots + time-travel
│   ├── 05_views/                    ← Adapter views + buyer surface
│   ├── 06_costs/                    ← Pricing / actual cost layer
│   ├── 07_history/                  ← Historical backfill (360+ days)
│   ├── 08_forecasts/                ← Volume projections
│   ├── 09_validation/               ← Validation pack + alerts
│   └── 10_deprecation/              ← Deprecate old MED view chain
└── sql/
    ├── ddl/                         ← Data definition language scripts
    │   └── 01_landing_tables.sql     ← 12 landing tables (h_ prefix)
    ├── procs/                       ← Stored procedures
    │   ├── usp_rep_log.sql          ← Shared replication audit log
    │   ├── usp_replicate_*.sql      ← 8 replication procs
    │   ├── usp_state_refresh.sql    ← State table refresh
    │   └── usp_state_refresh_full.sql ← Full orchestration
    └── views/                       ← Views (planned)
```

## Governance Rules (Non-Negotiable)

- ALTER VIEW only via SSMS query window. View Designer banned.
- No Friday deploys.
- Validate deployed truth against source files before any change.
- Every proc ends with `EXEC dbo.usp_rep_log`.
- Snapshots are append-only. Never update or delete from snapshot tables.
- No magic numbers. All thresholds in named config CTEs.
- NONINVEN = 0 filter on all receipt/cost queries.
- TRY_CAST over ISNUMERIC everywhere.
- Explicit column lists. No SELECT *.

## Getting Started

See [docs/01-adr.md](docs/01-adr.md) for the full architecture decision record.
See [milestones/README.md](milestones/README.md) for the phased delivery plan.
