
USE HRadmin
GO
------------Insert data-----------------

INSERT INTO Grades (grade) VALUES ('G03'), ('GO1'), ('M03')
GO ----Grades table

SELECT * FROM Grades
GO

INSERT INTO Departments (departmentname) VALUES ('Accounts'),('Admin'),('Marketing')
GO -----Departments Table

SELECT * FROM Departments
Go

INSERT INTO Employees (emploteename,joindate,email,phone,departmentid) VALUES ('Rahmatullah Muzahid','2017-07-01','rmuzahid@gmail.com','01934675987',300),
	('Kaiser Faisal','2017-01-01','faisal@gmail.com','01934612612',301),
	('Azad Ahmed','2018-03-01','azad@yahoo.com','01751123123',300)
GO
SELECT * FROM Employees
GO
-------insert into data Gradeshistories----
SET IDENTITY_INSERT Gradeshistories ON 
INSERT INTO Gradeshistories (employeeid,gradeid,startDate,endDate) VALUES (1000,1,'2017-07-01','2018-06-30'),
(1000,2,'2018-07-01','2019-06-30'),(1000,3,'2019-07-01','')
SET IDENTITY_INSERT Gradeshistories OFF
GO
SET IDENTITY_INSERT Gradeshistories ON 
INSERT INTO Gradeshistories (employeeid,gradeid,startDate,endDate) VALUES (1001,1,'2020-07-01','2022-06-30'),
(1002,2,'2021-07-01','2022-06-30'),(1002,3,'2022-07-01','')
SET IDENTITY_INSERT Gradeshistories OFF
GO

SELECT * FROM Gradeshistories
GO

---------inert into Designations-------------

INSERT INTO Designations (Designation) VALUES ('Accounts Assistant'),('Accountant'),('Assistant Accounts Manager')
GO

SELECT * FROM Designations
GO

---------inert into Designationhistories-------------
INSERT INTO Designationhistories(employeeid,designations,startDate,endDate) VALUES
(1000,500,'2017-07-01','2018-06-30'),
(1000,501,'2018-07-01','2019-06-30'),
(1000,502,'2019-07-01','')
GO
INSERT INTO Designationhistories(employeeid,designations,startDate,endDate) VALUES
(1001,500,'2020-07-01','2020-06-30'),
(1001,501,'2019-08-01','2020-06-30'),
(1002,502,'2019-08-01','')
GO

SELECT * FROM Designationhistories
GO


-------------------Index Creation------------------------
CREATE INDEX IxEmpName						
ON Employees (emploteename)
GO
EXEC sp_helpindex 'Employees'
GO

----------------Create view---------------------
/*
	A new employee must be registered with a designation and a grade.
	It must be implemented in procedural ways
*/
--------------View Employee Designation & Grades History ----------------------
CREATE VIEW Vemployee_Designation_histories
WITH ENCRYPTION
AS
	SELECT E.emploteename,D.Designation,De.departmentname,G.grade,E.email,E.phone,Gh.startDate,Gh.endDate
	FROM Employees E             -------Employees Table
	INNER JOIN Departments De
	ON E.departmentid = De.departmentid --------department table
	INNER JOIN Designationhistories Dh
	ON Dh.employeeid = E.employeeid ----------------Designationhistorie table
	INNER JOIN Designations D
	ON Dh.Designations = D.designationid     --------------Designations table
	INNER JOIN Gradeshistories Gh     -----------------Gradeshistories table
	ON Gh.employeeid = E.employeeid
	INNER JOIN Grades G   -------------------------------------Grades table
	ON Gh.gradeid = G.gradeid
GO

SELECT * FROM Vemployee_Designation_histories
GO

----------View All Employee Service our Companny----------------

CREATE VIEW VVAllEmloyee
WITH ENCRYPTION
AS
SELECT E.emploteename,De.departmentname,E.joindate,E.email,E.phone
	FROM Employees E             -------Employees Table
	INNER JOIN Departments De
	ON E.departmentid = De.departmentid -------Department table
GO

SELECT * FROM VVAllEmloyee
GO

----------View All Employee Gradeshistories Companny----------------

CREATE VIEW  VVGradeshistories
WITH ENCRYPTION
AS
SELECT E.emploteename,Gr.grade,D.departmentname, G.startDate,G.endDate
FROM Gradeshistories G
	INNER JOIN Employees E
	ON G.employeeid = E.employeeid
	INNER JOIN Grades Gr
	ON G.gradeid = Gr.gradeid
	INNER JOIN Departments D
	ON D.departmentid = E.departmentid
GO

SELECT * FROM VVGradeshistories
GO

---------------Stored insert Procedures ------------------------

CREATE PROC SpGrades ---------insert Procedures table Grades
@G NVARCHAR(20)
AS 
INSERT INTO Grades (grade) VALUES (@G)
GO

-----------Test the procedure-------------
EXEC SpGrades 'MO1'
GO

SELECT * FROM Grades
GO

CREATE PROC SpDepartments   ---------insert Procedures table Departments
@dpt NVARCHAR(60)
AS 
INSERT INTO Departments (departmentname) VALUES (@dpt)
GO

-----------Test the procedure-------------
EXEC SpDepartments 'Marketing'
GO

SELECT * FROM Departments
GO


CREATE PROC SpEmployees     ---------insert Procedures table Employees
@name NVARCHAR(50),
@jd DATETIME,
@Em NVARCHAR(50),
@phn NVARCHAR(15),
@dpt INT
AS
INSERT INTO Employees (emploteename,joindate,email,phone,departmentid)
VALUES (@name,@jd,@Em,@phn,@dpt)
GO

-----------Test the procedure-------------
EXEC SpEmployees @name ='tanjim', @jd = '2021-06-04',@Em = 'rest@gmail.com',@phn = '0123548',@dpt = 304
GO

SELECT * FROM Employees
GO

CREATE PROC SPGradeshistories ----------insert Procedures table Gradeshistories
@gid INT,
@Std DATETIME,
@End DATETIME
AS
INSERT INTO Gradeshistories (gradeid,startDate,endDate) VALUES (@gid,@Std,@End)
GO

-----------Test the procedure-------------
EXEC SPGradeshistories @gid = 2, @Std = '2019-06-04',@End= '2021-07-05'
GO

SELECT * FROM Gradeshistories
GO

CREATE PROC SpDesignations    ----------insert Procedures table Designations
@d NVARCHAR(50)
AS
INSERT INTO Designations (Designation) VALUES (@d)
GO

-----------Test the procedure-------------
EXEC SpDesignations @d = 'Sales'
GO

SELECT * FROM Designations
GO

CREATE PROC SPDesignationhistories
@empid INT,
@dgn INT,
@std DATETIME,
@end DATETIME
AS 
INSERT INTO Designationhistories (employeeid,Designations,startDate,endDate) VALUES (@empid,@dgn,@std,@end)
GO

-----------Test the procedure-------------
EXEC SPDesignationhistories @empid = 1002, @dgn = 503,@std = '2020-12-17',@end = '2021-11-25'
GO

SELECT * FROM Designationhistories
GO

------------------Store procedure Insert Grades-----------------------

CREATE PROC spInsert_Grades @gr NVARCHAR(20)
AS
DECLARE @id INT
SELECT @id = ISNULL(MAX(gradeid), 0)+1 FROM Grades
BEGIN TRY
	INSERT INTO Grades(gradeid, grade)
	VALUES (@id, @gr )
	RETURN @id
	END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Insert Departments-----------------------

CREATE PROC spInsert_Departments @dptn NVARCHAR(60)
AS
DECLARE @id INT
SELECT @id = ISNULL(MAX(departmentid), 0)+1 FROM Departments
BEGIN TRY
	INSERT INTO Departments(departmentid, departmentname)
	VALUES (@id, @dptn )
	RETURN @id
	END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Insert Employees-----------------------

CREATE PROC spInsert_Employees @name NVARCHAR(50),
							   @joindate DATETIME,
							   @em NVARCHAR(50),
							   @phn NVARCHAR (15),
							   @dpt INT

AS
DECLARE @id INT
SELECT @id = ISNULL(MAX(employeeid), 0)+1 FROM Employees
BEGIN TRY
	INSERT INTO Employees(employeeid, emploteename,joindate,email,phone,departmentid)
	VALUES (@id, @name,@joindate,@em,@phn,@dpt)
	RETURN @id
	END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Insert Gradeshistories-----------------------

CREATE PROC spInsert_Gradeshistories @Gr INT,
									 @Stda DATETIME,
									 @endDate DATE
AS
DECLARE @id INT
SELECT @id = ISNULL(MAX(employeeid), 0)+1 FROM Gradeshistories
BEGIN TRY
	INSERT INTO Gradeshistories (employeeid, gradeid,startDate, endDate)
	VALUES (@id,@Gr, @Stda,@endDate)
	RETURN @id
	END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Insert Designations-----------------------

CREATE PROC spInsert_Designations @Dn NVARCHAR(50)
AS
DECLARE @id INT
SELECT @id = ISNULL(MAX(designationid), 0)+1 FROM Designations
BEGIN TRY
	INSERT INTO Designations (designationid, Designation)
	VALUES (@id,@Dn)
	RETURN @id
	END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Insert Designationhistories-----------------------

CREATE PROC spInsert_Designationhistories @D INT,
									      @Stda DATETIME,
								          @endDate DATETIME
                                     
AS
DECLARE @id INT
SELECT @id = ISNULL(MAX(employeeid), 0)+1 FROM Designationhistories
BEGIN TRY
	INSERT INTO Designationhistories (employeeid,Designations,startDate,endDate)
	VALUES (@id,@D,@Stda,@endDate)
	RETURN @id
	END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO
------------------Store procedure Update Grades-----------------------

CREATE PROC spUpdate_Grades @id INT,@n NVARCHAR(20)
AS
BEGIN TRY
	UPDATE Grades
	SET grade = @n
	WHERE gradeid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO


------------------Store procedure Update Departments-----------------------

CREATE PROC spUpdate_Departments @id INT,@n NVARCHAR(60)
AS
BEGIN TRY
	UPDATE Departments
	SET departmentname = @n
	WHERE departmentid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Update Employees-----------------------

CREATE PROC spUpdate_Employees @id INT,
							   @name NVARCHAR(50),
							   @joindate DATETIME,
							   @em NVARCHAR(50),
							   @phn NVARCHAR (15),
							   @dpt INT

AS
BEGIN TRY
	UPDATE Employees
	SET emploteename = @name,
		joindate = @joindate,
		email = @em,
		phone = @phn,
		departmentid = @dpt
	WHERE employeeid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Update Gradeshistories-----------------------

CREATE PROC spUpdate_Gradeshistories @id INT,
							   @Gr INT,
							   @Stda DATETIME,
							   @endDate DATETIME
AS
BEGIN TRY
	UPDATE Gradeshistories
	SET gradeid = @Gr ,
		startDate = @Stda
	WHERE employeeid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Update Designations-----------------------

CREATE PROC spUpdate_Designations @id INT,
							   @Dn NVARCHAR(50)
AS
BEGIN TRY
	UPDATE Designations
	SET Designation = @Dn
	WHERE designationid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Update Designationhistories-----------------------

CREATE PROC spUpdate_Designationhistories @id INT,
                                          @D INT,
									      @Stda DATETIME,
								          @endDate DATETIME
AS
BEGIN TRY
	UPDATE Designationhistories
	SET Designations = @D ,
		startDate = @Stda,
		endDate = @endDate
	WHERE employeeid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Delete Grades-----------------------

CREATE PROC spDelete_Grades @id INT
AS
BEGIN TRY
	DELETE Grades
	WHERE gradeid  = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Delete Departments-----------------------

CREATE PROC spDelete_Departments @id INT
AS
BEGIN TRY
	DELETE Departments
	WHERE departmentid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO


------------------Store procedure  Delete Employees-----------------------

CREATE PROC spDelete_Employees @id INT,
							   @name NVARCHAR(50),
							   @joindate DATETIME,
							   @em NVARCHAR(50),
							   @phn NVARCHAR (15),
							   @dpt INT
AS
BEGIN TRY
	DELETE Employees
	WHERE employeeid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Delete Gradeshistories-----------------------

CREATE PROC spDelete_Gradeshistories @id INT,
									 @Gr INT,
									 @Stda DATETIME,
									 @endDate DATETIME
AS
BEGIN TRY
	DELETE Gradeshistories
	WHERE employeeid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO

------------------Store procedure Delete Designations-----------------------

CREATE PROC spDelete_Designations @id INT
									 
AS
BEGIN TRY
	DELETE Designations
	WHERE designationid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO


------------------Store procedure Delete  Designationhistories-----------------------

CREATE PROC spDelete_Designationhistories @id INT,
                                          @D INT,
									      @Stda DATETIME,
								          @endDate DATETIME
									 
AS
BEGIN TRY
	DELETE Designationhistories
	WHERE employeeid = @id
END TRY
BEGIN CATCH
	;
	THROW 50001, 'Error encountered', 1
	RETURN 0
END CATCH
GO



---------------Stored Procedures ------------------------
/*
	A new employee must be registered with a designation and a grade.
	It must be implemented in procedural ways
*/

--CREATE PROC registeredemployee
--	@Name NVARCHAR(50),
--	@joindate DATETIME,
--	@email NVARCHAR(50),
--	@departmentid INT,
--	@Designationid INT,
--	@gradeid INT
--AS
--BEGIN
--	INSERT INTO Employees (emploteename,joindate,email,departmentid) VALUES (@Name,@joindate,@email,@departmentid)
--	DECLARE @employeeid int = @@IDENTITY
--	INSERT INTO Departments (departmentid) VALUES (@departmentid,@employeeid)
--	DECLARE @Department_ID int = @@IDENTITY
--	INSERT INTO Gradeshistories (gradeid) VALUES (@gradeid,@Department_ID)
--END
--GO


 /*
  * Procedures for Employees table
  * */
  -------------------------Insert procedure--------------------------------

CREATE PROC SSpPEmployees	
			@name NVARCHAR(50),
			@jd DATETIME OUTPUT,
			@Em NVARCHAR(50),
			@phn NVARCHAR(15),
			@dpt INT
			
AS
	DECLARE @id INT
	BEGIN TRY
		insert into Employees(emploteename,joindate,email,phone,departmentid) values (@name, @jd,@Em,@phn,@dpt)
		
	END TRY
	BEGIN CATCH
		DECLARE @errmessage nvarchar(500)
		set @errmessage = ERROR_MESSAGE()
		RAISERROR( @errmessage, 11, 1)
		return 
	END CATCH
GO

-----------Test the procedure-------------
EXEC SSpPEmployees @name = 'Jhon',@jd = '2019-1-2',@Em ='XXXX@mail.com',@phn='01XXXXXXXXX',@dpt = 301
GO

SELECT * FROM Employees
GO

----------------------------Update procedure---------------------------------
CREATE PROC spUpEmployees 
			@emid INT,
			@name NVARCHAR(50),
			@jd DATETIME OUTPUT,
			@Em NVARCHAR(50),
			@phn NVARCHAR(15),
			@dpt INT		
AS
BEGIN TRY
	UPDATE Employees SET emploteename =ISNULL(@name,emploteename),joindate = ISNULL(@jd,joindate),email=ISNULL(@em, email),
	phone =ISNULL(@phn,phone),departmentid = ISNULL(@dpt,departmentid)
	WHERE employeeid = @emid	
END TRY
BEGIN CATCH
	DECLARE @errmessage nvarchar(500)
	set @errmessage = ERROR_MESSAGE()
	RAISERROR( @errmessage, 11, 1)
	return 
END CATCH
return 
GO 

-----------Test the procedure-------------
EXEC spUpEmployees @emid= 1003,@name = 'Jack ma',@jd = '2020-1-14',@Em = 'jackma@hotmail.com',@phn = '+01XXXXXXXXXX',@dpt = 304
GO

SELECT * FROM Employees
GO


----------------------------DELETE procedure---------------------------------
CREATE PROC spDeleteEmployees   @employeeid INT
AS
IF EXISTS (SELECT 1 FROM Employees WHERE employeeid=@employeeid)
BEGIN

	raiserror ('Cannot delete Employees', 11, 1)
	return
END
ELSE
BEGIN
	DELETE Employees WHERE employeeid = @employeeid
END
GO

-----------Test the procedure-------------
EXEC spDeleteEmployees @employeeid = 2013

SELECT * FROM Employees
GO


----------------------------User Defined Function(UDF)----------------------------------------

CREATE FUNCTION fnEmployee_Designation (@emploteename NVARCHAR(500)) RETURNS TABLE
AS
RETURN
(
	SELECT E.emploteename,D.Designation,De.departmentname,G.grade,E.email,E.phone,Gh.startDate,Gh.endDate
	FROM Employees E             -------Employees Table
	INNER JOIN Departments De
	ON E.departmentid = De.departmentid --------department table
	INNER JOIN Designationhistories Dh
	ON Dh.employeeid = E.employeeid ----------------Designationhistorie table
	INNER JOIN Designations D
	ON Dh.Designations = D.designationid     --------------Designations table
	INNER JOIN Gradeshistories Gh     -----------------Gradeshistories table
	ON Gh.employeeid = E.employeeid
	INNER JOIN Grades G   -------------------------------------Grades table
	ON Gh.gradeid = G.gradeid
	WHERE E.emploteename = @emploteename
)
GO

SELECT dbo.fnEmployee_Designation








------------------ DML triggers--------------------
---------DML Trigger Insert data---------------

--INSERT INTO Grades (grade) VALUES ('G03'), ('GO1'), ('M03')
--GO

--SELECT * FROM Grades
--GO

--SELECT * FROM Gradeshistories
--GO

--CREATE TRIGGER TrGrades
--ON Grades
--FOR INSERT, UPDATE, DELETE
--AS
--BEGIN
--	PRINT 'Trigger Fired'
--	ROLLBACK TRANSACTION
--END
--GO
-------------Insert---------
--CREATE TRIGGER TrInGrades
--ON Grades
--FOR INSERT 
--AS 
--BEGIN 
--	DECLARE @j INT, @g NVARCHAR(20), @i INT  -------For Grades
--	SELECT @g = grade, @i = gradeid FROM inserted
	
--	UPDATE Gradeshistories
--	SET gradeid = gradeid + @i
--	WHERE gradeid = @j
--	END 
--GO
--SELECT * FROM Gradeshistories
--GO
--INSERT INTO Gradeshistories (gradeid,startDate,endDate) VALUES (10,'2017-07-01','2018-06-30'),(11,'2018-07-01','2019-06-30'),(12,'2019-07-01')
--GO

----------------- DELETE----------------
--CREATE TRIGGER TrDelGrades
--ON Grades
--FOR DELETE
--AS
--BEGIN
--	DECLARE @j INT, @g NVARCHAR(20), @i INT  -------For Grades
--	SELECT @g = grade, @i = gradeid FROM deleted

--	UPDATE Gradeshistories
--	SET gradeid = gradeid - @i
--	WHERE gradeid = @j
--	END
--GO

--SELECT * FROM Grades
--SELECT * FROM Gradeshistories
--DELETE Grades WHERE gradeid = 1
--GO
