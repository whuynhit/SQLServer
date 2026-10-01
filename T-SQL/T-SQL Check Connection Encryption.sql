-- Check Connection Encryption
SELECT 
    c.session_id,
    s.login_name,
    c.encrypt_option,
    c.net_transport,
    c.auth_scheme
FROM sys.dm_exec_connections AS c
JOIN sys.dm_exec_sessions AS s 
    ON c.session_id = s.session_id;
