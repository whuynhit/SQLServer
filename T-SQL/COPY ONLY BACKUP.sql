-- Optional - run the following to create new subdirectory:
-- EXEC master.dbo.xp_create_subdir '\\<Server>\<Network Shared Folder>\<Folder>\';
-- Generate Copy-Only BACKUP command based on existing databases
DECLARE @location NVARCHAR(256) = '\\<Server>\<Network Shared Folder>\<Folder>\';
SELECT 
	CONCAT_WS(
	CHAR(13) + CHAR(10),
	CONCAT('BACKUP DATABASE ', name), 
	CONCAT('TO DISK = ''', @location, name, '_db_backup.bak'''),
	'WITH COPY_ONLY;'
	)
FROM sys.databases
WHERE database_id > 4
ORDER BY name;
