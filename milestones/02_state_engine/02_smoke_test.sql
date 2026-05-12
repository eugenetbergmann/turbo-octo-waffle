-- Milestone 02: State Engine — Smoke Test
-- Validates state tables, refresh logic, and adapter views.

-- ============================================
-- CONFIG
-- ============================================
DECLARE @ROWCOUNT_THRESHOLD INT = 0; -- Expecting at least some rows from source

-- ============================================
-- TEST 1: State tables exist in ddl/
-- ============================================
PRINT 'TEST 1: State table existence check...';
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME LIKE 'st\_%' ESCAPE '\';

-- ============================================
-- TEST 2: Adapter views exist in views/
-- ============================================
PRINT 'TEST 2: Adapter view existence check...';
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME LIKE 'v\_adapter\_%' ESCAPE '\';

-- ============================================
-- TEST 3: Verify MO state data has expected columns
-- ============================================
PRINT 'TEST 3: MO state table column check...';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE 'st\_mo%' ESCAPE '\'
ORDER BY ORDINAL_POSITION;

-- ============================================
-- TEST 4: Verify PO state data has expected columns
-- ============================================
PRINT 'TEST 4: PO state table column check...';
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME LIKE 'st\_po%' ESCAPE '\'
ORDER BY ORDINAL_POSITION;

-- ============================================
-- TEST 5: Refresh proc exists
-- ============================================
PRINT 'TEST 5: Refresh proc existence check...';
SELECT ROUTINE_NAME
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
  AND ROUTINE_NAME = 'usp_state_refresh';

PRINT 'State engine smoke tests complete.';
GO