-- ============================================================
-- SQL Lab 3 & 4  |  Somaia Mahmoud Shapaan
-- ============================================================

-- ══════════════ LAB 3 ══════════════

-- Part 1: JOIN Queries

-- (1) Department with Manager name
SELECT dep.Dep_ID, dep.Dep_Name, emp.FirstName AS ManagerFirstName
FROM Department dep
INNER JOIN Employee emp ON dep.ManagerID = emp.Emp_ID;

-- (2) Course with Topic name
SELECT c.Crs_Name, t.Topic_Name
FROM Course c
INNER JOIN Topic t ON c.Crs_ID = t.Crs_ID;

-- (3) Dependant with Employee full name
SELECT d.*, e.FirstName + ' ' + e.LastName AS EmployeeFullName
FROM Dependant d
INNER JOIN Employee e ON d.Emp_ID = e.Emp_ID;

-- (4) Employees in Cairo or Alex
SELECT Emp_ID, FirstName, Address
FROM Employee
WHERE Address = 'cairo' OR Address = 'Alex';

-- (5) Employees whose name starts with 'a'
SELECT *
FROM Employee
WHERE FirstName LIKE 'a%';

-- (6a) Employees in Dep 1 with salary 1000-5000 (AND / BETWEEN)
SELECT *
FROM Employee
WHERE Dep_ID = 1
  AND Salary >= 1000 AND Salary <= 5000;

-- (6b) Same using BETWEEN
SELECT *
FROM Employee
WHERE Dep_ID = 1
  AND Salary BETWEEN 1000 AND 5000;

-- (7) Students with grade >= 80 in courses with duration >= 80
SELECT s.St_ID, s.FirstName, s.LastName
FROM Student s
INNER JOIN Student_Course sc ON s.St_ID = sc.St_ID
INNER JOIN Course c          ON c.Crs_ID = sc.Crs_ID
WHERE sc.Grade >= 80 AND c.Duration >= 80;

-- (8) Students supervised by Noha Mohamed
SELECT s.FirstName, s.MiddleName, s.LastName
FROM Student s
INNER JOIN Employee e ON s.Supervisor_ID = e.Emp_ID
WHERE e.FirstName LIKE '%Noha%' AND e.LastName LIKE '%Mohamed%';

-- (10) All employees with their department (LEFT JOIN)
SELECT e.Emp_ID, e.FirstName, e.LastName, d.Dep_Name
FROM Employee e
LEFT JOIN Department d ON e.Dep_ID = d.Dep_ID;

-- (11) Employees with department and manager
SELECT
    e.Emp_ID,
    e.FirstName  AS EmployeeFirstName,
    e.LastName   AS EmployeeLastName,
    d.Dep_Name,
    m.FirstName  AS ManagerFirstName,
    m.LastName   AS ManagerLastName
FROM Employee e
LEFT JOIN Department d  ON e.Dep_ID   = d.Dep_ID
LEFT JOIN Employee   m  ON d.ManagerID = m.Emp_ID;

-- (12) Employees with dependants
SELECT
    e.Emp_ID,
    e.FirstName AS EmployeeFirstName,
    e.LastName  AS EmployeeLastName,
    e.Dep_ID,
    d.Dep_Name  AS DependentName
FROM Employee e
LEFT JOIN Dependant d ON e.Dep_ID = d.Emp_ID;

-- (13) Insert self
INSERT INTO Employee (FirstName, LastName, Dep_ID, SSN, Manager_ID, Salary)
VALUES ('Somaia', 'Shapaan', 10, 1000, 1, 3000);

-- (14) Insert friend
INSERT INTO Employee (FirstName, LastName, Dep_ID, SSN)
VALUES ('FriendFirstName', 'FriendLastName', 10, 1010);

-- ──────── Part 2: DDL – Create Tables ────────

CREATE TABLE Instructor (
    Ins_ID    INT PRIMARY KEY,
    FirstNAME NVARCHAR(50),
    LastName  NVARCHAR(50),
    Salary    INT,
    Overtime  INT,
    HireDate  DATE,
    Address   NVARCHAR(100),
    BD        DATE,
    Age       AS (YEAR(GETDATE()) - YEAR(BD)),
    NetSalary AS (Salary + Overtime)
);

CREATE TABLE Course (
    CID    INT PRIMARY KEY,
    C_Name NVARCHAR(50),
    Duration INT
);

CREATE TABLE Lab (
    LID      INT PRIMARY KEY,
    Location NVARCHAR(50),
    Capacity INT,
    CID      INT,
    CONSTRAINT FK_Lab_Course FOREIGN KEY (CID) REFERENCES Course (CID)
);

CREATE TABLE Teach (
    Ins_ID INT,
    CID    INT,
    CONSTRAINT PK_Teach          PRIMARY KEY (Ins_ID, CID),
    CONSTRAINT FK_Teach_Instructor FOREIGN KEY (Ins_ID) REFERENCES Instructor (Ins_ID),
    CONSTRAINT FK_Teach_Course     FOREIGN KEY (CID)    REFERENCES Course (CID)
);

-- ERD Implementation With Constraints
CREATE TABLE Instructor (
    Ins_ID    INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName  NVARCHAR(50) NOT NULL,
    Salary    INT DEFAULT 3000 CHECK (Salary BETWEEN 1000 AND 5000),
    Overtime  INT NOT NULL UNIQUE DEFAULT 0,
    HireDate  DATE DEFAULT GETDATE(),
    Address   NVARCHAR(10) CHECK (Address IN ('cairo','alex')),
    BD        DATE NOT NULL,
    Age       AS (YEAR(GETDATE()) - YEAR(BD)),
    NetSalary AS (Salary + Overtime)
);

CREATE TABLE Course (
    C_ID     INT IDENTITY(1,1) PRIMARY KEY,
    C_Name   NVARCHAR(50) NOT NULL,
    Duration INT UNIQUE NOT NULL
);

CREATE TABLE Lab (
    L_ID     INT IDENTITY(1,1),
    Location NVARCHAR(50),
    Capacity INT CHECK (Capacity < 20),
    C_ID     INT NOT NULL,
    CONSTRAINT PK_Lab PRIMARY KEY (L_ID, C_ID),
    CONSTRAINT FK_Lab_Course
        FOREIGN KEY (C_ID) REFERENCES Course(C_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Teach (
    Ins_ID INT NOT NULL,
    C_ID   INT NOT NULL,
    CONSTRAINT PK_Teach              PRIMARY KEY (Ins_ID, C_ID),
    CONSTRAINT FK_Teach_Instructor
        FOREIGN KEY (Ins_ID) REFERENCES Instructor(Ins_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT FK_Teach_Course
        FOREIGN KEY (C_ID) REFERENCES Course(C_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- ══════════════ LAB 4 ══════════════

-- Part 1: Aggregation Functions

-- (1) AVG hour rate per course
SELECT c.Crs_Name, AVG(i.HourRate) AS AVG_HOUR_RATE
FROM Course c
INNER JOIN Instructor_Course ic ON c.Crs_ID = ic.Crs_ID
INNER JOIN Instructor i         ON ic.Ins_ID = i.Ins_ID
WHERE i.HourRate IS NOT NULL
GROUP BY c.Crs_Name;

-- (2) MAX / MIN / AVG salary + employee count per department
SELECT
    d.Dep_Name,
    MAX(e.Salary) AS Max_Salary,
    MIN(e.Salary) AS Min_Salary,
    AVG(e.Salary) AS Avg_Salary,
    COUNT(e.Emp_ID) AS Employee_Count
FROM Department d
INNER JOIN Employee e ON d.Dep_ID = e.Dep_ID
GROUP BY d.Dep_Name;

-- (3) Total salary per dept where employees > 50 yrs and total > 3500
SELECT d.Dep_Name, SUM(e.Salary) AS Total_Salary
FROM Department d
INNER JOIN Employee e ON d.Dep_ID = e.Dep_ID
WHERE DATEDIFF(YEAR, e.DateOfBirth, GETDATE()) > 50
GROUP BY d.Dep_Name
HAVING SUM(e.Salary) > 3500;

-- Part 2: Sub Queries

-- (4) Employees with salary below average
SELECT *
FROM Employee
WHERE Salary < (SELECT AVG(Salary) FROM Employee);

-- (5) Addresses whose average salary is below overall average
SELECT Address
FROM Employee
GROUP BY Address
HAVING AVG(Salary) < (SELECT AVG(Salary) FROM Employee);
