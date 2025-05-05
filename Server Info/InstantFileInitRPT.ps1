# Define paths
$serverListPath = "N:\Shares\Network Share\DBA\WS2022AD\servers.txt"
$outputCsvPath = "D:\InstantFileInitReport.csv"

# Your SQL query
$sqlQuery = @"
SELECT 
    SERVERPROPERTY('MachineName') AS [Server Name], 
    servicename AS [Service Name], 
    instant_file_initialization_enabled AS [Instant File Initialization Enabled]
FROM 
    sys.dm_server_services;
"@

# Clear or create output file
if (Test-Path $outputCsvPath) {
    Remove-Item $outputCsvPath
}

# Loop through each server
Get-Content $serverListPath | ForEach-Object {
    $server = $_.Trim()
    if ($server -ne "") {
        try {
            $results = Invoke-Sqlcmd -ServerInstance $server -Query $sqlQuery -TrustServerCertificate -ErrorAction Stop

            if ($results) {
                if (-Not (Test-Path $outputCsvPath)) {
                    # Output with headers if file doesn't exist
                    $results | Export-Csv -Path $outputCsvPath -NoTypeInformation
                } else {
                    # Append without headers
                    $results | Export-Csv -Path $outputCsvPath -NoTypeInformation -Append
                }
            }
        }
        catch {
            Write-Warning "Failed to connect to $server`: $_"
        }
    }
}