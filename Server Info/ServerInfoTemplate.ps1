# Define paths
$serverListPath = "N:\Shares\Network Share\DBA\WS2022AD\servers.txt"
$outputCsvPath = "D:\ServerInfo.csv"

# Your SQL query
$sqlQuery = @"
[Your Query Here]
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
