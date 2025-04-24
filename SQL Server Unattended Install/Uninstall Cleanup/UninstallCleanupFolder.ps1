$TempPath = "D:\Temp"	# Temporary Folder Directory
$InstanceDir = "D:\Program Files"	# Instance and Shared Features Directory
$SharedWOWDir = "D:\Program Files (x86)"	# Shared Features 32-bit/x86/WOW64 Directory
$SQLBackupDir       = "G:\BACKUPS"
$SQLUserDBDir       = "E:\DATA"
$SQLUserDBLogDir    = "F:\LOGS"
$SQLTempDBDir       = "E:\TEMPDB"
$SQLTempDBLogDir    = "F:\TEMPLOGS"

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

foreach ($path in $RequiredPaths){
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Output "Deleted folder: $path"
    } else {
        Write-Output "Folder not found: $path"
    }
}