CREATE TABLE dbo.SQLDatabaseInventory (
    Server_Name NVARCHAR(128),
    Instance_Name NVARCHAR(128),
    Database_Name NVARCHAR(256),
    Database_Type NVARCHAR(20),       -- User / System
    Database_Status NVARCHAR(60),
    Recovery_Model NVARCHAR(60),
    Compatibility_Level INT,
    Database_SizeGB DECIMAL(10,2),
--  Application_Name NVARCHAR(128) NULL, -- linked via ApplicationMapping
    CaptureDate DATETIME DEFAULT GETDATE()
);
