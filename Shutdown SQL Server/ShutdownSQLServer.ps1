# Path to the list of SQL Server instances (one per line)
$serverListPath = "N:\Shares\Network Share\DBA\WS2022AD\servers.txt"

# Generate a timestamped log file
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "N:\Shares\Network Share\DBA\WS2022AD\SQL Server Shutdown Logs\sql_shutdown_$timestamp.log"

# Read the list of servers
$servers = Get-Content $serverListPath

foreach ($server in $servers) {
    try {
        Write-Host "Attempting to shut down $server..." -ForegroundColor Cyan

        # Issue graceful shutdown command        
        Invoke-Sqlcmd -ServerInstance $server -Query "SHUTDOWN;" -QueryTimeout 60 -TrustServerCertificate

        # Log success
        $successMsg = "$(Get-Date -Format u) - SUCCESS: Shutdown issued for $server"
        Write-Host $successMsg -ForegroundColor Green
        Add-Content -Path $logFile -Value $successMsg
    } catch {
        # Log failure
        $errorMsg = "$(Get-Date -Format u) - ERROR: Could not shut down $server - $_"
        Write-Host $errorMsg -ForegroundColor Red
        Add-Content -Path $logFile -Value $errorMsg
    }

    # Optional: small pause between servers
    Start-Sleep -Seconds 5
}

Write-Host "Shutdown script completed. Log file saved to $logFile" -ForegroundColor Yellow
