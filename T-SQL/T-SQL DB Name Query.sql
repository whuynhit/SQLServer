-- Queries All User Databases in Server
SELECT @@SERVERNAME N'Server Name', name N'User Database'
FROM sys.databases
WHERE database_id > 4
ORDER BY N'User Database';