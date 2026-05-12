# 03 — GP Discovery

## Status: Draft

This document captures all Great Plains / MED discovery findings: table names,
column names, relationships, and known quirks.

## Tables of Interest

| Table | Alias | Purpose |
|-------|-------|---------|
| `WO010302` | MO Picklist | Manufacturing order picklist (active MOs) |
| `PM00200` | Vendor Master | Vendor master records |
| `IV00103` | Item-Vendor Xref | Item to vendor cross-reference |
| `IV00102` | Item Master | Inventory item master |
| `POP30310` | PO Receipt Work | PO receiving work/open quantities |

## Key Column Mappings

### MO (Manufacturing Orders)
- Active filter: `MANUFACTUREORDERST_I IN (2, 3)`
- Demand qty: `QTYPENDING`
- Start date: `STRTDATE`
- Quantity: `ENDQTY_I`
- Status codes: 0=void, 1=open, 2=released, 3=in-process, 5=closed, 6=cancelled, 7=complete

### PO (Purchase Orders)
- Header status: `POSTATUS`
- Line status: `POLNESTA`
- Open qty: `QTYUNCMTBASE`

### Inventory
- On-hand qty: `QTYONHND`
- Non-inventory flag: `NONINVEN`