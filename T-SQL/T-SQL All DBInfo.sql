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
    SELECT ''' + @DatabaseName + ''' AS DatabaseName,
           TABLE_SCHEMA,
           TABLE_NAME,
           COLUMN_NAME,
           DATA_TYPE
    FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.COLUMNS
    WHERE COLUMN_NAME LIKE ''%email%'' 
       OR COLUMN_NAME LIKE ''%ssn%''
       OR COLUMN_NAME LIKE ''%name%''
       OR COLUMN_NAME LIKE ''%dob%''
       OR COLUMN_NAME LIKE ''%phone%''
       OR COLUMN_NAME LIKE ''%address%'';'

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
