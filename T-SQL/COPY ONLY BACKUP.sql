-- Generate Copy-Only BACKUP command based on existing databases
SELECT 
	CONCAT_WS(
	CHAR(13) + CHAR(10),
	CONCAT('BACKUP DATABASE ', name), 
	CONCAT('TO DISK = ''', '\\<Server>\<Network Shared Folder>\<Folder>\', name, '_copy_only.bak'''),
	'WITH COPY_ONLY;'
	)
FROM sys.databases
WHERE database_id > 4
ORDER BY name;
