-- Queries Server Active Connections
SELECT
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
