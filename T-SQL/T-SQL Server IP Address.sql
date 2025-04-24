-- Query IP Address of Connected Server
SELECT dec.local_net_address
FROM sys.dm_exec_connections AS dec
WHERE dec.session_id = @@SPID;