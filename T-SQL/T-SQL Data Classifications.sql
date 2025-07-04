DECLARE @ServerName AS VARCHAR(128) = UPPER(CAST(SERVERPROPERTY('MachineName') AS nvarchar(128)));
SELECT 
		@ServerName [Server Name], 
		(SELECT dec.local_net_address
		FROM sys.dm_exec_connections AS dec
		WHERE dec.session_id = @@SPID) AS [IP Address],
		CASE
		WHEN @ServerName LIKE '%P[0-9][0-9]%' THEN 'PRD'
		WHEN @ServerName LIKE '%T[0-9][0-9]%' THEN 'UAT'
		WHEN @ServerName LIKE '%D[0-9][0-9]%' THEN 'DEV'
		ELSE 'Unknown ENV'
		END AS ENV,
		DB_NAME() AS DatabaseName,
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
