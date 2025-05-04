-- Queries Server Information for SQL Server 2016, but works for later versions.
DECLARE @ProductVersion NVARCHAR(128) = CONVERT(NVARCHAR, SERVERPROPERTY('ProductVersion'));
DECLARE @DriveE AS VARCHAR(3) = 'E:\';
DECLARE @DriveF AS VARCHAR(3) = 'F:\';

-- Get OS info using xp_msver
DECLARE @MSVer TABLE (
    [Index] INT,
    [Name] NVARCHAR(128),
    [Internal_Value] INT,
    [Character_Value] NVARCHAR(512)
);

INSERT INTO @MSVer
EXEC master.dbo.xp_msver;

DECLARE @OSDistribution NVARCHAR(512) = (
    SELECT TOP 1 [Character_Value]
    FROM @MSVer
    WHERE [Name] = 'WindowsVersion'
);

SELECT 
    SERVERPROPERTY('MachineName') AS ServerName,
    (SELECT dec.local_net_address 
     FROM sys.dm_exec_connections AS dec 
     WHERE dec.session_id = @@SPID) AS [IP Address],
    CASE
        WHEN @ProductVersion LIKE '16%' THEN 'SQL Server 2022' 
        WHEN @ProductVersion LIKE '15%' THEN 'SQL Server 2019'
        WHEN @ProductVersion LIKE '14%' THEN 'SQL Server 2017'
        WHEN @ProductVersion LIKE '13%' THEN 'SQL Server 2016'
        ELSE 'Unknown SQL Server Version'
    END AS SQLVersion,
    SERVERPROPERTY('Edition') AS Edition,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,
        (
        SELECT
            CASE windows_release
                WHEN '10.0' THEN 
                    CASE 
                        WHEN windows_sku = 8 THEN 'Windows Server 2016 Standard'
                        WHEN windows_sku = 12 THEN 'Windows Server 2016 Datacenter'
                        WHEN windows_sku = 13 THEN 'Windows Server 2019 Standard'
                        WHEN windows_sku = 14 THEN 'Windows Server 2019 Datacenter'
                        WHEN windows_sku = 79 THEN 'Windows Server 2022 Standard Evaluation'
                        WHEN windows_sku = 80 THEN 'Windows Server 2022 Datacenter Evaluation'
                        ELSE 'Windows Server (10.0 based, unknown SKU)'
                    END
                WHEN '6.3' THEN 'Windows Server 2012 R2'
                WHEN '6.2' THEN 'Windows Server 2012'
                WHEN '6.1' THEN 'Windows Server 2008 R2'
                ELSE 'Unknown Windows Version'
            END
        FROM sys.dm_os_windows_info
    ) AS OS_Distribution,

    (SELECT cpu_count FROM sys.dm_os_sys_info) AS CPUCount,


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
         WHERE vs.volume_mount_point = @DriveF) AS DECIMAL(10, 2)) AS DriveF_TotalSizeGB;
