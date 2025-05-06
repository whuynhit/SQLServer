-- Queries Server Information; Works for SQL Server 2017, 2019, 2022
DECLARE @ProductVersion NVARCHAR(128) = CONVERT(NVARCHAR, SERVERPROPERTY('ProductVersion'));
DECLARE @DriveE AS VARCHAR(3) = 'E:\';
DECLARE @DriveF AS VARCHAR(3) = 'F:\';

SELECT 
    UPPER(CAST(SERVERPROPERTY('MachineName') AS nvarchar(128))) AS [Server Name],
    (SELECT dec.local_net_address FROM sys.dm_exec_connections AS dec WHERE dec.session_id = @@SPID) AS 'IP Address',
    CASE
	WHEN @ProductVersion LIKE '16%' THEN 'SQL Server 2022'
	WHEN @ProductVersion LIKE '15%' THEN 'SQL Server 2019'
	WHEN @ProductVersion LIKE '14%' THEN 'SQL Server 2017'
        ELSE 'Unknown SQL Server Version'
    END AS SQLVersion,
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
    os.host_distribution AS OS_Distribution,
    sysinfo.cpu_count AS CPUCount,
    -- Drive E space details
    CAST((SELECT 
        SUM(CASE WHEN vs.volume_mount_point = @DriveE 
            THEN (vs.total_bytes - vs.available_bytes) END) / 1024.0 / 1024.0 / 1024.0
     FROM (SELECT DISTINCT vs.volume_mount_point, vs.total_bytes, vs.available_bytes
           FROM sys.master_files mf
           CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs) vs
     WHERE vs.volume_mount_point = @DriveE) AS DECIMAL(10, 2)) AS DriveE_UsedSpaceGB,
    CAST((SELECT 
        SUM(CASE WHEN vs.volume_mount_point = @DriveE 
            THEN vs.total_bytes END) / 1024.0 / 1024.0 / 1024.0
     FROM (SELECT DISTINCT vs.volume_mount_point, vs.total_bytes, vs.available_bytes
           FROM sys.master_files mf
           CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs) vs
     WHERE vs.volume_mount_point = @DriveE) AS DECIMAL(10, 2)) AS DriveE_TotalSizeGB,
    -- Drive F space details
    CAST((SELECT 
        SUM(CASE WHEN vs.volume_mount_point = @DriveF 
            THEN (vs.total_bytes - vs.available_bytes) END) / 1024.0 / 1024.0 / 1024.0
     FROM (SELECT DISTINCT vs.volume_mount_point, vs.total_bytes, vs.available_bytes
           FROM sys.master_files mf
           CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs) vs
     WHERE vs.volume_mount_point = @DriveF) AS DECIMAL(10, 2)) AS DriveF_UsedSpaceGB,
    CAST((SELECT 
        SUM(CASE WHEN vs.volume_mount_point = @DriveF 
            THEN vs.total_bytes END) / 1024.0 / 1024.0 / 1024.0
     FROM (SELECT DISTINCT vs.volume_mount_point, vs.total_bytes, vs.available_bytes
           FROM sys.master_files mf
           CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs) vs
     WHERE vs.volume_mount_point = @DriveF) AS DECIMAL(10, 2)) AS DriveF_TotalSizeGB
FROM 
    sys.dm_os_host_info AS os
CROSS JOIN 
    sys.dm_os_sys_info AS sysinfo;
