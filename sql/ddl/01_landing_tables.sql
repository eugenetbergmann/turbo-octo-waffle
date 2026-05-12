-- MILESTONE: 01
-- OBJECT: h_landing_tables_ddl
-- DESCRIPTION: Create landing (h_) tables that mirror MED/GP source tables for replication.
-- STATUS: active

-- =============================================
-- Landing Tables — Solid Waddle Carlsbad
-- =============================================
-- These tables receive replicated data from MED/GP via usp_replicate_*.
-- Pattern: append-only, IF NOT EXISTS, no UPDATE/DELETE.
-- =============================================

-- MO Picklist (WO010302)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_mo_picklist' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_mo_picklist
    (
        PICKLISTNUMBER      INT             NOT NULL,
        MANUFACTUREORDER_I  INT             NOT NULL,
        WORKORDERNUMBER     VARCHAR(50)     NOT NULL,
        LOCNCODE            VARCHAR(31)     NULL,
        QUANTITY            NUMERIC(19,5)   NULL,
        ITEMNMBR            VARCHAR(31)     NULL,
        UOFM                VARCHAR(9)      NULL,
        DUEDATE             DATETIME        NULL,
        STATUS              SMALLINT        NULL,
        BINREFERENCE        VARCHAR(255)    NULL,
        CREATEDDATETIME     DATETIME        NULL,
        MODIFIEDDATETIME    DATETIME        NULL,
        SUPPLIERID          VARCHAR(15)     NULL,
        PURCHASEORDER_I     INT             NULL,
        PURCHASEORDERLN_I   INT             NULL,
        MILESTONEVALUE      INT             NULL,
        MILESTONEDATE       DATETIME        NULL,
        REVISION            VARCHAR(50)     NULL,
        LOTATTRIBUTE1       VARCHAR(50)     NULL,
        LOTATTRIBUTE2       VARCHAR(50)     NULL,
        LOTATTRIBUTE3       VARCHAR(50)     NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_mo_picklist PRIMARY KEY CLUSTERED (PICKLISTNUMBER, MANUFACTUREORDER_I)
    );
END
GO

-- MO Header (MOP10100)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_mo_header' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_mo_header
    (
        MANUFACTUREORDER_I  INT             NOT NULL,
        WORKORDERNUMBER     VARCHAR(50)     NOT NULL,
        STATUS              SMALLINT        NULL,
        MANUFACTUREORDERT   SMALLINT        NULL,
        ITEMNMBR            VARCHAR(31)     NULL,
        LOCNCODE            VARCHAR(31)     NULL,
        DUEDATE             DATETIME        NULL,
        STARTDATE           DATETIME        NULL,
        TRACK               SMALLINT        NULL,
        FGIINDX             INT             NULL,
        FGNINDX             INT             NULL,
        SCRAPAMNT           NUMERIC(19,5)   NULL,
        SOURCERES_I         INT             NULL,
        QTYORDER            NUMERIC(19,5)   NULL,
        QTYREMAINING        NUMERIC(19,5)   NULL,
        QTYCOMPLETED        NUMERIC(19,5)   NULL,
        QTYREJECTED         NUMERIC(19,5)   NULL,
        DATERECD            DATETIME        NULL,
        REFTONMBRS          VARCHAR(50)     NULL,
        BCKTYEAR_I          SMALLINT        NULL,
        BCKTPERIOD_I        SMALLINT        NULL,
        REVISION            VARCHAR(50)     NULL,
        LOTATTRIBUTE1       VARCHAR(50)     NULL,
        LOTATTRIBUTE2       VARCHAR(50)     NULL,
        LOTATTRIBUTE3       VARCHAR(50)     NULL,
        CREATEDDATETIME     DATETIME        NULL,
        MODIFIEDDATETIME    DATETIME        NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_mo_header PRIMARY KEY CLUSTERED (MANUFACTUREORDER_I)
    );
END
GO

-- MO Picklist Demand (WO010302 — demand side)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_mo_picklist_demand' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_mo_picklist_demand
    (
        PICKLISTNUMBER      INT             NOT NULL,
        MANUFACTUREORDER_I  INT             NOT NULL,
        WORKORDERNUMBER     VARCHAR(50)     NOT NULL,
        ITEMNMBR            VARCHAR(31)     NULL,
        LOCNCODE            VARCHAR(31)     NULL,
        LOTATTRIBUTE1       VARCHAR(50)     NULL,
        LOTATTRIBUTE2       VARCHAR(50)     NULL,
        LOTATTRIBUTE3       VARCHAR(50)     NULL,
        TRK_LOT_USERDEF_1   VARCHAR(50)     NULL,
        TRK_LOT_USERDEF_2   VARCHAR(50)     NULL,
        QUANTITY            NUMERIC(19,5)   NULL,
        UOFM                VARCHAR(9)      NULL,
        POSTATUS            SMALLINT        NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_mo_picklist_demand PRIMARY KEY CLUSTERED (PICKLISTNUMBER, MANUFACTUREORDER_I)
    );
END
GO

-- PO Header (POD10100)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_po_header' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_po_header
    (
        PONUMBER            VARCHAR(17)     NOT NULL,
        POSTATUS            SMALLINT        NOT NULL,
        VENDORID            VARCHAR(15)     NULL,
        VENDNAME            VARCHAR(65)     NULL,
        DOCAMNT             NUMERIC(19,5)   NULL,
        CURNCYID            VARCHAR(15)     NULL,
        ORSOURCEDOC         VARCHAR(50)     NULL,
        ORSOURCEREF         VARCHAR(50)     NULL,
        REQDATETIME         DATETIME        NULL,
        DUEDATE             DATETIME        NULL,
        SHIPMTHD            VARCHAR(15)     NULL,
        PAYMTHID            VARCHAR(21)     NULL,
        PRCLEVEL            SMALLINT        NULL,
        DATERECD            DATETIME        NULL,
        REFTONMBRS          VARCHAR(50)     NULL,
        BCKTYEAR_I          SMALLINT        NULL,
        BCKTPERIOD_I        SMALLINT        NULL,
        CREATEDDATETIME     DATETIME        NULL,
        MODIFIEDDATETIME    DATETIME        NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_po_header PRIMARY KEY CLUSTERED (PONUMBER)
    );
END
GO

-- PO Detail (POD10110)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_po_detail' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_po_detail
    (
        PONUMBER            VARCHAR(17)     NOT NULL,
        POLNESTA            SMALLINT        NOT NULL,
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
        POSTATUS            SMALLINT        NULL,
        ORD                 INT             NULL,
        BCKTYEAR_I          SMALLINT        NULL,
        BCKTPERIOD_I        SMALLINT        NULL,
        LOTATTRIBUTE1       VARCHAR(50)     NULL,
        LOTATTRIBUTE2       VARCHAR(50)     NULL,
        LOTATTRIBUTE3       VARCHAR(50)     NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_po_detail PRIMARY KEY CLUSTERED (PONUMBER, POLNESTA)
    );
END
GO

-- Item Master (IV00101)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_item_master' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_item_master
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
        STKAVLBL            NUMERIC(19,5)   NULL,
        COMMCODE_I          INT             NULL,
        TAXOPTNS            SMALLINT        NULL,
        IVCOGSIX            INT             NULL,
        IVSLSIDX            INT             NULL,
        IVALIASIX           INT             NULL,
        IVVARIX             INT             NULL,
        INACTIVE            SMALLINT        NULL,
        MSTRCDTY            SMALLINT        NULL,
        MODIFDT             DATETIME        NULL,
        CREATEDDT           DATETIME        NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_item_master PRIMARY KEY CLUSTERED (ITEMNMBR)
    );
END
GO

-- Item Qty (IV00102)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_item_qty' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_item_qty
    (
        ITEMNMBR            VARCHAR(31)     NOT NULL,
        LOCNCODE            VARCHAR(31)     NOT NULL,
        UOFM                VARCHAR(9)      NOT NULL,
        QTYTYPE             SMALLINT        NOT NULL,
        TRK_LOT_USERDEF_1   VARCHAR(50)     NULL,
        TRK_LOT_USERDEF_2   VARCHAR(50)     NULL,
        ATYALLOC            NUMERIC(19,5)   NULL,
        QTYONHND            NUMERIC(19,5)   NULL,
        QTYINSPECT          NUMERIC(19,5)   NULL,
        QTYINUSE            NUMERIC(19,5)   NULL,
        QTYDMGED            NUMERIC(19,5)   NULL,
        QTYRSVD             NUMERIC(19,5)   NULL,
        QTYBACKORD          NUMERIC(19,5)   NULL,
        QTYAVAIL            NUMERIC(19,5)   NULL,
        DECPLQTY            INT             NULL,
        EXCESSALLOCQTY_I    NUMERIC(19,5)   NULL,
        ALLOCABAL           NUMERIC(19,5)   NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_item_qty PRIMARY KEY CLUSTERED (ITEMNMBR, LOCNCODE, UOFM, QTYTYPE)
    );
END
GO

-- Item-Vendor Cross Reference (IV00103)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_item_vendor_xref' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_item_vendor_xref
    (
        VENDORID            VARCHAR(15)     NOT NULL,
        ITEMNMBR            VARCHAR(31)     NOT NULL,
        VENDNAME            VARCHAR(65)     NULL,
        ITMVNPNMBR          VARCHAR(31)     NULL,
        ITEMDESC            VARCHAR(101)    NULL,
        CURRCOST            NUMERIC(19,5)   NULL,
        DECPLCUR            INT             NULL,
        LEADTIME            INT             NULL,
        MINORDERQTY         NUMERIC(19,5)   NULL,
        MAXORDERQTY         NUMERIC(19,5)   NULL,
        ECONORDERQTY        NUMERIC(19,5)   NULL,
        PRIMARYVENDOR       SMALLINT        NULL,
        VNDPRCTNM           NUMERIC(19,5)   NULL,
        UOFM                VARCHAR(9)      NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_item_vendor_xref PRIMARY KEY CLUSTERED (VENDORID, ITEMNMBR)
    );
END
GO

-- Bill of Materials Master (BM00101)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_bom_master' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_bom_master
    (
        BILLTYPE_I          INT             NOT NULL,
        WORKORDERNUMBER     VARCHAR(50)     NOT NULL,
        ITEMNMBR            VARCHAR(31)     NOT NULL,
        REVNO_I             INT             NOT NULL,
        BOMNOTE_I           INT             NULL,
        LOWLEVEL            INT             NULL,
        UOFM                VARCHAR(9)      NULL,
        QTYORDER            NUMERIC(19,5)   NULL,
        DATERECD            DATETIME        NULL,
        REFTONMBRS          VARCHAR(50)     NULL,
        BCKTYEAR_I          SMALLINT        NULL,
        BCKTPERIOD_I        SMALLINT        NULL,
        CREATEDDATETIME     DATETIME        NULL,
        MODIFIEDDATETIME    DATETIME        NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_bom_master PRIMARY KEY CLUSTERED (BILLTYPE_I, WORKORDERNUMBER, ITEMNMBR, REVNO_I)
    );
END
GO

-- BOM Component (BM00111)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_bom_component' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_bom_component
    (
        BILLTYPE_I          INT             NOT NULL,
        WORKORDERNUMBER     VARCHAR(50)     NOT NULL,
        ITEMNMBR            VARCHAR(31)     NOT NULL,
        COMPONENTITEM       VARCHAR(31)     NOT NULL,
        REVNO_I             INT             NOT NULL,
        OPRNSEQNC_I         INT             NOT NULL,
        QUANTITY            NUMERIC(19,5)   NULL,
        UOFM                VARCHAR(9)      NULL,
        LOTATTRIBUTE1       VARCHAR(50)     NULL,
        LOTATTRIBUTE2       VARCHAR(50)     NULL,
        LOTATTRIBUTE3       VARCHAR(50)     NULL,
        TRACK               SMALLINT        NULL,
        SCRAPAMNT           NUMERIC(19,5)   NULL,
        BCKTYEAR_I          SMALLINT        NULL,
        BCKTPERIOD_I        SMALLINT        NULL,
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_bom_component PRIMARY KEY CLUSTERED (BILLTYPE_I, WORKORDERNUMBER, ITEMNMBR, COMPONENTITEM, REVNO_I, OPRNSEQNC_I)
    );
END
GO

-- Lot Master (LOTMAST)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_lot_master' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_lot_master
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
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_lot_master PRIMARY KEY CLUSTERED (LOTNUMBR, ITEMNMBR)
    );
END
GO

-- Vendor Master (PM00200)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'h_vendor_master' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.h_vendor_master
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
        DATETIMESTAMP       DATETIME        NOT NULL DEFAULT GETUTCDATE(),
        CONSTRAINT PK_h_vendor_master PRIMARY KEY CLUSTERED (VENDORID)
    );
END
GO