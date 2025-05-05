SELECT 
    SERVERPROPERTY('MachineName') AS [Server Name], 
    servicename AS [Service Name], 
    instant_file_initialization_enabled AS [Instant File Initialization Enabled]
FROM 
    sys.dm_server_services;