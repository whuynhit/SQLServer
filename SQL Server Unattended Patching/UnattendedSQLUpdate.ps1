# ==========================
# Unattended SQL Server Update Script
# For SQL Server
# ==========================


param (
    [string]$SQLVersion = "2022",		# SQL Version
    [string]$PatchVersion = "KB5050771",	# Patch Version, could be KB# or CU#, depends on how you name the <patch>.exe
    [string]$PatchFile = "SQLServer$SQLVersion-$PatchVersion-x64.exe",
    [string]$SourceUpdatePath = "\\WS2022AD\Network Share\DBA\SQL Server Patches\$PatchFile",   # Path to update .exe
    [string]$InstanceName = "MSSQLSERVER",                    # Default instance; change if named
    [string]$LocalTempPath = "D:\Temp",
    [string]$DestUpdatePath = "$LocalTempPath\$PatchFile",
    [switch]$RebootIfRequired                                 # Flag to reboot if update requires it
)

# Create log folder
if (!(Test-Path $LocalTempPath)) {
    New-Item -ItemType Directory -Path $LocalTempPath -Force
}

Write-Output "Copying $PatchFile from $SourceUpdatePath..."
Copy-Item -Path $SourceUpdatePath -Destination $LocalTempPath -Force

# Build arguments for the update
$Arguments = "/quiet /Action=Patch /InstanceName=$InstanceName /IAcceptSQLServerLicenseTerms"

Write-Host "Starting update for instance '$InstanceName' using: $DestUpdatePath"
Write-Host "Logs will be available in the default SQL Server log folder (C:\Program Files\Microsoft SQL Server\<version>\Setup Bootstrap\Log\)"

# Execute the update
$process = Start-Process -FilePath $DestUpdatePath -ArgumentList $Arguments -Wait -PassThru

# Check result based on exit code
if ($process.ExitCode -eq 0) {
    Write-Host "✅ Update succeeded for instance '$InstanceName'."
} elseif ($process.ExitCode -eq 3010 -and $RebootIfRequired) {
    Write-Host "⚠️ Update succeeded but requires reboot. Rebooting..."
    Restart-Computer -Force
} else {
    Write-Host "❌ Update failed with exit code $($process.ExitCode). Check logs in: C:\Program Files\Microsoft SQL Server\<version>\Setup Bootstrap\Log"
    Exit 1
}

# Optional: Email notification (customize as needed)
<# 
Send-MailMessage -To "dba@example.com" -From "sqlupdate@example.com" `
    -Subject "SQL Update Completed for $InstanceName" `
    -Body "Update completed successfully. Logs available in default log directory." `
    -SmtpServer "smtp.example.com"
#>

# Deletes Temp Folder
if (Test-Path $LocalTempPath) {
    Remove-Item -Path $LocalTempPath -Recurse -Force
    Write-Output "Deleted folder: $LocalTempPath"
} else {
    Write-Output "Folder not found: $LocalTempPath"
}