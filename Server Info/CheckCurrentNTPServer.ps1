# 1. Define input and output file paths
$ServerList = "D:\servers.txt"
$OutputCsv  = "D:\\NTP_Audit_Report.csv"

# 2. Read server names (ignoring any blank lines)
$Servers = Get-Content -Path $ServerList | Where-Object { $_.Trim() -ne "" }

# 3. Loop through each server, display status, and collect info
$Results = foreach ($Server in $Servers) {
    $Server = $Server.Trim()
    Write-Host "Collecting database server info from $Server ..." -ForegroundColor Cyan

    Invoke-Command -ComputerName $Server -ErrorAction SilentlyContinue -ScriptBlock {
        $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters"
        $Params  = Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue
        
        # Capture active source and clean up whitespace
        $Source = (w32tm /query /source 2>$null)
        if ($Source) { $Source = $Source.Trim() } else { $Source = "Service Stopped / Unreachable" }

        [PSCustomObject]@{
            Hostname     = $env:COMPUTERNAME
            SyncType     = $Params.Type
            NtpServer    = $Params.NtpServer
            ActiveSource = $Source
            ServiceState = (Get-Service w32time).Status
        }
    }
}

# 4. Clean up PowerShell remoting metadata and export to CSV
$Results | Select-Object Hostname, SyncType, NtpServer, ActiveSource, ServiceState |
    Export-Csv -Path $OutputCsv -NoTypeInformation

Write-Host "Audit complete. Results saved to $OutputCsv" -ForegroundColor Green
