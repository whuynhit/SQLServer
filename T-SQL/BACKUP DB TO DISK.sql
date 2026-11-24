-- Queries for information of all Columns from all Tables of all User Databases
DECLARE @DatabaseName NVARCHAR(255)
DECLARE @SQL NVARCHAR(MAX)
DECLARE @BackupDir NVARCHAR(256) = '\\<Server>\<Network Shared Folder>\<Folder>';
DECLARE @Timestamp NVARCHAR(15) = CONCAT(
CONVERT(NVARCHAR(8), CURRENT_TIMESTAMP, 112), '_' , 
REPLACE(CONVERT(NVARCHAR(8), CURRENT_TIMESTAMP, 108), ':', ''));

-- Step 1: Declare cursor for user databases
DECLARE db_cursor CURSOR FOR
SELECT name 
FROM sys.databases 
WHERE state_desc = 'ONLINE'
AND name != 'tempdb';

-- Step 2: Open cursor
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName;

-- Step 3: Loop through each database
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Build dynamic SQL
    SET @SQL = '
        -- Optional - run the following to create new subdirectory:
        -- EXEC master.dbo.xp_create_subdir ''\\<Server>\<Network Shared Folder>\<Folder>'';

        BACKUP DATABASE [' + @DatabaseName + ']
        TO DISK = ''' + @BackupDir + @DatabaseName + '_db_bkup_' + @Timestamp + '.bak''
        WITH COPY_ONLY;';

    BEGIN TRY
        EXEC(@SQL);
    END TRY
    BEGIN CATCH
        PRINT 'Error accessing database: ' + @DatabaseName + ' - ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

-- Step 4: Cleanup
CLOSE db_cursor;
DEALLOCATE db_cursor;
