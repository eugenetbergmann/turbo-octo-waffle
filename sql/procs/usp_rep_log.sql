-- MILESTONE: 01
-- OBJECT: usp_rep_log
-- DESCRIPTION: Shared replication audit log. Called at end of every replication/state proc.
-- STATUS: active

CREATE PROCEDURE dbo.usp_rep_log
    @SourceSystem  VARCHAR(50),
    @Action        VARCHAR(100),
    @Status        VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'replication_log' AND schema_id = SCHEMA_ID('dbo'))
    BEGIN
        CREATE TABLE dbo.replication_log
        (
            LogID           INT IDENTITY(1,1) PRIMARY KEY,
            SourceSystem    VARCHAR(50)    NOT NULL,
            Action          VARCHAR(100)   NOT NULL,
            Status          VARCHAR(20)    NOT NULL,
            LogDate         DATETIME       NOT NULL DEFAULT GETUTCDATE(),
            BatchID         UNIQUEIDENTIFIER DEFAULT NEWID()
        );
    END

    INSERT INTO dbo.replication_log (SourceSystem, Action, Status)
    VALUES (@SourceSystem, @Action, @Status);
END
GO