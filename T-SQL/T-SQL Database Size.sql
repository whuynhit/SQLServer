-- View size of all databases in the server.
SELECT 
    d.name AS DatabaseName, 
    CAST(SUM(mf.size * 8.0 / 1024) AS DECIMAL(18,2)) AS TotalSize_MB
FROM sys.databases d
JOIN sys.master_files mf ON d.database_id = mf.database_id
GROUP BY d.name
ORDER BY TotalSize_MB DESC;
