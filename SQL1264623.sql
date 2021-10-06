CREATE DATABASE db1264623
GO

USE db1264623
GO

CREATE TABLE Restaurant_Dishes
(
	id INT PRIMARY KEY,
	Dishesname NVARCHAR (30) NOT NULL,
	unitprice MONEY NOT NULL,
	orderquantity INT NOT NULL,
	orderdate DATE NOT NULL,
	deliverydate DATE NULL
)
GO
------------------Insert values------------------
DECLARE @i INT =1
WHILE @i <=10
BEGIN 
	INSERT INTO Restaurant_Dishes VALUES
	(@i, 'Dishesname' + CAST(@i as VARCHAR), CEILING (RAND()*100),RAND()*@i, DATEADD(d, @i, '2021-06-01'), null)
	SET @i += 1
END
GO

SELECT * FROM Restaurant_Dishes
GO

----------- 1 Create view--------------
CREATE VIEW ordersCurrentMonth
WITH ENCRYPTION
AS
	SELECT id, Dishesname, unitprice, orderdate, orderquantity, unitprice*orderquantity as 'Amount'
	FROM Restaurant_Dishes
	WHERE YEAR(orderdate) = YEAR(GETDATE()) AND MONTH(orderdate) = MONTH(GETDATE())
GO

SELECT * FROM ordersCurrentMonth
GO

-------------------Create Stored Procedure Insert update delete-------------------------
---------------insert---------------------

CREATE PROC spCreateOrder @Dish NVARCHAR(30), @pr MONEY,  @OQ INT = 1, @Od DATE ,@Delidate DATE =NULL, @id INT OUTPUT
AS
IF @Delidate IS NOT NULL
BEGIN
	IF @Delidate < @od
	BEGIN
		RAISERROR ('Invalid delivery date', 11, 1)
		RETURN
	END
END
DECLARE @i INT
SELECT @i = ISNULL(MAX(id), 0)+1 FROM Restaurant_Dishes
INSERT INTO Restaurant_Dishes VALUES(@i, @Dish, @pr, @OQ, @od, @Delidate)
SET @id = @i
GO

DECLARE @newid INT
EXEC spCreateOrder @Dish = 'Biryani', @pr = 250.00, @od='2021-06-22', @id=@newid OUTPUT
SELECT @newid
GO

DECLARE @newid INT
EXEC spCreateOrder @Dish = 'Biryani', @pr = 250.00, @od='2021-06-24',@Delidate ='2021-06-25' ,@id=@newid OUTPUT
SELECT @newid
GO

SELECT * FROM Restaurant_Dishes
GO

---------------Create A update Procedure------------------

CREATE PROC spUpdateeOrder @ID INT, @Dish NVARCHAR(30) = NULL, @pr MONEY = NULL,  @OQ INT  = NULL, @Od DATE = NULL ,@Delidate DATE = NULL
AS
IF @Delidate > @od
BEGIN
	RAISERROR ('Invalid delivery date', 11, 1)
	RETURN
END
UPDATE Restaurant_Dishes
SET Dishesname =ISNULL(@Dish,Dishesname),
	unitprice = ISNULL(@pr,unitprice),
	orderquantity = ISNULL(@OQ,orderquantity),
	orderdate = ISNULL(@od, orderdate),
	deliverydate = ISNULL(@Delidate, deliverydate)
WHERE id = @ID
GO


EXEC spUpdateeOrder @ID =1, @Delidate = '2021-06-4'
GO

SELECT * FROM Restaurant_Dishes
GO

---------------Create A Delete Procedure------------------

CREATE PROC spDelOrder @id INT
AS
DELETE FROM Restaurant_Dishes 
WHERE id = @id
GO

DELETE FROM Restaurant_Dishes WHERE id = 12
GO

SELECT * FROM Restaurant_Dishes
GO

---------------Create trigger inserted------------------------
CREATE TRIGGER trOrderInsert
ON Restaurant_Dishes
AFTER INSERT
AS
BEGIN
	DECLARE @od DATE, @dd DATE
	
	SELECT @od =orderdate, @dd=deliverydate FROM inserted
	
	IF DATEDIFF(day, @od, @dd) < 3
	BEGIN
		ROLLBACK TRAN
		;
		THROW 50001, 'Invalid delivary date, action cancelled', 1
	END
END
GO

SELECT * FROM Restaurant_Dishes
GO

INSERT INTO Restaurant_Dishes VALUES ( 17, 'Dish_name1', 90, 1, '2021-06-15', '2021-06-17')
GO

CREATE TRIGGER trDelOrder
ON Restaurant_Dishes
FOR DELETE
AS
BEGIN
	DECLARE @dd DATE
	SELECT @dd = deliverydate FROM deleted
	IF @dd IS NOT NULL
	BEGIN
		ROLLBACK TRANSACTION
		RAISERROR( 'Already delivered order, action cancelled.', 11, 1)
	END
END
GO

SELECT * FROM Restaurant_Dishes
EXEC spDelOrder 1
SELECT * FROM Restaurant_Dishes
EXEC spDelOrder 2
SELECT * FROM Restaurant_Dishes
GO

--------------Create scaler functions--------------------
CREATE FUNCTION fnOrderQuantity(@startdate DATE, @enddate DATE) RETURNS MONEY
AS
BEGIN
	DECLARE @amt MONEY
	SELECT @amt=SUM(unitprice*orderquantity)
	FROM Restaurant_Dishes
	WHERE orderdate BETWEEN @startdate AND @enddate
	RETURN @amt
END
GO

SELECT dbo.fnOrderQuantity('2021-06-01', '2021-06-30')
GO

-------------------------table valued funcaations----------------
CREATE FUNCTION fnOrderItemOrders(@startdate DATE, @enddate DATE) RETURNS TABLE
AS
RETURN (
	
	SELECT Dishesname, SUM(unitprice*orderquantity) 'value'
	FROM Restaurant_Dishes
	WHERE orderdate BETWEEN @startdate AND @enddate
	GROUP BY Dishesname
	
)
GO
SELECT * FROM fnOrderItemOrders('2021-06-01', '2021-06-10')
GO

--USE master
--GO
--DROP DATABASE db11264623
--GO