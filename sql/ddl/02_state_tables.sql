-- MILESTONE: 02
-- OBJECT: h_state_tables_ddl
-- DESCRIPTION: Create analytical state (st_) tables derived from landing (h_) tables.
-- STATUS: active

-- =============================================
-- State Tables — Solid Waddle Carlsbad
-- =============================================
-- Pattern: append-only, IF NOT EXISTS, no UPDATE/DELETE.
-- State tables hold the latest analytical view of the business.
-- Refreshed by usp_state_refresh (called from usp_state_refresh_full).
-- =============================================

-- Active MO Summary (joins picklist + header)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'st_mo_active' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.st_mo_active
    (
        MANUFACTUREORDER_I  INT             NOT NULL,
        WORKORDERNUMBER     VARCHAR(50)     NOT NULL,
        ITEMNMBR            VARCHAR(31)     NULL,
        LOCNCODE            VARCHAR(31)     NULL,
        STATUS              SMALLINT        NULL,
        MANUFACTUREORDERT   SMALLINT        NULL,
        DUEDATE             DATETIME        NULL,
        STARTDATE           DATETIME        NULL,
        TRACK               SMALLINT        NULL,
        QTYORDER            NUMERIC(19,5)   NULL,
        QTYREMAINING        NUMERIC(19,5)   NULL,
        QTYCOMPLETED        NUMERIC(19,5)   NULL,
        QTYREJECTED         NUMERIC(19,5)   NULL,
        PICKLISTCOUNT       INT             NULL,
        REVISION            VARCHAR(50)     NULL,
        LOTATTRIBUTE1       VARCHAR(50)     NULL,
        LOTATTRIBUTE2       VARCHAR(50)     NULL,
        LOTATTRIBUTE3       VARCHAR(50)     NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- PO Line Enriched (detail + header join)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'st_po_line' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.st_po_line
    (
        PONUMBER            VARCHAR(17)     NOT NULL,
        POLNESTA            SMALLINT        NOT NULL,
        POSTATUS            SMALLINT        NULL,
        VENDORID            VARCHAR(15)     NULL,
        VENDNAME            VARCHAR(65)     NULL,
        ITEMNMBR            VARCHAR(31)     NULL,
        ITEMDESC            VARCHAR(101)    NULL,
        LOCNCODE            VARCHAR(31)     NULL,
        UOFM                VARCHAR(9)      NULL,
        QTYORDER            NUMERIC(19,5)   NULL,
        QTYRCVD             NUMERIC(19,5)   NULL,
        QTYCANCE            NUMERIC(19,5)   NULL,
        QTYUNCMTBASE        NUMERIC(19,5)   NULL,
        UNITCOST            NUMERIC(19,5)   NULL,
        EXTDCOST            NUMERIC(19,5)   NULL,
        REQDATETIME         DATETIME        NULL,
        DUEDATE             DATETIME        NULL,
        TRACK               SMALLINT        NULL,
        MILESTONEVALUE      INT             NULL,
        MILESTONEDATE       DATETIME        NULL,
        REFTONMBRS          VARCHAR(50)     NULL,
        ORD                 INT             NULL,
        BCKTYEAR_I          SMALLINT        NULL,
        BCKTPERIOD_I        SMALLINT        NULL,
        LOTATTRIBUTE1       VARCHAR(50)     NULL,
        LOTATTRIBUTE2       VARCHAR(50)     NULL,
        LOTATTRIBUTE3       VARCHAR(50)     NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- Item Master Enriched (item + qty + vendor + BOM context)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'st_item_master' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.st_item_master
    (
        ITEMNMBR            VARCHAR(31)     NOT NULL,
        ITEMDESC            VARCHAR(101)    NULL,
        ITMSHNAM            VARCHAR(16)     NULL,
        ITEMSHWT            NUMERIC(19,5)   NULL,
        ITMSHWTUOM          SMALLINT        NULL,
        STNDCOST            NUMERIC(19,5)   NULL,
        CURRCOST            NUMERIC(19,5)   NULL,
        ITEMSHWTDSCR        VARCHAR(510)    NULL,
        DECPLQTY            INT             NULL,
        DECPLCUR            INT             NULL,
        ITEMSCHCAT_I        INT             NULL,
        ITEMTYPE            SMALLINT        NULL,
        INACTIVE            SMALLINT        NULL,
        STKAVLBL            NUMERIC(19,5)   NULL,
        COMMCODE_I          INT             NULL,
        TAXOPTNS            SMALLINT        NULL,
        IVCOGSIX            INT             NULL,
        IVSLSIDX            INT             NULL,
        IVALIASIX           INT             NULL,
        IVVARIX             INT             NULL,
        MSTRCDTY            SMALLINT        NULL,
        MODIFDT             DATETIME        NULL,
        CREATEDDT           DATETIME        NULL,
        PRIMARYVENDORID     VARCHAR(15)     NULL,
        PRIMARYVENDNAME     VARCHAR(65)     NULL,
        LEADTIME            INT             NULL,
        MINORDERQTY         NUMERIC(19,5)   NULL,
        MAXORDERQTY         NUMERIC(19,5)   NULL,
        ECONORDERQTY        NUMERIC(19,5)   NULL,
        VNDPRCTNM           NUMERIC(19,5)   NULL,
        BOM_COUNT           INT             NULL,
        BOM_TOTAL_QTY       NUMERIC(19,5)   NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- Lot Master Enriched (lot + item + vendor context)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'st_lot_status' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.st_lot_status
    (
        LOTNUMBR            VARCHAR(31)     NOT NULL,
        ITEMNMBR            VARCHAR(31)     NOT NULL,
        LOCNCODE            VARCHAR(31)     NULL,
        LOTATTRIBUTE1       VARCHAR(50)     NULL,
        LOTATTRIBUTE2       VARCHAR(50)     NULL,
        LOTATTRIBUTE3       VARCHAR(50)     NULL,
        TRK_LOT_USERDEF_1   VARCHAR(50)     NULL,
        TRK_LOT_USERDEF_2   VARCHAR(50)     NULL,
        QUANTITY            NUMERIC(19,5)   NULL,
        DATERECD            DATETIME        NULL,
        DUEDATE             DATETIME        NULL,
        EXPDATE             DATETIME        NULL,
        LOTSTATUS           SMALLINT        NULL,
        HOLDSTS             SMALLINT        NULL,
        ITEMDESC            VARCHAR(101)    NULL,
        VENDORID            VARCHAR(15)     NULL,
        VENDNAME            VARCHAR(65)     NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

-- Vendor Performance Summary (vendor + PO aggregate)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'st_vendor_perf' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.st_vendor_perf
    (
        VENDORID            VARCHAR(15)     NOT NULL,
        VENDNAME            VARCHAR(65)     NULL,
        VNDCLSID            VARCHAR(10)     NULL,
        VNDSTID             VARCHAR(15)     NULL,
        VNDSTNUM            VARCHAR(15)     NULL,
        VNDPHNUM            VARCHAR(21)     NULL,
        VNDFAX              VARCHAR(21)     NULL,
        VNDCRCRD            VARCHAR(21)     NULL,
        CURNCYID            VARCHAR(15)     NULL,
        INACTIVE            SMALLINT        NULL,
        MINPYMTTYP          SMALLINT        NULL,
        MINPYDLRNT          INT             NULL,
        MAXPYMTTYP          SMALLINT        NULL,
        PYMTRMID            INT             NULL,
        CHKACTINDX          INT             NULL,
        OPENPO_COUNT        INT             NULL,
        OPENPO_TOTAL        NUMERIC(19,5)   NULL,
        LAST_PO_DATE        DATETIME        NULL,
        CREATEDDATETIME     DATETIME        NULL,
        MODIFIEDDATETIME    DATETIME        NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE()
    );
END
GO