---------------Create datebase------------------

CREATE DATABASE HRadmin
GO

USE HRadmin
GO

CREATE TABLE Grades
(
	gradeid INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
	grade NVARCHAR(20) NOT NULL
)
GO

CREATE TABLE Departments
(
	departmentid INT  IDENTITY(300,1) NOT NULL PRIMARY KEY,
	departmentname NVARCHAR(60) NOT NULL,
)
GO

CREATE TABLE Employees
(
	employeeid INT IDENTITY (1000,1) NOT NULL PRIMARY KEY,
	emploteename NVARCHAR(50) NOT NULL,
	joindate DATETIME ,
	email NVARCHAR(50) ,
	phone NVARCHAR(15),
	departmentid INT
	REFERENCES Departments(departmentid),
)
GO

CREATE TABLE Gradeshistories
(
	employeeid INT IDENTITY(200,1) NOT NULL
	REFERENCES Employees(employeeid),
	gradeid INT NOT NULL
	REFERENCES Grades(gradeid),
	startDate DATETIME,
	endDate DATETIME ,
	PRIMARY KEY (employeeid,gradeid)
)
GO



CREATE TABLE Designations
(
	designationid INT IDENTITY(500,1)NOT NULL PRIMARY KEY,
	Designation NVARCHAR(50)
)
GO

CREATE TABLE Designationhistories
(
	employeeid INT NOT NULL
	REFERENCES Employees(employeeid),
	Designations INT NOT NULL
	REFERENCES Designations(designationid),
	startDate DATETIME,
	endDate DATETIME,
	PRIMARY KEY (employeeid,designations)
)
GO


--USE master
--GO
--DROP DATABASE HRadmin
--GO