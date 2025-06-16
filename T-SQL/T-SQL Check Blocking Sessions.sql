SELECT
    r.blocking_session_id AS blocking_session_id,
    r.session_id AS blocked_session_id,
    s.login_name,
    r.status,
    r.wait_type,
    r.wait_time,
    r.wait_resource,
    r.command,
    t.text AS blocking_query_text
FROM
    sys.dm_exec_requests r
JOIN
    sys.dm_exec_sessions s ON r.blocking_session_id = s.session_id
CROSS APPLY
    sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE
    r.blocking_session_id <> 0;
