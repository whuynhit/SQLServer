-- Queries for information of all Columns from all Tables of all User Databases
DECLARE @DatabaseName NVARCHAR(255)
DECLARE @SQL NVARCHAR(MAX)


-- Step 1: Declare cursor for user databases
DECLARE db_cursor CURSOR FOR
SELECT name 
FROM sys.databases 
WHERE database_id > 4 
  AND state_desc = 'ONLINE'

-- Step 2: Open cursor
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @DatabaseName

-- Step 3: Loop through each database
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Build dynamic SQL using 3-part naming (db.schema.table)
    SET @SQL = '
	DECLARE @ServerName AS VARCHAR(128) = UPPER(CAST(SERVERPROPERTY(''MachineName'') AS nvarchar(128)));
    SELECT 
			@ServerName [Server Name], 
			(SELECT dec.local_net_address
			FROM sys.dm_exec_connections AS dec
			WHERE dec.session_id = @@SPID) AS [IP Address],
			CASE
			WHEN @ServerName LIKE ''%P[0-9][0-9]%'' THEN ''PRD''
			WHEN @ServerName LIKE ''%T[0-9][0-9]%'' THEN ''UAT''
			WHEN @ServerName LIKE ''%D[0-9][0-9]%'' THEN ''DEV''
			ELSE ''Unknown ENV''
			END AS ENV,
			''' + @DatabaseName + ''' AS DatabaseName,
           TABLE_SCHEMA,
           TABLE_NAME,
           COLUMN_NAME,
           DATA_TYPE
    FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS;'

    BEGIN TRY
        EXEC(@SQL)
    END TRY
    BEGIN CATCH
        PRINT 'Error accessing database: ' + @DatabaseName + ' - ' + ERROR_MESSAGE()
    END CATCH

    FETCH NEXT FROM db_cursor INTO @DatabaseName
END

-- Step 4: Cleanup
CLOSE db_cursor
DEALLOCATE db_cursor
