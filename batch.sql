--SELECT * FROM dbo.Files_Temporary

--UPDATE dbo.Files_Temporary	
--SET localstart = null,
--localComplete = null,
--RemoteStart = null,
--RemoteComplete = NULL

--EXEC PlanData



IF OBJECT_ID('tempdb..#temp', 'U') IS NOT NULL
	DROP TABLE #temp

CREATE TABLE #temp (DataYear int)
--INSERT INTO #temp (DataYear) VALUES (2017),(2016),(2015),(2014),(2013)
INSERT INTO #temp (DataYear) VALUES (2016),(2015),(2014),(2013)

WHILE (SELECT COUNT(*) FROM #temp) > 0
BEGIN 
	DECLARE @DataYear int
	SET @DataYear = (SELECT TOP 1 DataYear FROM #temp ORDER BY DataYear DESC)

	DECLARE @Msg NVARCHAR(255)
	SET @Msg = 'Working on data year ' +convert(varchar,@DataYear)
	RAISERROR (@Msg, 0, 1) WITH NOWAIT

	UPDATE dbo.Files_Temporary	SET localstart = 1 WHERE DataYear = @DataYear

	EXEC LoadData

	IF @DataYear = 2017
		EXEC TransferTables 0
	ELSE
		EXEC TransferTables 1

	DELETE FROM #temp WHERE DataYear = (@DataYear)
END 




