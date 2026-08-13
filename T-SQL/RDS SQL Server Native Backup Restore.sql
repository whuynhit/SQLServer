-- Generate RESTORE (from bak file in S3) command based on existing databases from Source. 
SELECT 
	CONCAT_WS(
	CHAR(13) + CHAR(10),
	'exec msdb.dbo.rds_restore_database',
	CONCAT('@restore_db_name= ''', name, ''','),
	CONCAT('@s3_arn_to_restore_from=''arn:aws:s3:::<bucket_name>/', name, '_copy_only.bak'';')
	)
FROM sys.databases
WHERE database_id > 4
ORDER BY name;
