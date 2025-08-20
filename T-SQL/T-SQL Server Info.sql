-- Queries Server Information; Works for SQL Server 2017, 2019, 2022
DECLARE @ServerName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('MachineName') AS nvarchar(128)));
DECLARE @ProductVersion NVARCHAR(128) = CONVERT(
	NVARCHAR,SERVERPROPERTY('ProductVersion'));
DECLARE @DriveE AS VARCHAR(3) = 'E:\';
DECLARE @DriveF AS VARCHAR(3) = 'F:\';

SELECT UPPER(CAST(SERVERPROPERTY('MachineName') AS nvarchar(128))) AS [Server Name],
(SELECT dec.local_net_address
FROM sys.dm_exec_connections as dec
WHERE dec.session_id = @@SPID) [IP Address],
CASE
	WHEN @ServerName LIKE '%P[0-9][0-9]%' THEN 'PRD'
	WHEN @ServerName LIKE '%T[0-9][0-9]%' THEN 'UAT'
	WHEN @ServerName LIKE '%D[0-9][0-9]%' THEN 'DEV'
	WHEN @ServerName LIKE '%DEV[0-9]%' THEN 'DEV'
	ELSE 'Unknown ENV'
END AS 'ENV',
CASE
	WHEN @ProductVersion LIKE '16%' THEN 'SQL SERVER 2022'
	WHEN @ProductVersion LIKE '15%' THEN 'SQL SERVER 2019'
	WHEN @ProductVersion LIKE '14%' THEN 'SQL SERVER 2017'
	ELSE 'Unknown SQL SERVER Version'
END AS 'SQL Version',
SERVERPROPERTY('Edition') AS 'Edition',
SERVERPROPERTY('ProductVersion') AS 'DB Engine Version',
os.host_distribution AS 'OS_Distribution',
os.host_architecture AS 'OS Architecture',
sysinfo.cpu_count AS 'CPU Count (Logical)',

--Drive E space Details
CAST((SELECT
	SUM(CASE WHEN vs.volume_mount_point = @DriveE
		THEN (vs.total_bytes - vs.available_bytes) END) / 1024.0 / 1024.0 / 1024.0
FROM (SELECT DISTINCT vs.volume_mount_point, vs.total_bytes, vs.available_bytes
	FROM sys.master_files mf
	CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs) vs
WHERE vs.volume_mount_point = @DriveE) AS DECIMAL(10,2)) AS 'Data Storage Used (GB)',
CAST((SELECT
	SUM(CASE WHEN vs.volume_mount_point = @DriveE
		THEN vs.total_bytes END) / 1024.0 / 1024.0 / 1024.0
FROM (SELECT DISTINCT vs.volume_mount_point, vs.total_bytes, vs.available_bytes
	FROM sys.master_files mf
	CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs) vs
WHERE vs.volume_mount_point = @DriveE) AS DECIMAL(10,2)) AS 'Data Storage Size (GB)',

-- Drive F details
CAST((SELECT
	SUM(CASE WHEN vs.volume_mount_point = @DriveF
		THEN (vs.total_bytes - vs.available_bytes) END) / 1024.0 / 1024.0 / 1024.0
FROM (SELECT DISTINCT vs.volume_mount_point, vs.total_bytes, vs.available_bytes
	FROM sys.master_files mf
	CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs) vs
WHERE vs.volume_mount_point = @DriveF) AS DECIMAL(10,2)) AS 'Log Storage Used (GB)',
CAST((SELECT
	SUM(CASE WHEN vs.volume_mount_point = @DriveF
		THEN vs.total_bytes END) / 1024.0 / 1024.0 / 1024.0
FROM (SELECT DISTINCT vs.volume_mount_point, vs.total_bytes, vs.available_bytes
	FROM sys.master_files mf
	CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs) vs
WHERE vs.volume_mount_point = @DriveF) AS DECIMAL(10,2)) AS 'Log Storage Size (GB)'

FROM sys.dm_os_host_info AS os, sys.dm_os_sys_info AS sysinfo;
