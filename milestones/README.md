# Milestones

## Roadmap

| #  | Milestone | Status |
|----|-----------|--------|
| 01 | Landing — smoke test & project scaffold | 🔲 |
| 02 | State engine — core tables & refresh logic | 🔲 |
| 03 | Exceptions — detect & flag anomalies | 🔲 |
| 04 | Snapshots — append-only daily snapshots | 🔲 |
| 05 | Views — adapter & decision-support views | 🔲 |
| 06 | Costs — cost roll-up & variance analysis | 🔲 |
| 07 | History — audit trail & change tracking | 🔲 |
| 08 | Forecasts — demand & supply forecasting | 🔲 |
| 09 | Validation — data quality checks | 🔲 |
| 10 | Deprecation — legacy cleanup | 🔲 |

## Conventions
- Each milestone directory contains a `NN_smoke_test.sql` that validates the
  milestone's deliverables.
- All SQL follows the guardrails in `.gastown-context.md`.
- Every stored procedure ends with `EXEC dbo.usp_rep_log`.
- No `SELECT *` — always explicit column lists.
- No magic numbers — use named config CTEs.
- `TRY_CAST` over `ISNUMERIC` everywhere.