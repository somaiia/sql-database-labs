-- ============================================================
-- SQL Lab 5  |  Somaia Mahmoud Shapaan
-- Ranking Functions, CTE, Schema, CASE, Variables
-- ============================================================

-- Part 1: Ranking Functions & CTE

-- (1) DENSE_RANK all employees by salary DESC
WITH EmployeeRank AS (
    SELECT
        Emp_ID,
        CONCAT(FirstName, ' ', LastName) AS EmployeeName,
        Salary,
        DENSE_RANK() OVER (ORDER BY Salary DESC) AS SalaryRank
    FROM Employee
)
SELECT * FROM EmployeeRank;

-- (2) DENSE_RANK per department by salary DESC
WITH DeptSalaryRank AS (
    SELECT
        Emp_ID,
        CONCAT(FirstName, ' ', LastName) AS EmployeeName,
        Salary,
        Dep_ID,
        DENSE_RANK() OVER (PARTITION BY Dep_ID ORDER BY Salary DESC) AS SalaryRank
    FROM Employee
)
SELECT * FROM DeptSalaryRank;

-- (3) ROW_NUMBER by Age DESC
WITH AgeRanking AS (
    SELECT
        Emp_ID,
        CONCAT(FirstName, ' ', LastName) AS EmployeeName,
        Age,
        ROW_NUMBER() OVER (ORDER BY Age DESC) AS AgeRank
    FROM Employee
)
SELECT * FROM AgeRanking;

-- (4) ROW_NUMBER per Address ordered by Age DESC
SELECT
    Emp_ID,
    CONCAT(FirstName, ' ', LastName) AS EmployeeName,
    Age,
    Address,
    ROW_NUMBER() OVER (PARTITION BY Address ORDER BY Age DESC) AS AgeRank
FROM Employee;

-- (5) NTILE(3) partition by Dep_ID
SELECT
    Emp_Id,
    CONCAT(FirstName, ' ', LastName) AS Names,
    Dep_Id,
    NTILE(3) OVER (ORDER BY Dep_Id) AS Group_No
FROM Employee;

-- (6) Delete the oldest employee using ROW_NUMBER
WITH AgeRanking AS (
    SELECT Emp_ID, ROW_NUMBER() OVER (ORDER BY Age) AS Age_Rank
    FROM Employee
)
DELETE FROM Employee
WHERE Emp_ID IN (
    SELECT Emp_ID FROM AgeRanking
    WHERE Age_Rank = (SELECT MAX(Age_Rank) FROM AgeRanking)
);

-- ── Part 2: Schema & IF EXISTS ────────────────────────────────────────

-- (7) Create HR schema if it doesn''t exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'HR')
BEGIN
    CREATE SCHEMA HR;
END

-- (8) Transfer tables to HR schema
ALTER SCHEMA HR TRANSFER dbo.Student;
ALTER SCHEMA HR TRANSFER dbo.Instructor;
ALTER SCHEMA HR TRANSFER dbo.Employee;
GO

-- ── Part 3: CASE / IIF ───────────────────────────────────────────────

-- (9) Gender description using CASE
SELECT
    Emp_ID,
    FirstName,
    LastName,
    CASE Gender
        WHEN 'M' THEN 'Male'
        WHEN 'F' THEN 'Female'
        ELSE 'Unknown'
    END AS Gender_Description
FROM HR.Employee;

-- ── Part 5: Variables, SELECT INTO, INSERT Based on SELECT ───────────

-- (11) Declare a table variable
DECLARE @TempEmp TABLE (
    EID     INT,
    ESalary INT,
    FName   NVARCHAR(50)
);

-- (12) Insert from Employee into table variable
INSERT INTO @TempEmp (EID, ESalary, FName)
SELECT Emp_ID, Salary, FirstName FROM HR.Employee;

SELECT * FROM @TempEmp;

-- (13) SELECT INTO – copy all data
SELECT * INTO New_Department_Data FROM Department;

-- (14) SELECT INTO – empty copy (structure only)
SELECT * INTO New_Department_Data FROM Department WHERE 1 = 2;
