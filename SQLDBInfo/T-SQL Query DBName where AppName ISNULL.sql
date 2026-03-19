-- Queries for Databases where Application_Name is NULL
SELECT 
	inv.Server_Name, 
	inv.Instance_Name, 
	inv.Database_Name, 
	inv.Database_Type, 
	app.Application_Name,
	si.SQL_Version,
	si.Edition,
	si.Product_Version,
	si.ENV,
	inv.Database_Status, 
	inv.Recovery_Model, 
	inv.Compatibility_Level, 
	inv.Database_SizeGB,
	inv.CaptureDate
FROM DBInfo inv
LEFT JOIN AppMap app
ON inv.Server_Name = app.Server_Name
AND inv.Instance_Name = app.Instance_Name
AND inv.Database_Name = app.Database_Name
INNER JOIN ServerInfo si
ON si.Server_Name = inv.Server_Name
WHERE Application_Name IS NULL;
/*OR app.Database_Name IN (
'DB1',
'DB2',
'DB3'
);*/
