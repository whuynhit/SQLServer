-- Queries Disk Space
SELECT DISTINCT 
    vs.volume_mount_point AS DriveLetter,
    CAST(vs.total_bytes / 1024.0 / 1024 / 1024 AS DECIMAL(10, 2)) AS TotalSizeGB,
    CAST(vs.available_bytes / 1024.0 / 1024 / 1024 AS DECIMAL(10, 2)) AS FreeSpaceGB,
    CAST((vs.total_bytes - vs.available_bytes) / 1024.0 / 1024 / 1024 AS DECIMAL(10, 2)) AS UsedSpaceGB
FROM 
    sys.master_files mf
CROSS APPLY 
    sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
ORDER BY 
    DriveLetter;
