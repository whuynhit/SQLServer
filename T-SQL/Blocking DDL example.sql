-- Use the test database
USE BlockingTestDB;
GO

-- This query will block because the row is locked in Session 1
UPDATE Employees
SET Name = 'Blocked Update'
WHERE EmployeeID = 1;
