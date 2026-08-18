-- Generate BACKUP (bak file to S3) command based on existing databases from Source RDS. 
DECLARE @s3_bucket_name NVARCHAR(256) = '<bucket_name>';
SELECT 
	CONCAT_WS(
	CHAR(13) + CHAR(10),
	'exec msdb.dbo.rds_backup_database',
	CONCAT('@source_db_name= ''', name, ''','),
	CONCAT('@s3_arn_to_backup_to=''arn:aws:s3:::', @s3_bucket_name,'/', name, '_db_backup.bak'';')
	)
FROM sys.databases
WHERE database_id > 4 AND name NOT IN ('rdsadmin')
ORDER BY name;


-- Generate RESTORE (from bak file in S3) command based on existing databases from Source. 
DECLARE @s3_bucket_name NVARCHAR(256) = '<bucket_name>';
SELECT 
	CONCAT_WS(
	CHAR(13) + CHAR(10),
	'exec msdb.dbo.rds_restore_database',
	CONCAT('@restore_db_name= ''', name, ''','),
	CONCAT('@s3_arn_to_restore_from=''arn:aws:s3:::', @s3_bucket_name,'/', name, '_db_backup.bak'';')
	)
FROM sys.databases
WHERE database_id > 4 AND name NOT IN ('rdsadmin')
ORDER BY name;


-- Check RDS BACKUP/RESTORE task status
exec msdb.dbo.rds_task_status;
