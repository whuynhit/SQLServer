CREATE TABLE dbo.SQLServerInventory (
    Server_Name NVARCHAR(128),
    Instance_Name NVARCHAR(128),
    IP_Address NVARCHAR(50),
    ENV NVARCHAR(20),
    Location NVARCHAR(50),
    SQL_Version NVARCHAR(50),
    Edition NVARCHAR(128),
    Product_Version NVARCHAR(128),
    CPU_Count INT,
    Memory_MB INT,
    DiskE_UsedSpaceGB DECIMAL(10,2),
    DiskE_FreeSpaceGB DECIMAL(10,2),
    DiskE_TotalSpaceGB DECIMAL(10,2),
    DiskF_UsedSpaceGB DECIMAL(10,2),
    DiskF_FreeSpaceGB DECIMAL(10,2),
    DiskF_TotalSpaceGB DECIMAL(10,2),
    CaptureDate DATETIME DEFAULT GETDATE()
);
