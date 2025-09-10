# Define paths
$serverListPath = "N:\Shares\Network Share\DBA\WS2022AD\servers.txt"

# Central repository SQL Server (where inventory data is stored)
$inventoryDbServer = "WS2022AD"   # 👈 change this
$inventoryDbName   = "SQLInfo"                 # 👈 change this
$inventoryTable    = "dbo.SQLServerInventory"

# Your SQL query (run against each target SQL Server)
$sqlQuery = @"
-- Queries Server and Disk Information; Works for SQL Server 2016, 2017, 2019, 2022
DECLARE @ServerName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('MachineName') AS nvarchar(128)));
DECLARE @InstanceName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('ServerName') AS nvarchar(128)));
DECLARE @ProductVersion NVARCHAR(128) = CONVERT(NVARCHAR, SERVERPROPERTY('ProductVersion'));
DECLARE @DiskE AS VARCHAR(3) = 'E:\';
DECLARE @DiskF AS VARCHAR(3) = 'F:\';

With DiskInfo AS (
SELECT DISTINCT
	vs.volume_mount_point,
	vs.total_bytes,
	vs.available_bytes
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
WHERE vs.volume_mount_point IN (@DiskE, @DiskF)
)

SELECT 
@ServerName AS [Server_Name],
@InstanceName AS [Instance_Name],
(SELECT dec.local_net_address 
FROM sys.dm_exec_connections AS dec 
WHERE dec.session_id = @@SPID) AS [IP_Address],
CASE
WHEN @ServerName LIKE '%P[0-9][0-9]%' THEN 'PRD'
WHEN @ServerName LIKE '%T[0-9][0-9]%' THEN 'UAT'
WHEN @ServerName LIKE '%D[0-9][0-9]%' THEN 'DEV'
WHEN @ServerName LIKE '%DEV[0-9]%' THEN 'DEV'
ELSE 'Unknown ENV'
END AS [ENV],
CASE
WHEN @ServerName LIKE '%AWS%' THEN 'AWS EC2'
WHEN @ServerName LIKE '%ABY%' THEN 'AWS EC2'
ELSE 'On-Prem'
END AS [Location],
CASE
WHEN @ProductVersion LIKE '16%' THEN 'SQL Server 2022' 
WHEN @ProductVersion LIKE '15%' THEN 'SQL Server 2019'
WHEN @ProductVersion LIKE '14%' THEN 'SQL Server 2017'
WHEN @ProductVersion LIKE '13%' THEN 'SQL Server 2016'
ELSE 'Unknown SQL Server Version'
END AS [SQL_Version],
SERVERPROPERTY('Edition') AS [Edition],
@ProductVersion AS [Product_Version],
(SELECT cpu_count FROM sys.dm_os_sys_info) AS [CPU_Count],

-- Disk E, Data Storage
CAST(SUM(CASE WHEN volume_mount_point = @DiskE
THEN (total_bytes - available_bytes) END) 
/ 1024.0 / 1024.0/ 1024.0 AS DECIMAL(10,2)) AS [DiskE_UsedSpaceGB],
CAST(SUM(CASE WHEN volume_mount_point = @DiskE
THEN (available_bytes) END) 
/ 1024.0 / 1024.0/ 1024.0 AS DECIMAL(10,2)) AS [DiskE_FreeSpaceGB],
CAST(SUM(CASE WHEN volume_mount_point = @DiskE
THEN (total_bytes) END) 
/ 1024.0 / 1024.0/ 1024.0 AS DECIMAL(10,2)) AS [DiskE_TotalSpaceGB],

-- Disk F, Data Storage
CAST(SUM(CASE WHEN volume_mount_point = @DiskF
THEN (total_bytes - available_bytes) END) 
/ 1024.0 / 1024.0/ 1024.0 AS DECIMAL(10,2)) AS [DiskF_UsedSpaceGB],
CAST(SUM(CASE WHEN volume_mount_point = @DiskF
THEN (available_bytes) END) 
/ 1024.0 / 1024.0/ 1024.0 AS DECIMAL(10,2)) AS [DiskF_FreeSpaceGB],
CAST(SUM(CASE WHEN volume_mount_point = @DiskF
THEN (total_bytes) END) 
/ 1024.0 / 1024.0/ 1024.0 AS DECIMAL(10,2)) AS [DiskF_TotalSpaceGB]
FROM DiskInfo;
"@

# (Optional) Clear old snapshot before new insert
Invoke-Sqlcmd -ServerInstance $inventoryDbServer -Database $inventoryDbName -Query "TRUNCATE TABLE $inventoryTable;" -TrustServerCertificate

# Loop through each server
Get-Content $serverListPath | ForEach-Object {
    $server = $_.Trim()
    if ($server -ne "") {
        try {
            # Run query against target SQL Server
            $results = Invoke-Sqlcmd -ServerInstance $server -Query $sqlQuery -TrustServerCertificate -ErrorAction Stop

            if ($results) {
                foreach ($row in $results) {
                    # Build INSERT for central inventory table
                    $insert = @"
INSERT INTO $inventoryTable
(Server_Name, Instance_Name, IP_Address, ENV, Location, SQL_Version, Edition, Product_Version, CPU_Count,
 DiskE_UsedSpaceGB, DiskE_FreeSpaceGB, DiskE_TotalSpaceGB,
 DiskF_UsedSpaceGB, DiskF_FreeSpaceGB, DiskF_TotalSpaceGB, CaptureDate)
VALUES
('$($row.Server_Name)', '$($row.Instance_Name)', '$($row.IP_Address)',
 '$($row.ENV)', '$($row.Location)', '$($row.SQL_Version)', '$($row.Edition)', '$($row.Product_Version)', $($row.CPU_Count),
 $($row.DiskE_UsedSpaceGB), $($row.DiskE_FreeSpaceGB), $($row.DiskE_TotalSpaceGB),
 $($row.DiskF_UsedSpaceGB), $($row.DiskF_FreeSpaceGB), $($row.DiskF_TotalSpaceGB), GETDATE());
"@
                    # Insert into central repo
                    Invoke-Sqlcmd -ServerInstance $inventoryDbServer -Database $inventoryDbName -Query $insert -TrustServerCertificate
                }
            }
        }
        catch {
            Write-Warning "Failed to connect to $server`: $_"
        }
    }
}
