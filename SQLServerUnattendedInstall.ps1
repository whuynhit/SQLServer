# Define version and paths
$SAPasswd = "Password1"
$SQLVersion = "2022"
$SQLEdition = "Developer"        # Edition "Developer" or "Evaluation"
$ISOFile = "SQLServer$SQLVersion-x64-ENU-$SQLEdition.iso"

$TempPath = "D:\Temp"        # Temp Folder Directory
$InstanceDir = "D:\Program Files\Microsoft SQL Server"        # SQL Server Instance and Shared Features Directory
$SharedDir = $InstanceDir
$SharedWowDir = "D:\Program Files (x86)\Microsoft SQL Server"        # SQL Server 32-Bit/x86/wow64 Shared Features Directory
$SQLBackupDir       = "G:\BACKUPS"
$SQLUserDBDir       = "E:\DATA"
$SQLUserDBLogDir    = "F:\LOGS"
$SQLTempDBDir       = "E:\TEMPDB"
$SQLTempDBLogDir    = "F:\TEMPLOGS"

$SourceISO = "\\WS2022AD\Network Share\DBA\ISO\$ISOFile"    # Network Share location of ISO to copy from
$LocalISO = "$TempPath\$ISOFile"        # Local ISO file location
$SQLConfigFile = "$TempPath\SQLConfig$SQLVersion.ini"       # Config file path
$SSMSInstaller = "https://aka.ms/ssmsfullsetup"        # SSMS Download Link
$NetworkSSMS = "\\WS2022AD\Network Share\DBA\SSMS\SSMS-Setup.exe"
$SSMSExe = "$TempPath\SSMS-Setup.exe"                # SSMS Download Path

# User Accounts to be added to SQL Server
$DBAAdmins = '"CMV\DBA Admins"'
$SQLSentrySvc = '"CMV\SqlSentry.Service"'
$MSAssessSvc = '"CMV\MSAssess.Service"'
$RubrikSvc = '"CMV\rubriksqlbackupsvc"'
# Accounts to be assigned SysAdmin permissions for SQL Server
$SQLSysAdminAcct = "$DBAAdmins $SQLSentrySvc $MSAssessSvc $RubrikSvc"

# Ensure necessary folders exist
$RequiredPaths = @(
    # Application and system directories
    $TempPath,
    $InstanceDir,
    $SharedWOWDir,

    # Data and log directories
    $SQLBackupDir,
    $SQLUserDBDir,
    $SQLUserDBLogDir,
    $SQLTempDBDir,
    $SQLTempDBLogDir
)

foreach ($path in $RequiredPaths) {
    if (!(Test-Path $path)) {
        Write-Output "Creating $path..."
        New-Item -Path $path -ItemType Directory -Force | Out-Null
        Write-Output "$path Created"
    }
}

# Allow remote access by opening TCP port 1433 in Windows Firewall
Write-Output "Configuring Windows Firewall to allow remote SQL Server connections..."
New-NetFirewallRule -DisplayName "Allow SQL Server TCP 1433" `
  -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow

# Generate SQL Server configuration file
@"
[Config File Here]
"@ | Set-Content -Path $SQLConfigFile

# Copy SQL Server ISO Install from Network Share location to local location
Write-Output "Copying $ISOFile from $SourceISO..."
Copy-Item -Path $SourceISO -Destination $LocalISO -Force
Write-Output "Copied $ISOFile to $TempPath"

# Mount ISO file
Write-Output "Mounting Media $ISOFile ..."
$mountResult = Mount-DiskImage -ImagePath $LocalISO -PassThru
$volume = ($mountResult | Get-Volume)
$driveLetter = $volume.DriveLetter + ":"
Write-Output "Mounted $ISOFile to $driveLetter"

# Run Unattended SQL Server installation
$setupPath = "$driveLetter\setup.exe"
if (Test-Path $setupPath) {
    Write-Output "Starting SQL Server unattended installation from $setupPath..."
    Start-Process -FilePath $setupPath `
        -ArgumentList "/ConfigurationFile=$SQLConfigFile /Q" `
        -Wait -NoNewWindow
    Write-Output "SQL Server $SQLVersion $SQLEdition Installed"
} else {
    Write-Output "ERROR: setup.exe not found at $setupPath"
    exit 1
}

# Optional: Enable SQL Server Agent if needed
# Start-Service -Name "SQLSERVERAGENT"
# Set-Service -Name "SQLSERVERAGENT" -StartupType Automatic

# Option 1: Directly Download SSMS to Server
#Invoke-WebRequest -Uri $SSMSInstaller -OutFile $SSMSExe
# Option 2: Copy SSMS-Setup.exe from Network Share location to local location
Write-Output "Copying SSMS-Setup.exe from $NetworkSSMS..."
Copy-Item -Path $NetworkSSMS -Destination $SSMSExe -Force
Write-Output "Copied SSMS-Setup.exe to $TempPath"

# Install SSMS silently
Write-Output "Installing SSMS..."
Start-Process -FilePath $SSMSExe -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow
Write-Output "SSMS Installed"

# Dismount ISO
Write-Output "Dismounting Media $ISOFile from $driveLetter..."
Dismount-DiskImage -ImagePath $LocalISO
Write-Output "Dismounted Media $ISOFile from $driveLetter..."

# Delete Temp Folder
if (Test-Path $TempPath) {
    Remove-Item -Path $TempPath -Recurse -Force
    Write-Output "Deleted folder: $TempPath"
} else {
    Write-Output "Folder not found: $TempPath"
}
