CREATE VIEW v_Database_Disk_Info AS
(SELECT 
	di.Server_Name, 
	db.Instance_Name, 
	db.Database_Name, 
	db.Database_SizeGB, 
	di.Usage, 
	SUM(di.SpaceGB) AS [SpaceGB], 
	SUM(di.TotalGB) AS [TotalGB] 
FROM v_DiskInfo di
INNER JOIN DBInfo db
ON di.Server_Name = db.Server_Name
GROUP BY 
	di.Server_Name, 
	db.Instance_Name, 
	db.Database_Name, 
	db.Database_SizeGB, 
	di.Usage);
