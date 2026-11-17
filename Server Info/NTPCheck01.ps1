
# 1. Define input and output file paths
$ServerListPath = "C:\path\dev_servers.txt"
$CsvOutputPath  = "D:\NTP_Audit_Report_001.csv"

# 2. Configure PowerShell Remoting timeouts
$SessionOption = New-PSSessionOption `
    -OpenTimeout 2000 `
    -OperationTimeout 15000

# 3. Read the server list
$Servers = Get-Content -Path $ServerListPath |
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
    ForEach-Object { $_.Trim() }

# 4. Query each server remotely
$Results = foreach ($Server in $Servers) {

    try {
        Write-Host "Collecting database server info from $Server ..." -ForegroundColor Cyan

        Invoke-Command -ComputerName $Server `
            -SessionOption $SessionOption `
            -ErrorAction Stop `
            -ScriptBlock {

                $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"

                $Params = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue

                # Capture active NTP source
                $Source = w32tm /query /source 2>$null

                if ($Source) {
                    $Source = $Source.Trim()
                }
                else {
                    $Source = "Service Stopped / Unreachable"
                }

                # Capture Windows Time service state
                $Service = Get-Service -Name W32Time -ErrorAction SilentlyContinue

                if ($Service) {
                    $ServiceState = $Service.Status.ToString()
                }
                else {
                    $ServiceState = "Service Not Found"
                }

                # Return server information
                [PSCustomObject]@{
                    Hostname     = $env:COMPUTERNAME
                    SyncType     = $Params.Type
                    NtpServer    = $Params.NtpServer
                    ActiveSource = $Source
                    ServiceState = $ServiceState
                }
            }
    }
    catch {
        Write-Warning "Failed to connect to $Server`: $_"

        [PSCustomObject]@{
            Hostname     = $Server
            SyncType     = "N/A"
            NtpServer    = "N/A"
            ActiveSource = "Connection Failed"
            ServiceState = "Unknown"
        }
    }
}

# 5. Display results
$Results | Format-Table -AutoSize

# 6. Export results to CSV
$Results | Export-Csv -Path $CsvOutputPath -NoTypeInformation -Encoding UTF8

Write-Host "Export complete: $CsvOutputPath" -ForegroundColor Green
