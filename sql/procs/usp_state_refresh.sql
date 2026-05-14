-- MILESTONE: 02
-- OBJECT: usp_state_refresh
-- DESCRIPTION: Refresh analytical state (st_) tables from landing (h_) tables.
--              Append-only; never UPDATE or DELETE. Called from usp_state_refresh_full.
-- STATUS: active

-- =============================================
-- State Refresh Procedure — Solid Waddle Carlsbad
-- =============================================
-- Reads from h_* landing tables, writes to st_* state tables.
-- Pattern: append-only, idempotent via NOT EXISTS checks.
-- Config CTE drives all threshold logic (no magic numbers).
-- Non-inventory items excluded (NONINVEN = 0).
-- =============================================

CREATE PROCEDURE dbo.usp_state_refresh
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH config AS (
        SELECT
            mo_status_active   = CAST(2 AS SMALLINT),
            mo_status_released = CAST(3 AS SMALLINT),
            NONINVEN           = 0
    )

    -- ============================================
    -- 1. st_mo_active: Active MO summary
    -- ============================================
    INSERT INTO dbo.st_mo_active
    (
        MANUFACTUREORDER_I, WORKORDERNUMBER, ITEMNMBR, LOCNCODE,
        STATUS, MANUFACTUREORDERT, DUEDATE, STARTDATE, TRACK,
        QTYORDER, QTYREMAINING, QTYCOMPLETED, QTYREJECTED,
        PICKLISTCOUNT, REVISION, LOTATTRIBUTE1, LOTATTRIBUTE2, LOTATTRIBUTE3,
        DATETIMESTAMP
    )
    SELECT
        hdr.MANUFACTUREORDER_I, hdr.WORKORDERNUMBER, hdr.ITEMNMBR, hdr.LOCNCODE,
        hdr.STATUS, hdr.MANUFACTUREORDERT, hdr.DUEDATE, hdr.STARTDATE, hdr.TRACK,
        hdr.QTYORDER, hdr.QTYREMAINING, hdr.QTYCOMPLETED, hdr.QTYREJECTED,
        pl.PICKLISTCOUNT, hdr.REVISION, hdr.LOTATTRIBUTE1, hdr.LOTATTRIBUTE2, hdr.LOTATTRIBUTE3,
        GETUTCDATE()
    FROM dbo.h_mo_header AS hdr
    CROSS JOIN config
    LEFT JOIN (
        SELECT MANUFACTUREORDER_I, COUNT(*) AS PICKLISTCOUNT
        FROM dbo.h_mo_picklist
        GROUP BY MANUFACTUREORDER_I
    ) AS pl ON pl.MANUFACTUREORDER_I = hdr.MANUFACTUREORDER_I
    WHERE hdr.MANUFACTUREORDERT IN (config.mo_status_active, config.mo_status_released)
      AND NOT EXISTS (
          SELECT 1 FROM dbo.st_mo_active AS tgt
          WHERE tgt.MANUFACTUREORDER_I = hdr.MANUFACTUREORDER_I
      );

    -- ============================================
    -- 2. st_po_line: PO detail enriched with header
    -- ============================================
    INSERT INTO dbo.st_po_line
    (
        PONUMBER, POLNESTA, POSTATUS, VENDORID, VENDNAME,
        ITEMNMBR, ITEMDESC, LOCNCODE, UOFM,
        QTYORDER, QTYRCVD, QTYCANCE, QTYUNCMTBASE,
        UNITCOST, EXTDCOST, REQDATETIME, DUEDATE, TRACK,
        MILESTONEVALUE, MILESTONEDATE, REFTONMBRS, ORD,
        BCKTYEAR_I, BCKTPERIOD_I, LOTATTRIBUTE1, LOTATTRIBUTE2, LOTATTRIBUTE3,
        DATETIMESTAMP
    )
    SELECT
        det.PONUMBER, det.POLNESTA, hdr.POSTATUS, hdr.VENDORID, hdr.VENDNAME,
        det.ITEMNMBR, det.ITEMDESC, det.LOCNCODE, det.UOFM,
        det.QTYORDER, det.QTYRCVD, det.QTYCANCE, det.QTYUNCMTBASE,
        det.UNITCOST, det.EXTDCOST, det.REQDATETIME, det.DUEDATE, det.TRACK,
        det.MILESTONEVALUE, det.MILESTONEDATE, det.REFTONMBRS, det.ORD,
        det.BCKTYEAR_I, det.BCKTPERIOD_I, det.LOTATTRIBUTE1, det.LOTATTRIBUTE2, det.LOTATTRIBUTE3,
        GETUTCDATE()
    FROM dbo.h_po_detail AS det
    JOIN dbo.h_po_header AS hdr ON hdr.PONUMBER = det.PONUMBER
    WHERE hdr.POSTATUS > 0
      AND NOT EXISTS (
          SELECT 1 FROM dbo.st_po_line AS tgt
          WHERE tgt.PONUMBER = det.PONUMBER AND tgt.POLNESTA = det.POLNESTA
      );

    -- ============================================
    -- 3. st_item_master: Items enriched with vendor + BOM context
    -- ============================================
    INSERT INTO dbo.st_item_master
    (
        ITEMNMBR, ITEMDESC, ITMSHNAM, ITEMSHWT, ITMSHWTUOM,
        STNDCOST, CURRCOST, ITEMSHWTDSCR, DECPLQTY, DECPLCUR,
        ITEMSCHCAT_I, ITEMTYPE, INACTIVE, STKAVLBL, COMMCODE_I,
        TAXOPTNS, IVCOGSIX, IVSLSIDX, IVALIASIX, IVVARIX,
        MSTRCDTY, MODIFDT, CREATEDDT,
        PRIMARYVENDORID, PRIMARYVENDNAME, LEADTIME,
        MINORDERQTY, MAXORDERQTY, ECONORDERQTY, VNDPRCTNM,
        BOM_COUNT, BOM_TOTAL_QTY,
        DATETIMESTAMP
    )
    SELECT
        item.ITEMNMBR, item.ITEMDESC, item.ITMSHNAM, item.ITEMSHWT, item.ITMSHWTUOM,
        item.STNDCOST, item.CURRCOST, item.ITEMSHWTDSCR, item.DECPLQTY, item.DECPLCUR,
        item.ITEMSCHCAT_I, item.ITEMTYPE, item.INACTIVE, item.STKAVLBL, item.COMMCODE_I,
        item.TAXOPTNS, item.IVCOGSIX, item.IVSLSIDX, item.IVALIASIX, item.IVVARIX,
        item.MSTRCDTY, item.MODIFDT, item.CREATEDDT,
        vx.VENDORID, vx.VENDNAME, vx.LEADTIME,
        vx.MINORDERQTY, vx.MAXORDERQTY, vx.ECONORDERQTY, vx.VNDPRCTNM,
        bom.BOM_COUNT, bom.BOM_TOTAL_QTY,
        GETUTCDATE()
    FROM dbo.h_item_master AS item
    CROSS JOIN config
    LEFT JOIN (
        -- Primary vendor per item (lowest VNDPRCTNM or first alphabetically)
        SELECT v1.ITEMNMBR, v1.VENDORID, v1.VENDNAME, v1.LEADTIME,
               v1.MINORDERQTY, v1.MAXORDERQTY, v1.ECONORDERQTY, v1.VNDPRCTNM
        FROM dbo.h_item_vendor_xref AS v1
        INNER JOIN (
            SELECT ITEMNMBR, MIN(VENDORID) AS VENDORID
            FROM dbo.h_item_vendor_xref
            GROUP BY ITEMNMBR
        ) AS v2 ON v2.ITEMNMBR = v1.ITEMNMBR AND v2.VENDORID = v1.VENDORID
    ) AS vx ON vx.ITEMNMBR = item.ITEMNMBR
    LEFT JOIN (
        SELECT ITEMNMBR, COUNT(*) AS BOM_COUNT, SUM(QUANTITY) AS BOM_TOTAL_QTY
        FROM dbo.h_bom_component
        GROUP BY ITEMNMBR
    ) AS bom ON bom.ITEMNMBR = item.ITEMNMBR
    WHERE item.NONINVEN = config.NONINVEN
      AND NOT EXISTS (
          SELECT 1 FROM dbo.st_item_master AS tgt
          WHERE tgt.ITEMNMBR = item.ITEMNMBR
      );

    -- ============================================
    -- 4. st_lot_status: Lots enriched with item + vendor context
    -- ============================================
    INSERT INTO dbo.st_lot_status
    (
        LOTNUMBR, ITEMNMBR, LOCNCODE,
        LOTATTRIBUTE1, LOTATTRIBUTE2, LOTATTRIBUTE3,
        TRK_LOT_USERDEF_1, TRK_LOT_USERDEF_2,
        QUANTITY, DATERECD, DUEDATE, EXPDATE, LOTSTATUS, HOLDSTS,
        ITEMDESC, VENDORID, VENDNAME,
        DATETIMESTAMP
    )
    SELECT
        lot.LOTNUMBR, lot.ITEMNMBR, lot.LOCNCODE,
        lot.LOTATTRIBUTE1, lot.LOTATTRIBUTE2, lot.LOTATTRIBUTE3,
        lot.TRK_LOT_USERDEF_1, lot.TRK_LOT_USERDEF_2,
        lot.QUANTITY, lot.DATERECD, lot.DUEDATE, lot.EXPDATE, lot.LOTSTATUS, lot.HOLDSTS,
        item.ITEMDESC,
        -- Find vendor for this lot's item
        (SELECT TOP 1 VENDORID FROM dbo.h_item_vendor_xref WHERE ITEMNMBR = lot.ITEMNMBR) AS VENDORID,
        (SELECT TOP 1 VENDNAME FROM dbo.h_item_vendor_xref WHERE ITEMNMBR = lot.ITEMNMBR) AS VENDNAME,
        GETUTCDATE()
    FROM dbo.h_lot_master AS lot
    LEFT JOIN dbo.h_item_master AS item ON item.ITEMNMBR = lot.ITEMNMBR
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.st_lot_status AS tgt
        WHERE tgt.LOTNUMBR = lot.LOTNUMBR AND tgt.ITEMNMBR = lot.ITEMNMBR
    );

    -- ============================================
    -- 5. st_vendor_perf: Vendor performance summary
    -- ============================================
    INSERT INTO dbo.st_vendor_perf
    (
        VENDORID, VENDNAME, VNDCLSID, VNDSTID, VNDSTNUM, VNDPHNUM, VNDFAX,
        VNDCRCRD, CURNCYID, INACTIVE, MINPYMTTYP, MINPYDLRNT, MAXPYMTTYP,
        PYMTRMID, CHKACTINDX,
        OPENPO_COUNT, OPENPO_TOTAL, LAST_PO_DATE,
        CREATEDDATETIME, MODIFIEDDATETIME,
        DATETIMESTAMP
    )
    SELECT
        vnd.VENDORID, vnd.VENDNAME, vnd.VNDCLSID, vnd.VNDSTID, vnd.VNDSTNUM,
        vnd.VNDPHNUM, vnd.VNDFAX, vnd.VNDCRCRD, vnd.CURNCYID, vnd.INACTIVE,
        vnd.MINPYMTTYP, vnd.MINPYDLRNT, vnd.MAXPYMTTYP, vnd.PYMTRMID, vnd.CHKACTINDX,
        po.OPENPO_COUNT, po.OPENPO_TOTAL, po.LAST_PO_DATE,
        vnd.CREATEDDATETIME, vnd.MODIFIEDDATETIME,
        GETUTCDATE()
    FROM dbo.h_vendor_master AS vnd
    LEFT JOIN (
        SELECT VENDORID,
               COUNT(*) AS OPENPO_COUNT,
               SUM(DOCAMNT) AS OPENPO_TOTAL,
               MAX(DATERECD) AS LAST_PO_DATE
        FROM dbo.h_po_header
        WHERE POSTATUS > 0
        GROUP BY VENDORID
    ) AS po ON po.VENDORID = vnd.VENDORID
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.st_vendor_perf AS tgt
        WHERE tgt.VENDORID = vnd.VENDORID
    );

    EXEC dbo.usp_rep_log;
END
GO