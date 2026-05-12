-- Milestone 01: Landing — Smoke Test
-- Validates the project scaffold and baseline assumptions.

-- ============================================
-- CONFIG
-- ============================================
DECLARE @EXPECTED_DB_NAME SYSNAME = DB_NAME();

-- ============================================
-- TEST 1: Verify we are connected to the right database
-- ============================================
PRINT 'TEST 1: Database context check...';
SELECT @EXPECTED_DB_NAME AS [database_name];

-- ============================================
-- TEST 2: Verify key MED/GP tables exist
-- ============================================
PRINT 'TEST 2: MED/GP table existence check...';
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME IN ('WO010302', 'PM00200', 'IV00103', 'IV00102', 'POP30310');

-- ============================================
-- TEST 3: Verify key columns on WO010302 (MO Picklist)
-- ============================================
PRINT 'TEST 3: MO Picklist column existence...';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'WO010302'
  AND COLUMN_NAME IN ('QTYPENDING', 'STRTDATE', 'ENDQTY_I', 'MANUFACTUREORDERST_I');

-- ============================================
-- TEST 4: Verify key columns on POP30310 (PO Receipt Work)
-- ============================================
PRINT 'TEST 4: PO Receipt Work column existence...';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'POP30310'
  AND COLUMN_NAME IN ('POSTATUS', 'POLNESTA', 'QTYUNCMTBASE');

-- ============================================
-- TEST 5: Verify inventory columns
-- ============================================
PRINT 'TEST 5: Inventory column existence...';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'IV00102'
  AND COLUMN_NAME IN ('QTYONHND', 'NONINVEN', 'ITMCLSCD');

PRINT 'All smoke tests complete.';
GO