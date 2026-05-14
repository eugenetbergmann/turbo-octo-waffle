-- MILESTONE: 01
-- OBJECT: usp_state_refresh_full
-- DESCRIPTION: Full orchestration proc — calls all replication procs in dependency order
-- STATUS: active

CREATE PROCEDURE dbo.usp_state_refresh_full
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- 1. Replicate reference data (no dependencies)
        EXEC dbo.usp_rep_log 'ORCHESTRATION', 'usp_state_refresh_full started', 'START';

        EXEC dbo.usp_replicate_items;
        EXEC dbo.usp_replicate_bom;
        EXEC dbo.usp_replicate_vendor;
        EXEC dbo.usp_replicate_lots;

        -- 2. Replicate transactional data (depends on reference data for joins)
        EXEC dbo.usp_replicate_po_header;
        EXEC dbo.usp_replicate_po_detail;
        EXEC dbo.usp_replicate_mo_header;
        EXEC dbo.usp_replicate_mo_picklist;

        -- 3. Refresh state views
        EXEC dbo.usp_state_refresh;

        EXEC dbo.usp_rep_log 'ORCHESTRATION', 'usp_state_refresh_full completed', 'SUCCESS';
    END TRY
    BEGIN CATCH
        EXEC dbo.usp_rep_log 'ORCHESTRATION', 'usp_state_refresh_full FAILED', 'ERROR';
        THROW;
    END CATCH
END
GO