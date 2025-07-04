-- Check Assigned Data Classifications of all Columns in all Tables for all User Databases
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
	USE ' + QUOTENAME(@DatabaseName) + ';
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
			SCHEMA_NAME(sys.all_objects.schema_id) as SchemaName,
			sys.all_objects.name AS [TableName], 
			sys.all_columns.name As [ColumnName],
			[Label], 
			[Label_ID], 
			[Information_Type], 
			[Information_Type_ID], 
			[Rank], 
			[Rank_Desc]
	FROM
          sys.sensitivity_classifications
	left join sys.all_objects 
	on sys.sensitivity_classifications.major_id = sys.all_objects.object_id
	left join sys.all_columns 
	on sys.sensitivity_classifications.major_id = sys.all_columns.object_id 
	and sys.sensitivity_classifications.minor_id = sys.all_columns.column_id
'

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
