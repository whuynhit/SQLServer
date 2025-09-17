-- Queries Server Active Connections
SELECT
	c.session_id,
	c.client_net_address,
	s.login_name,
	c.connect_time,
	c.last_read,
	c.last_write
FROM
	sys.dm_exec_connections c
JOIN sys.dm_exec_sessions s
ON c.session_id = s.session_id;
