# Define version and paths
$SAPasswd = "Password1"
$SQLVersion = "2022"
$SQLEdition = "Developer"	# Editions "Developer"/"Evaluation" for Enterprise

$SetupPath = "\\WS2022AD\Network Share\DBA\SQL Server $SQLVersion $SQLEdition\setup.exe"	# UNC Path
$SSMSExe = "\\WS2022AD\Network Share\DBA\SSMS\SSMS-Setup.exe"	# UNC Path

$TempPath = "D:\Temp"	# Temporary Folder Directory
$InstanceDir = "D:\Program Files\Microsoft SQL Server"	# Instance and Shared Features Directory
$SharedDir = $InstanceDir
$SharedWOWDir = "D:\Program Files (x86)\Microsoft SQL Server"	# Shared Features 32-bit/x86/WOW64 Directory
$SQLBackupDir       = "G:\BACKUPS"
$SQLUserDBDir       = "E:\DATA"
$SQLUserDBLogDir    = "F:\LOGS"
$SQLTempDBDir       = "E:\TEMPDB"
$SQLTempDBLogDir    = "F:\TEMPLOGS"

$SQLConfigFile = "$TempPath\SQLConfig$SQLVersion.ini"	# Config file path

# User Accounts to be added to SQL Server
$DBAAdmins = '"CMV\DBA Admins"'
$SQLSentrySvc = '"CMV\SqlSentry.Service"'
$MSAssessSvc = '"CMV\MSAssess.Service"'
$RubrikSvc = '"CMV\rubriksqlbackupsvc"'
# Accounts to be assigned SysAdmin permissions for SQL Server
$SQLSysAdminAcct = "$DBAAdmins $SQLSentrySvc $MSAssessSvc $RubrikSvc"

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

# Run Unattended SQL Server installation
if (Test-Path $SetupPath) {
    Write-Output "Starting SQL Server unattended installation from $SetupPath..."
    Start-Process -FilePath $SetupPath `
        -ArgumentList "/ConfigurationFile=$SQLConfigFile /Q" `
        -Wait -NoNewWindow
    Write-Output "SQL Server $SQLVersion $SQLEdition Installed"
} else {
    Write-Output "ERROR: setup.exe not found at $SetupPath"
    exit 1
}

# Optional: Install SSMS silently
Write-Output "Installing SSMS..."
Start-Process -FilePath $SSMSExe -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow
Write-Output "SSMS Installed"

# Delete Temp Folder
if (Test-Path $TempPath) {
    Remove-Item -Path $TempPath -Recurse -Force
    Write-Output "Deleted folder: $TempPath"
} else {
    Write-Output "Folder not found: $TempPath"
}
