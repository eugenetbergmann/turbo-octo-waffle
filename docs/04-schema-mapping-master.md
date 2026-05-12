# Schema Mapping Master — Solid Waddle Carlsbad State Engine

## Corrected Table Mappings

| Logical Name       | MED Table      | Landing Table        | Notes                                    |
|--------------------|----------------|----------------------|------------------------------------------|
| MO Picklist        | WO010302       | h_mo_picklist        | NOT WO010033                             |
| MO Header          | MOP10100       | h_mo_header          | Manufacturing orders                     |
| MO Demand          | QTYPENDING     | h_mo_picklist_demand | NOT QTYREMAININGTOPOST                   |
| PO Header          | POD10100       | h_po_header          | Status column: POSTATUS                  |
| PO Detail          | POD10110       | h_po_detail          | Open qty: QTYUNCMTBASE                   |
| Item Master        | IV00101        | h_item_master        |                                          |
| Item-Qty           | IV00102        | h_item_qty           |                                          |
| Item-Vendor Xref   | IV00103        | h_item_vendor_xref   | NOT POP60000                             |
| Bill of Materials  | BM00101        | h_bom_master         | Bill master                              |
| BOM Component      | BM00111        | h_bom_component      | Bill components                          |
| Lot Master         | LOTMAST        | h_lot_master         | Qty column: QUANTITY (NOT QTY)           |
| Vendor Master      | PM00200        | h_vendor_master      |                                          |
| UOM Schedule        | IV40400       | —                    | Unit of measure                          |
| Locator            | IV00112       | —                    | Item locations                           |
| Site Master        | SY01400       | —                    | Company / intercompany                   |
| Currency           | CM20100       | —                    | Currency codes                           |

## Active MO Filter
`MANUFACTUREORDERST_I IN (2, 3)` — excludes statuses 5 (Closed) and 6 (Cancelled)

## PO Open Quantity
Use `QTYUNCMTBASE` directly — do NOT compute as `(QTYORDER - QTYRCVD - QTYCANCE)`

## Landing → State Mapping

| Landing Table        | State Table      | Notes                              |
|----------------------|------------------|------------------------------------|
| h_mo_picklist        | st_mo_picklist   | Active MOs only                    |
| h_mo_header          | st_mo_header     | Active MOs only                    |
| h_po_header + detail | st_po            | JOIN on PONUMBER, POSTATUS > 0     |
| h_item_master        | st_item          | INACTIVE = 0 only                  |
| h_bom_master         | st_bom           | All BOM records                     |

## Key Conventions
- NONINVEN = 0 on all receipt/cost queries
- TRY_CAST over ISNUMERIC everywhere
- Snapshots are append-only; never UPDATE or DELETE from snapshot tables
- Every proc ends with EXEC dbo.usp_rep_log
- No SELECT * — explicit column lists only
- No magic numbers — thresholds in named config CTE
- ALTER VIEW only via SSMS query window (View Designer banned)
- No Friday deploys