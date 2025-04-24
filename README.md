<h1><b>SQL Server</b></h1>

## [SQLServerUnattendedInstall.ps1 Notes](https://github.com/whuynhit/SQLServer/blob/main/SQL%20Server%20Unattended%20Install/SQLServerUnattendedInstall.ps1)
- SQLServerUnattendedInstall.ps1 script uses an ISO media file that gets **mounted** to install SQL Server unattendedly with the configuration file.
- ISO file can be stored in a network share/online storage, from which it gets copied to a temporary folder on the system to prepare for mounting.
- SSMS-Setup.exe may also be stored in a network share/online storage, from which it can initiate the unattended SSMS install.
- The configuration file is already included within the script so that it generates a configuration file with desired parameters in a temporary folder that will be deleted when all installs complete successfully

## [SQLServerUNCInstall.ps1 Notes](https://github.com/whuynhit/SQLServer/blob/main/SQL%20Server%20Unattended%20Install/SQLServerUNCInstall.ps1)
- SQLServerUNCInstall.ps1 script uses a setup.exe that is **extracted** from the ISO media to install SQL Server unattendedly with the configuration file.
- Extracted files including the setup.exe can be stored in a network share/online storage, from which it can initiate the unattended SQL Server install.
- SSMS-Setup.exe may also be stored in a network share/online storage, from which it can initiate the unattended SSMS install.
- The configuration file is already included within the script so that it generates a configuration file with desired parameters in a temporary folder that will be deleted when all installs complete successfully.
