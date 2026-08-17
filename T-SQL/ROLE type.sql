-- Describe Role type for each Database User
DECLARE @RoleMemberships TABLE (
    DatabaseName SYSNAME,
    RoleName SYSNAME,
    UserName SYSNAME,
    UserType VARCHAR(60)
);

INSERT INTO @RoleMemberships
EXEC sp_MSforeachdb '
    USE [?];
    SELECT 
        DB_NAME() AS DatabaseName,
        r.name AS RoleName,
        m.name AS UserName,
        m.type_desc AS UserType
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id;
';

SELECT * FROM @RoleMemberships 
WHERE DatabaseName NOT IN ('master','model', 'msdb', 'tempdb')
AND UserName != 'dbo'
ORDER BY DatabaseName, RoleName, UserName;
