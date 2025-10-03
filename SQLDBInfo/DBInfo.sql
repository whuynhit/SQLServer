-- Queries for List of Database Information on Server
DECLARE @ServerName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('MachineName') AS NVARCHAR(128)));
DECLARE @InstanceName NVARCHAR(128) = UPPER(CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128)));

SELECT  
    @ServerName AS [Server_Name],
    @InstanceName AS [Instance_Name],
    d.name AS [Database_Name],
    CASE
        WHEN d.database_id > 4 THEN 'User'
        ELSE 'System'
    END AS [Database_Type],
    d.state_desc AS [Database_Status],
    d.recovery_model_desc AS [Recovery_Model],
    d.compatibility_level AS [Compatibility_Level],
    CAST(ISNULL(SUM(mf.size),0) * 8.0 / 1024 / 1024 AS DECIMAL(10,2)) AS [Database_SizeGB]
FROM sys.databases d
LEFT JOIN sys.master_files mf 
    ON d.database_id = mf.database_id
GROUP BY d.database_id, d.name, d.state_desc, d.recovery_model_desc, d.compatibility_level
ORDER BY d.name;
