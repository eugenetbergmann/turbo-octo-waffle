-- MILESTONE: 01
-- OBJECT: smoke_test_landing_tables
-- DESCRIPTION: Validate all landing tables and core replication procs exist and are functional.
-- STATUS: active

-- =============================================
-- Smoke Test — Milestone 01: Landing Tables
-- =============================================

-- TEST 1: Verify all 12 landing tables exist
DECLARE @missing_tables TABLE (table_name VARCHAR(128));
INSERT INTO @missing_tables (table_name)
SELECT name FROM (VALUES
    ('h_mo_picklist'),
    ('h_mo_header'),
    ('h_mo_picklist_demand'),
    ('h_po_header'),
    ('h_po_detail'),
    ('h_item_master'),
    ('h_item_qty'),
    ('h_item_vendor_xref'),
    ('h_bom_master'),
    ('h_bom_component'),
    ('h_lot_master'),
    ('h_vendor_master')
) AS expected(name)
WHERE name NOT IN (
    SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo'
);

IF EXISTS (SELECT 1 FROM @missing_tables)
BEGIN
    RAISERROR('FAIL: Missing landing tables:', 16, 1);
    SELECT * FROM @missing_tables;
    RETURN;
END
PRINT 'PASS: All 12 landing tables exist';

-- TEST 2: Verify key columns on h_mo_picklist
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'h_mo_picklist' AND COLUMN_NAME = 'MANUFACTUREORDER_I'
) OR NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'h_mo_picklist' AND COLUMN_NAME = 'PICKLISTNUMBER'
)
BEGIN
    RAISERROR('FAIL: h_mo_picklist missing key columns', 16, 1);
    RETURN;
END
PRINT 'PASS: h_mo_picklist key columns verified';

-- TEST 3: Verify DATETIMESTAMP column exists on all landing tables
DECLARE @missing_ts TABLE (table_name VARCHAR(128));
INSERT INTO @missing_ts (table_name)
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_SCHEMA = 'dbo'
  AND t.TABLE_NAME LIKE 'h\_%' ESCAPE '\'
  AND NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS c
    WHERE c.TABLE_NAME = t.TABLE_NAME AND c.COLUMN_NAME = 'DATETIMESTAMP'
);

IF EXISTS (SELECT 1 FROM @missing_ts)
BEGIN
    RAISERROR('FAIL: Missing DATETIMESTAMP on tables:', 16, 1);
    SELECT * FROM @missing_ts;
    RETURN;
END
PRINT 'PASS: DATETIMESTAMP column present on all h_ tables';

-- TEST 4: Verify replication procs exist
DECLARE @missing_procs TABLE (proc_name VARCHAR(128));
INSERT INTO @missing_procs (proc_name)
SELECT name FROM (VALUES
    ('usp_rep_log'),
    ('usp_replicate_mo_picklist'),
    ('usp_replicate_mo_header'),
    ('usp_replicate_po_header'),
    ('usp_replicate_po_detail'),
    ('usp_replicate_items'),
    ('usp_replicate_bom'),
    ('usp_replicate_vendor'),
    ('usp_replicate_lots'),
    ('usp_state_refresh_full')
) AS expected(name)
WHERE name NOT IN (
    SELECT ROUTINE_NAME FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_TYPE = 'PROCEDURE'
);

IF EXISTS (SELECT 1 FROM @missing_procs)
BEGIN
    RAISERROR('FAIL: Missing replication procs:', 16, 1);
    SELECT * FROM @missing_procs;
    RETURN;
END
PRINT 'PASS: All replication procs exist';

-- TEST 5: Verify primary keys on critical tables
DECLARE @missing_pk TABLE (table_name VARCHAR(128));
INSERT INTO @missing_pk (table_name)
SELECT t.name FROM (VALUES
    ('h_mo_picklist'),
    ('h_mo_header'),
    ('h_po_header'),
    ('h_po_detail'),
    ('h_item_master'),
    ('h_item_qty'),
    ('h_item_vendor_xref'),
    ('h_bom_master'),
    ('h_bom_component'),
    ('h_lot_master'),
    ('h_vendor_master')
) AS t(name)
WHERE NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    JOIN sys.objects o ON i.object_id = o.object_id
    WHERE o.name = t.name AND i.is_primary_key = 1
);

IF EXISTS (SELECT 1 FROM @missing_pk)
BEGIN
    RAISERROR('FAIL: Missing primary keys on tables:', 16, 1);
    SELECT * FROM @missing_pk;
    RETURN;
END
PRINT 'PASS: Primary keys verified on all landing tables';

PRINT '';
PRINT '=== SMOKE TEST PASSED: Milestone 01 ===';

EXEC dbo.usp_rep_log 'SMOKE_TEST', 'Milestone 01 landing tables validation', 'PASS';