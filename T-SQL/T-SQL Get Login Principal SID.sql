-- This gets the login principal SID
SELECT 'CREATE LOGIN [' + name + '] WITH PASSWORD = ''<PasswordHere>'', SID = ' 
    + CONVERT(VARCHAR(MAX), sid, 1) + ', DEFAULT_DATABASE = [' + default_database_name + '];'
FROM sys.sql_logins
WHERE name IN ('Login1', 'Login2', ...);
