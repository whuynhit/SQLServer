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
;SQL Server 2022 Configuration File
[OPTIONS]

; By specifying this parameter and accepting Microsoft SQL Server terms, you acknowledge that you have read and understood the terms of use. 

IACCEPTSQLSERVERLICENSETERMS="True"

; Specifies a Setup work flow, like INSTALL, UNINSTALL, or UPGRADE. This is a required parameter. 

ACTION="Install"

; Use the /ENU parameter to install the English version of SQL Server on your localized Windows operating system. 

ENU="True"

; Indicates whether the supplied product key is covered by Service Assurance. 

PRODUCTCOVEREDBYSA="False"

; Specifies that SQL Server Setup should not display the privacy statement when ran from the command line. 

SUPPRESSPRIVACYSTATEMENTNOTICE="False"

; Setup will not display any user interface. 

QUIET="True"

; Setup will display progress only, without any user interaction. 

QUIETSIMPLE="False"

; Specify whether SQL Server Setup should discover and include product updates. The valid values are True and False or 1 and 0. By default SQL Server Setup will include updates that are found. 

UpdateEnabled="True"

; If this parameter is provided, then this computer will use Microsoft Update to check for updates. 

USEMICROSOFTUPDATE="True"

; Specifies that SQL Server Setup should not display the paid edition notice when ran from the command line. 

SUPPRESSPAIDEDITIONNOTICE="False"

; Specify the location where SQL Server Setup will obtain product updates. The valid values are "MU" to search Microsoft Update, a valid folder path, a relative path such as .\MyUpdates or a UNC share. By default SQL Server Setup will search Microsoft Update or a Windows Update service through the Window Server Update Services. 

UpdateSource="MU"

; Specifies features to install, uninstall, or upgrade. The list of top-level features include SQL, AS, IS, MDS, and Tools. The SQL feature will install the Database Engine, Replication, Full-Text, and Data Quality Services (DQS) server. The Tools feature will install shared components. 

FEATURES=SQLENGINE

; Displays the command line parameters usage. 

HELP="False"

; Specifies that the detailed Setup log should be piped to the console. 

INDICATEPROGRESS="False"

; Specify a default or named instance. MSSQLSERVER is the default instance for non-Express editions and SQLExpress for Express editions. This parameter is required when installing the SQL Server Database Engine (SQL), or Analysis Services (AS). 

INSTANCENAME="MSSQLSERVER"

; Specify the root installation directory for shared components.  This directory remains unchanged after shared components are already installed. 

INSTALLSHAREDDIR="$SharedDir"

; Specify the root installation directory for the WOW64 shared components.  This directory remains unchanged after WOW64 shared components are already installed. 

INSTALLSHAREDWOWDIR="$SharedWOWDir"

; Specify the Instance ID for the SQL Server features you have specified. SQL Server directory structure, registry structure, and service names will incorporate the instance ID of the SQL Server instance. 

INSTANCEID="MSSQLSERVER"

; Startup type for the SQL Server CEIP service. 

SQLTELSVCSTARTUPTYPE="Automatic"

; Account for SQL Server CEIP service: Domain\User or system account. 

SQLTELSVCACCT="NT Service\SQLTELEMETRY"

; Specify the installation directory. 

INSTANCEDIR="$InstanceDir"

; Agent account name. 

AGTSVCACCOUNT="NT Service\SQLSERVERAGENT"

; Auto-start service after installation.  

AGTSVCSTARTUPTYPE="Automatic"

; Startup type for the SQL Server service. 

SQLSVCSTARTUPTYPE="Automatic"

; Level to enable FILESTREAM feature at (0, 1, 2 or 3). 

FILESTREAMLEVEL="0"

; The max degree of parallelism (MAXDOP) server configuration option. 

SQLMAXDOP="4"

; Set to "1" to enable RANU for SQL Server Express. 

ENABLERANU="False"

; Specifies a Windows collation or an SQL collation to use for the Database Engine. 

SQLCOLLATION="SQL_Latin1_General_CP1_CI_AS"

; Account for SQL Server service: Domain\User or system account. 

SQLSVCACCOUNT="NT Service\MSSQLSERVER"

; Set to "True" to enable instant file initialization for SQL Server service. If enabled, Setup will grant Perform Volume Maintenance Task privilege to the Database Engine Service SID. This may lead to information disclosure as it could allow deleted content to be accessed by an unauthorized principal. 

SQLSVCINSTANTFILEINIT="True"

; Windows account(s) to provision as SQL Server system administrators. 

SQLSYSADMINACCOUNTS=$SQLSysAdminAcct

; The default is Windows Authentication. Use "SQL" for Mixed Mode Authentication. 

SECURITYMODE="SQL"

SAPWD="$SAPasswd"

; The number of Database Engine TempDB files. 

SQLTEMPDBFILECOUNT="4"

; Specifies the initial size of a Database Engine TempDB data file in MB. 

SQLTEMPDBFILESIZE="8"

; Specifies the automatic growth increment of each Database Engine TempDB data file in MB. 

SQLTEMPDBFILEGROWTH="64"

; Specifies the initial size of the Database Engine TempDB log file in MB. 

SQLTEMPDBLOGFILESIZE="8"

; Specifies the automatic growth increment of the Database Engine TempDB log file in MB. 

SQLTEMPDBLOGFILEGROWTH="64"

; Default directory for the Database Engine backup files. 

SQLBACKUPDIR="$SQLBackupDir"

; Default directory for the Database Engine user databases. 

SQLUSERDBDIR="$SQLUserDBDir"

; Default directory for the Database Engine user database logs. 

SQLUSERDBLOGDIR="$SQLUserDBLogDir"

; Directories for Database Engine TempDB files. 

SQLTEMPDBDIR="$SQLTempDBDir"

; Directory for the Database Engine TempDB log files. 

SQLTEMPDBLOGDIR="$SQLTempDBLogDir"

; Provision current user as a Database Engine system administrator for SQL Server 2022 Express. 

ADDCURRENTUSERASSQLADMIN="False"

; Specify 0 to disable or 1 to enable the TCP/IP protocol. 

TCPENABLED="1"

; Specify 0 to disable or 1 to enable the Named Pipes protocol. 

NPENABLED="0"

; Startup type for Browser Service. 

BROWSERSVCSTARTUPTYPE="Disabled"

; Use SQLMAXMEMORY to minimize the risk of the OS experiencing detrimental memory pressure. 

SQLMAXMEMORY="2147483647"

; Use SQLMINMEMORY to reserve a minimum amount of memory available to the SQL Server Memory Manager. 

SQLMINMEMORY="0"

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