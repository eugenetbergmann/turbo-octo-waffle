-- MILESTONE: 01
-- OBJECT: usp_replicate_lots
-- DESCRIPTION: Replicate Lot Master (LOTMAST) into h_lot_master.
--              Filters NONINVEN = 0 per convention.
-- STATUS: active

CREATE PROCEDURE dbo.usp_replicate_lots
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH config AS (
        SELECT NONINVEN = 0
    )

    INSERT INTO dbo.h_lot_master (
        LOTNUMBR, ITEMNMBR, LOCNCODE, LOTATTRIBUTE1, LOTATTRIBUTE2,
        LOTATTRIBUTE3, TRK_LOT_USERDEF_1, TRK_LOT_USERDEF_2,
        QUANTITY, DATERECD, DUEDATE, EXPDATE, LOTSTATUS, HOLDSTS,
        DATETIMESTAMP
    )
    SELECT
        src.LOTNUMBR, src.ITEMNMBR, src.LOCNCODE, src.LOTATTRIBUTE1, src.LOTATTRIBUTE2,
        src.LOTATTRIBUTE3, src.TRK_LOT_USERDEF_1, src.TRK_LOT_USERDEF_2,
        src.QUANTITY, src.DATERECD, src.DUEDATE, src.EXPDATE, src.LOTSTATUS, src.HOLDSTS,
        GETUTCDATE()
    FROM dbo.LOTMAST AS src
    CROSS JOIN config
    WHERE src.NONINVEN = config.NONINVEN
      AND NOT EXISTS (
          SELECT 1 FROM dbo.h_lot_master AS tgt
          WHERE tgt.LOTNUMBR = src.LOTNUMBR AND tgt.ITEMNMBR = src.ITEMNMBR
      );

    EXEC dbo.usp_rep_log;
END
GO