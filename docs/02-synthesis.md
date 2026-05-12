# 02 — Synthesis

## Status: Draft

This document synthesises the design decisions, architecture, and operational
requirements captured across the ADRs and GP discovery work.

## Key Findings

### Architecture
- MED/GP is the single source of truth (transactional).
- Carlsbad is the analytical operating layer (read-only from MED/GP).
- State engine materialises views into tables refreshed on schedule.

### Data Model
- MO picklist sourced from `WO010302` with active filter `MANUFACTUREORDERST_I IN (2, 3)`.
- Demand quantity is `QTYPENDING`.
- PO open quantity is `QTYUNCMTBASE`.
- All receipt/cost queries filter `NONINVEN = 0`.

### Supply Tiers
1. **On-hand** (Certain) — inventory already received.
2. **Open PO / in-transit** (Conditional) — committed but not yet received.
3. **Quarantine / WFQ** (Binary) — quality hold or waiting-for-quote.
4. **Cross-suffix** (Requires sign-off) — cross-plant or cross-company.