-- MILESTONE: 02
-- OBJECT: smoke_test_state_tables
-- DESCRIPTION: Validate all state tables and the usp_state_refresh procedure exist and are functional.
-- STATUS: active

-- =============================================
-- Smoke Test — Milestone 02: Core State Tables
-- =============================================

-- TEST 1: Verify all 5 state tables exist
DECLARE @missing_tables TABLE (table_name VARCHAR(128));
INSERT INTO @missing_tables (table_name)
SELECT name FROM (VALUES
    ('st_mo_active'),
    ('st_po_line'),
    ('st_item_master'),
    ('st_lot_status'),
    ('st_vendor_perf')
) AS expected(name)
WHERE name NOT IN (
    SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo'
);

IF EXISTS (SELECT 1 FROM @missing_tables)
BEGIN
    RAISERROR('FAIL: Missing state tables:', 16, 1);
    SELECT * FROM @missing_tables;
    RETURN;
END
PRINT 'PASS: All 5 state tables exist';

-- TEST 2: Verify usp_state_refresh proc exists
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_TYPE = 'PROCEDURE' AND ROUTINE_NAME = 'usp_state_refresh'
)
BEGIN
    RAISERROR('FAIL: usp_state_refresh procedure missing', 16, 1);
    RETURN;
END
PRINT 'PASS: usp_state_refresh proc exists';

-- TEST 3: Verify key columns on st_mo_active
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_mo_active' AND COLUMN_NAME = 'MANUFACTUREORDER_I'
) OR NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_mo_active' AND COLUMN_NAME = 'PICKLISTCOUNT'
)
BEGIN
    RAISERROR('FAIL: st_mo_active missing key columns', 16, 1);
    RETURN;
END
PRINT 'PASS: st_mo_active key columns verified';

-- TEST 4: Verify key columns on st_po_line
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_po_line' AND COLUMN_NAME = 'PONUMBER'
) OR NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_po_line' AND COLUMN_NAME = 'QTYUNCMTBASE'
)
BEGIN
    RAISERROR('FAIL: st_po_line missing key columns', 16, 1);
    RETURN;
END
PRINT 'PASS: st_po_line key columns verified';

-- TEST 5: Verify key columns on st_item_master
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_item_master' AND COLUMN_NAME = 'ITEMNMBR'
) OR NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_item_master' AND COLUMN_NAME = 'PRIMARYVENDORID'
)
BEGIN
    RAISERROR('FAIL: st_item_master missing key columns', 16, 1);
    RETURN;
END
PRINT 'PASS: st_item_master key columns verified';

-- TEST 6: Verify key columns on st_lot_status
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_lot_status' AND COLUMN_NAME = 'LOTNUMBR'
) OR NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_lot_status' AND COLUMN_NAME = 'ITEMDESC'
)
BEGIN
    RAISERROR('FAIL: st_lot_status missing key columns', 16, 1);
    RETURN;
END
PRINT 'PASS: st_lot_status key columns verified';

-- TEST 7: Verify key columns on st_vendor_perf
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_vendor_perf' AND COLUMN_NAME = 'VENDORID'
) OR NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'st_vendor_perf' AND COLUMN_NAME = 'OPENPO_COUNT'
)
BEGIN
    RAISERROR('FAIL: st_vendor_perf missing key columns', 16, 1);
    RETURN;
END
PRINT 'PASS: st_vendor_perf key columns verified';

-- TEST 8: Verify DATETIMESTAMP column on all state tables
DECLARE @missing_ts TABLE (table_name VARCHAR(128));
INSERT INTO @missing_ts (table_name)
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES t
WHERE t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_SCHEMA = 'dbo'
  AND t.TABLE_NAME LIKE 'st\_%' ESCAPE '\'
  AND NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS c
    WHERE c.TABLE_NAME = t.TABLE_NAME AND c.COLUMN_NAME = 'DATETIMESTAMP'
  );

IF EXISTS (SELECT 1 FROM @missing_ts)
BEGIN
    RAISERROR('FAIL: Missing DATETIMESTAMP on state tables:', 16, 1);
    SELECT * FROM @missing_ts;
    RETURN;
END
PRINT 'PASS: DATETIMESTAMP column present on all st_ tables';

-- TEST 9: Verify primary keys on all state tables
DECLARE @missing_pk TABLE (table_name VARCHAR(128));
INSERT INTO @missing_pk (table_name)
SELECT t.name FROM (VALUES
    ('st_mo_active'),
    ('st_po_line'),
    ('st_item_master'),
    ('st_lot_status'),
    ('st_vendor_perf')
) AS t(name)
WHERE NOT EXISTS (
    SELECT 1 FROM sys.indexes i
    JOIN sys.objects o ON i.object_id = o.object_id
    WHERE o.name = t.name AND i.is_primary_key = 1
);

IF EXISTS (SELECT 1 FROM @missing_pk)
BEGIN
    RAISERROR('FAIL: Missing primary keys on state tables:', 16, 1);
    SELECT * FROM @missing_pk;
    RETURN;
END
PRINT 'PASS: Primary keys verified on all state tables';

PRINT '';
PRINT '=== SMOKE TEST PASSED: Milestone 02 ===';

EXEC dbo.usp_rep_log 'SMOKE_TEST', 'Milestone 02 state tables validation', 'PASS';