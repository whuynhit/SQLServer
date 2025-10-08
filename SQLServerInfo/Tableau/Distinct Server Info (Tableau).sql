-- For Tableau, Queries Server Info based on Distinct Server Names to prevent duplicate Server Names if there are multiple Named Instances on a Server.
SELECT 
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
FROM ServerInfo;
