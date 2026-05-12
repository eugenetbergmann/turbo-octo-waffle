# 04 — Schema Mapping Master

## Status: Draft

This document maps the source (MED/GP) schema to the Carlsbad analytical layer.

## Manufacturing Orders (MO)

| Source Table | Source Column | Carlsbad Column | Notes |
|---|---|---|---|
| WO010302 | WONUMBER_I | mo_number | Primary key |
| WO010302 | MANUFACTUREORDERST_I | mo_status | 2=released, 3=in-process |
| WO010302 | QTYPENDING | demand_qty | Demand quantity (NOT QTYREMAININGTOPOST) |
| WO010302 | STRTDATE | start_date | MO start date |
| WO010302 | ENDQTY_I | order_qty | Order quantity |
| WO010302 | ITMCLSCD | item_class | Item class filter: NOT LIKE '20%' |

## Purchase Orders (PO)

| Source Table | Source Column | Carlsbad Column | Notes |
|---|---|---|---|
| POP30310 | PONUMBER | po_number | PO number |
| POP30310 | POSTATUS | po_status | Header status |
| POP30310 | POLNESTA | po_line_status | Line status |
| POP30310 | QTYUNCMTBASE | open_qty | Open (uncommitted) quantity |

## Inventory

| Source Table | Source Column | Carlsbad Column | Notes |
|---|---|---|---|
| IV00102 | ITEMNMBR | item_number | Item number |
| IV00102 | QTYONHND | qty_on_hand | On-hand inventory |
| IV00102 | NONINVEN | noninven | Filter: must be 0 |
| IV00102 | ITMCLSCD | item_class | Item class code |

## Vendors

| Source Table | Source Column | Carlsbad Column | Notes |
|---|---|---|---|
| PM00200 | VENDORID | vendor_id | Vendor identifier |
| IV00103 | VENDORID | vendor_id | Item-vendor xref |
| IV00103 | ITEMNMBR | item_number | Item number |

## Guardrails
See `.gastown-context.md` for full column name guardrails and hard rules.