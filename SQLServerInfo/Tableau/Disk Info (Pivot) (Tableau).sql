-- For Tableau, pivots Disk Info from 'T-SQL and Disk Info 2016.txt' to look like 'T-SQL Disk Space (Old).txt'
SELECT
    DISTINCT(Server_Name),
    'Disk E' AS Disk,
    'Used' AS Usage,
    DiskE_UsedSpaceGB AS SpaceGB,
    DiskE_TotalSpaceGB AS TotalGB
FROM ServerInfo
UNION ALL
SELECT
    DISTINCT(Server_Name),
    'Disk E' AS Disk,
    'Free' AS Usage,
    DiskE_FreeSpaceGB AS SpaceGB,
    DiskE_TotalSpaceGB AS TotalGB
FROM ServerInfo
UNION ALL
SELECT
    DISTINCT(Server_Name),
    'Disk F' AS Disk,
    'Used' AS Usage,
    DiskF_UsedSpaceGB AS SpaceGB,
    DiskF_TotalSpaceGB AS TotalGB
FROM ServerInfo
UNION ALL
SELECT
    DISTINCT(Server_Name),
    'Disk F' AS Disk,
    'Free' AS Usage,
    DiskF_FreeSpaceGB AS SpaceGB,
    DiskF_TotalSpaceGB AS TotalGB
FROM ServerInfo
