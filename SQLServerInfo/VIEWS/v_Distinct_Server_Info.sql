-- View version of Distinct Server Info [Tableau Custom Query]
CREATE VIEW v_Distinct_Server_Info  AS
(SELECT 
DISTINCT(Server_Name),
IP_Address,
ENV,
Location,
SQL_Version,
Edition,
Product_Version,
CPU_Count,
DiskE_UsedSpaceGB,
DiskE_FreeSpaceGB,
DiskE_TotalSpaceGB,
DiskF_UsedSpaceGB,
DiskF_FreeSpaceGB,
DiskF_TotalSpaceGB
FROM ServerInfo);
