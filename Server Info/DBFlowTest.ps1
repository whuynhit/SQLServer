# ========================
# Config
# ========================
$serverListPath     = "N:\Shares\Network Share\DBA\WS2022AD\serverlist.txt"
$InventoryDbServer  = "YourInventoryServer\SQLInstance"
$InventoryDb        = "InventoryDB"
$TruncateBeforeLoad = $true   # set $false if you don’t want to truncate first

# ========================
# Function: Insert Inventory Record
# ========================
function Insert-InventoryRecord {
    param (
        [string]$ServerName,
        [string]$InstanceName,
        [string]$IPAddress,
        [string]$ENV,
        [string]$Location,
        [string]$Edition,
        [int]$CPUCount,
        [decimal]$DiskE_UsedSpaceGB,
        [decimal]$DiskE_FreeSpaceGB,
        [decimal]$DiskE_TotalSpaceGB,
        [decimal]$DiskF_UsedSpaceGB,
        [decimal]$DiskF_FreeSpaceGB,
        [decimal]$DiskF_TotalSpaceGB
    )

    # Escape quotes in strings for safety
    $ServerName   = $ServerName   -replace "'", "''"
    $InstanceName = $InstanceName -replace "'", "''"
    $IPAddress    = $IPAddress    -replace "'", "''"
    $ENV          = $ENV          -replace "'", "''"
    $Location     = $Location     -replace "'", "''"
    $Edition      = $Edition      -replace "'", "''"

    # Convert empty strings to NULL
    $toSqlValue = {
        param($val)
        if ($null -eq $val -or [string]::IsNullOrWhiteSpace("$val")) { return "NULL" }
        elseif ($val -is [string]) { return "'$val'" }
        else { return $val }
    }

    $sql = @"
INSERT INTO dbo.ServerInventory
(
    Server_Name,
    Instance_Name,
    IPAddress,
    ENV,
    Location,
    Edition,
    CPU_Count,
    DiskE_UsedSpaceGB,
    DiskE_FreeSpaceGB,
    DiskE_TotalSpaceGB,
    DiskF_UsedSpaceGB,
    DiskF_FreeSpaceGB,
    DiskF_TotalSpaceGB
)
VALUES (
    $(& $toSqlValue $ServerName),
    $(& $toSqlValue $InstanceName),
    $(& $toSqlValue $IPAddress),
    $(& $toSqlValue $ENV),
    $(& $toSqlValue $Location),
    $(& $toSqlValue $Edition),
    $(& $toSqlValue $CPUCount),
    $(& $toSqlValue $DiskE_UsedSpaceGB),
    $(& $toSqlValue $DiskE_FreeSpaceGB),
    $(& $toSqlValue $DiskE_TotalSpaceGB),
    $(& $toSqlValue $DiskF_UsedSpaceGB),
    $(& $toSqlValue $DiskF_FreeSpaceGB),
    $(& $toSqlValue $DiskF_TotalSpaceGB)
);
"@

    # Debug: show the SQL being sent
    Write-Host "DEBUG SQL: $sql" -ForegroundColor Yellow

    # Execute
    Invoke-Sqlcmd -ServerInstance $InventoryDbServer -Database $InventoryDb -Query $sql
}

# ========================
# Optional: Truncate existing table
# ========================
if ($TruncateBeforeLoad) {
    try {
        Invoke-Sqlcmd -ServerInstance $InventoryDbServer -Database $InventoryDb -Query "TRUNCATE TABLE dbo.ServerInventory;"
        Write-Host "Truncated dbo.ServerInventory before load." -ForegroundColor Cyan
    }
    catch {
        Write-Warning "Could not truncate dbo.ServerInventory. $_"
    }
}

# ========================
# Loop through servers
# ========================
Get-Content $serverListPath | ForEach-Object {
    $server = $_.Trim()
    if ($server -ne "") {
        Write-Host "Processing server: $server" -ForegroundColor Green
        try {
            $sqlQuery = @"
DECLARE @ServerName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)));
DECLARE @InstanceName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128)));
DECLARE @ProductVersion NVARCHAR(128) = CONVERT(NVARCHAR, SERVERPROPERTY('ProductVersion'));
DECLARE @DiskE AS VARCHAR(3) = 'E:\';
DECLARE @DiskF AS VARCHAR(3) = 'F:\';

WITH DiskInfo AS (
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
    (SELECT dec.local_net_address FROM sys.dm_exec_connections AS dec WHERE dec.session_id = @@SPID) AS [IPAddress],
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
    SERVERPROPERTY('Edition') AS [Edition],
    (SELECT cpu_count FROM sys.dm_os_sys_info) AS [CPU_Count],
    CAST(SUM(CASE WHEN volume_mount_point = @DiskE THEN (total_bytes - available_bytes) END) / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS [DiskE_UsedSpaceGB],
    CAST(SUM(CASE WHEN volume_mount_point = @DiskE THEN (available_bytes) END) / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS [DiskE_FreeSpaceGB],
    CAST(SUM(CASE WHEN volume_mount_point = @DiskE THEN (total_bytes) END) / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS [DiskE_TotalSpaceGB],
    CAST(SUM(CASE WHEN volume_mount_point = @DiskF THEN (total_bytes - available_bytes) END) / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS [DiskF_UsedSpaceGB],
    CAST(SUM(CASE WHEN volume_mount_point = @DiskF THEN (available_bytes) END) / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS [DiskF_FreeSpaceGB],
    CAST(SUM(CASE WHEN volume_mount_point = @DiskF THEN (total_bytes) END) / 1024.0 / 1024.0 / 1024.0 AS DECIMAL(10,2)) AS [DiskF_TotalSpaceGB]
FROM DiskInfo;
"@

            $result = Invoke-Sqlcmd -ServerInstance $server -Query $sqlQuery -TrustServerCertificate -ErrorAction Stop

            if ($result) {
                Insert-InventoryRecord `
                    -ServerName $result.Server_Name `
                    -InstanceName $result.Instance_Name `
                    -IPAddress $result.IPAddress `
                    -ENV $result.ENV `
                    -Location $result.Location `
                    -Edition $result.Edition `
                    -CPUCount $result.CPU_Count `
                    -DiskE_UsedSpaceGB $result.DiskE_UsedSpaceGB `
                    -DiskE_FreeSpaceGB $result.DiskE_FreeSpaceGB `
                    -DiskE_TotalSpaceGB $result.DiskE_TotalSpaceGB `
                    -DiskF_UsedSpaceGB $result.DiskF_UsedSpaceGB `
                    -DiskF_FreeSpaceGB $result.DiskF_FreeSpaceGB `
                    -DiskF_TotalSpaceGB $result.DiskF_TotalSpaceGB
            }
        }
        catch {
            Write-Warning "Failed to connect to $server : $_"
        }
    }
}
