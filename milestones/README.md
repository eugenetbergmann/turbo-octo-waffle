# Milestones

Solid Waddle Carlsbad State Engine — phased delivery plan.

## Milestone Index

| #  | Milestone             | Scope                                      | Smoke Test           |
|----|-----------------------|--------------------------------------------|----------------------|
| 01 | Landing               | Baseline DDL, adapter views, first refresh | `01_smoke_test.sql`  |
| 02 | State Engine          | Core state tables and refresh procs        | `02_smoke_test.sql`  |
| 03 | Exceptions            | Exception detection and alerting           | —                    |
| 04 | Snapshots             | Daily append-only snapshot layer           | —                    |
| 05 | Views                 | Analytical and adapter views               | —                    |
| 06 | Costs                 | Cost roll-up and allocation logic          | —                    |
| 07 | History               | Audit trail and change data capture        | —                    |
| 08 | Forecasts             | Demand and supply forecasting              | —                    |
| 09 | Validation            | Data-quality checks and reconciliation     | —                    |
| 10 | Deprecation           | Sunsetting legacy objects                  | —                    |

## Architecture Constraints

Every milestone must comply with the rules in `.gastown-context.md`:

- **MED/GP** is the transactional source of truth. Never write back.
- **Carlsbad** is the analytical operating layer. SQL Agent only — no real-time triggers.
- State tables are materialized and refreshed on schedule.
- Snapshots are append-only. Never `UPDATE` or `DELETE` from snapshot tables.
- Every stored procedure ends with `EXEC dbo.usp_rep_log`.
- No `SELECT *` — explicit column lists only.
- No magic numbers — all thresholds live in a named config CTE at the top of every proc.
- `TRY_CAST` over `ISNUMERIC` everywhere.
- `NONINVEN = 0` on all receipt and cost queries.
- `ALTER VIEW` only via SSMS query window. View Designer is banned.
- No Friday deploys.

## Decision Vocabulary

| Code         | Meaning                                      |
|--------------|----------------------------------------------|
| `DO_NOTHING` | No action required                           |
| `WAIT`       | Hold for more information                    |
| `INVESTIGATE`| Dig into data or logic before deciding       |
| `CHASE`      | Actively pursue resolution                   |
| `BUY`        | Procure or commit to external spend          |

## Supply Tiers

| Tier | Description                             |
|------|-----------------------------------------|
| 1    | On-hand (Certain)                       |
| 2    | Open PO / in-transit (Conditional)      |
| 3    | Quarantine / WFQ (Binary)               |
| 4    | Cross-suffix (Requires sign-off)        |

## Running Order

Milestones must be completed sequentially. Each milestone's smoke test must pass before the next milestone begins.