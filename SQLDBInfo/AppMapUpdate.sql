UPDATE inv
SET inv.Application_Name = map.Application_Name
FROM dbo.SQLDatabaseInventory inv
INNER JOIN dbo.ApplicationMapping map
    ON inv.Server_Name = map.Server_Name
   AND inv.Instance_Name = map.Instance_Name
   AND inv.Database_Name = map.Database_Name
WHERE inv.Application_Name IS NULL;
