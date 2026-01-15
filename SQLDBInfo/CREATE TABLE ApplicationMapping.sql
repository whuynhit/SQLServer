CREATE TABLE dbo.ApplicationMapping (
    Server_Name NVARCHAR(128),
    Instance_Name NVARCHAR(128),
    Database_Name NVARCHAR(256),
    Application_Name NVARCHAR(128),
    PRIMARY KEY (Server_Name, Instance_Name, Database_Name)
);
