# 1. Define your input and output file paths
$ServerListPath = "D:\servers.txt"
$CsvOutputPath  = "D:\NTP_Audit_Results.csv"

# 2. Configure PowerShell Remoting timeouts
$SessionOption = New-PSSessionOption `
    -OpenTimeout 2000 `
    -OperationTimeout 15000

# 3. Read the server list
$Servers = Get-Content -Path $ServerListPath |
    Where-Object { $_.Trim() -ne "" } |
    ForEach-Object { $_.Trim() }

# 4. Query each server remotely
$Results = foreach ($Server in $Servers) {
    try {
        Write-Host "Collecting database server info from $Server ..." -ForegroundColor Cyan

        $Source = Invoke-Command -ComputerName $Server -ScriptBlock {
            (w32tm /query /source).Trim()
        } -SessionOption $SessionOption -ErrorAction Stop

        [PSCustomObject]@{
            Hostname  = $Server
            Status    = "Success"
            NTPSource = $Source
        }
    }
    catch {
        Write-Warning "Failed to connect to $Server`: $_"
        continue
    }
}

# 5. Display results and export to CSV
$Results | Format-Table -AutoSize

$Results | Export-Csv -Path $CsvOutputPath -NoTypeInformation -Encoding UTF8

Write-Host "Export complete: $CsvOutputPath" -ForegroundColor Green
