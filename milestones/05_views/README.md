# Views

## Status: TBD

Adapter views and decision-support views.

## Adapter Views (`v_adapter_*`)
Thin layer over state tables. No business logic — just column mapping and
renaming from source conventions to Carlsbad conventions.

## Decision View (`v_decision`)
Aggregated view for supply/demand decision-making.

## Audit View (`v_audit`)
Read-only view into the audit trail.