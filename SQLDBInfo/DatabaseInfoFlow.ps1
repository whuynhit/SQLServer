# ==========================================
# Database Inventory Collector - PowerShell
# ==========================================

# Paths
$serverListPath = "N:\Shares\Network Share\DBA\WS2022AD\servers.txt"

# Central repository
$inventoryDbServer = "WS2022AD"
$inventoryDbName   = "SQLInfo"
$inventoryTable    = "dbo.SQLDatabaseInventory"

# SQL query to get DB info from each server
$sqlQuery = @"
DECLARE @ServerName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)));
DECLARE @InstanceName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128)));

SELECT  
    @ServerName AS [Server_Name],
    @InstanceName AS [Instance_Name],
    d.name AS [Database_Name],
    CASE
        WHEN d.database_id > 4 THEN 'User'
        ELSE 'System'
    END AS [Database_Type],
    d.state_desc AS [Database_Status],
    d.recovery_model_desc AS [Recovery_Model],
    d.compatibility_level AS [Compatibility_Level],
    CAST(ISNULL(SUM(mf.size),0) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS [Database_SizeGB]
FROM sys.databases d
LEFT JOIN sys.master_files mf 
    ON d.database_id = mf.database_id
GROUP BY d.database_id, d.name, d.state_desc, d.recovery_model_desc, d.compatibility_level
ORDER BY d.name;
"@

# Optional: clear old snapshot
Invoke-Sqlcmd -ServerInstance $inventoryDbServer -Database $inventoryDbName -Query "TRUNCATE TABLE $inventoryTable;" -TrustServerCertificate

# Loop through servers
Get-Content $serverListPath | ForEach-Object {
    $server = $_.Trim()
    if ($server -ne "") {
        try {
            Write-Host "Collecting database inventory from $server ..." -ForegroundColor Cyan

            $results = Invoke-Sqlcmd -ServerInstance $server -Query $sqlQuery -TrustServerCertificate -ErrorAction Stop

            if ($results) {
                foreach ($row in $results) {
                    # ISNULL already handled inside SQL query, so no $null issues here
                    $insert = @"
INSERT INTO $inventoryTable
(Server_Name, Instance_Name, Database_Name, Database_Type, Database_Status, Recovery_Model, Compatibility_Level, Database_SizeGB, CaptureDate)
VALUES
('$($row.Server_Name)', 
 '$($row.Instance_Name)', 
 '$($row.Database_Name)', 
 '$($row.Database_Type)',
 '$($row.Database_Status)', 
 '$($row.Recovery_Model)', 
 $($row.Compatibility_Level),
 $([math]::Round([double]$row.Database_SizeGB,2)), 
 GETDATE());
"@
                    Invoke-Sqlcmd -ServerInstance $inventoryDbServer -Database $inventoryDbName -Query $insert -TrustServerCertificate
                }
            }
        }
        catch {
            Write-Warning "Failed to collect from $server : $_"
        }
    }
}
