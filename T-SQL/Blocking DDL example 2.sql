-- Use the test database
USE BlockingTestDB;
GO

-- Begin a transaction that updates a row but never commits
BEGIN TRAN;

UPDATE Employees
SET Name = 'Alice Updated'
WHERE EmployeeID = 1;

-- DO NOT COMMIT OR ROLLBACK
-- This session is now holding a lock
