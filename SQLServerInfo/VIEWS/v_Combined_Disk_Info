-- Disk Info but with  Disk E and Disk F Used/Free storage values summed together.
CREATE VIEW v_Combined_Disk_Info AS
(SELECT 
	Server_Name, 
	Usage, 
	SUM(SpaceGB) AS [SpaceGB], 
	SUM(TotalGB) AS [TotalGB]
FROM v_DiskInfo
GROUP BY 
	Server_Name, 
	Usage);
