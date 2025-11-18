-- Queries Server Active Connections
DECLARE @ServerName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('MachineName') AS nvarchar(128)));
DECLARE @InstanceName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('ServerName') AS nvarchar(128)));
SELECT
	@ServerName AS [Server_Name],
	@InstanceName AS [Instance_Name],
	(SELECT dec.local_net_address 
	FROM sys.dm_exec_connections AS dec 
	WHERE dec.session_id = @@SPID) AS [IP_Address],
	c.session_id,
	c.client_net_address,
	s.login_name,
	d.name AS [database],
	c.connect_time,
	c.last_read,
	c.last_write
FROM
	sys.dm_exec_connections c
JOIN sys.dm_exec_sessions s
ON c.session_id = s.session_id
JOIN sys.databases d
ON d.database_id = s.database_id;
