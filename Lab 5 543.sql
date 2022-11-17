/*
M5 13 No Scaffolding Lab 5
 
Server: IS-HAY09.ischool.uw.edu
Database: SampleSuperStore
 
*/
 
-- Q1) Write the SQL to determine which customers meet all of the following conditions:
-- condition a) Purchased fewer than 3 units of products that are product type 'Electronics' before 2013
-- condition b) Spent less than $30 on Kitchen products between 1999 and 2008
 
SELECT Fname, Lname
FROM tblCUSTOMER
WHERE CustomerID IN (
   SELECT tblCUSTOMER.CustomerID
   FROM tblCUSTOMER
       JOIN tblORDER ON tblCUSTOMER.CustomerID = tblORDER.CustomerID
       JOIN tblORDER_PRODUCT ON tblORDER.OrderID = tblORDER_PRODUCT.OrderID
       JOIN tblPRODUCT ON tblORDER_PRODUCT.ProductID = tblPRODUCT.ProductID
       JOIN tblPRODUCT_TYPE ON tblPRODUCT.ProdTypeID = tblPRODUCT_TYPE.ProdTypeID
   WHERE ProdTypeName = 'Electronics' AND YEAR(OrderDate) < '2013'
   GROUP BY tblCUSTOMER.CustomerID
   HAVING SUM(Quantity) < 3
   )
AND CustomerID IN (
   SELECT tblCUSTOMER.CustomerID
   FROM tblCUSTOMER
       JOIN tblORDER ON tblCUSTOMER.CustomerID = tblORDER.CustomerID
       JOIN tblORDER_PRODUCT ON tblORDER.OrderID = tblORDER_PRODUCT.OrderID
       JOIN tblPRODUCT ON tblORDER_PRODUCT.ProductID = tblPRODUCT.ProductID
       JOIN tblPRODUCT_TYPE ON tblPRODUCT.ProdTypeID = tblPRODUCT_TYPE.ProdTypeID
   WHERE ProdTypeName = 'Kitchen' AND YEAR(OrderDate) BETWEEN '1999' AND '2008'
   GROUP BY tblCUSTOMER.CustomerID
   HAVING SUM(Calc_LineTotal) < 30
   )
 
-- Q2) Write the SQL query to determine the top 6 states for total dollars spend on products of type 'garden' for people younger than 33 years old at the time of purchase
 
SELECT TOP 6 CustState, SUM(Calc_OrderTotal) AS Total_Amount
FROM tblCUSTOMER
   JOIN tblORDER ON tblCUSTOMER.CustomerID = tblORDER.CustomerID
   JOIN tblORDER_PRODUCT ON tblORDER.OrderID = tblORDER_PRODUCT.OrderID
   JOIN tblPRODUCT ON tblORDER_PRODUCT.ProductID = tblPRODUCT.ProductID
   JOIN tblPRODUCT_TYPE ON tblPRODUCT.ProdTypeID = tblPRODUCT_TYPE.ProdTypeID
WHERE ProdTypeName = 'Garden' AND DATEDIFF(YY, BirthDate, OrderDate) BETWEEN '0' AND '32'
GROUP BY CustState
ORDER BY SUM(Calc_LineTotal) DESC
GO
 
-- Q3) Write the SQL to label and count the number of customers that meet the following conditions:
--      a) Purchased fewer than 20 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Blue'
--      b) Purchased between 20 and 30 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Green'
--      c) Purchased between 31 and 45 units of 'automotive' products lifetime AND spent less than $800 lifetime of product type 'kitchen', label them 'Orange'
--      d) Purchased between 46 and 60 units of 'automotive' products lifetime AND spent BETWEEN $801 and $3000 lifetime of product type 'kitchen', label them 'Purple'
--      e) Else 'Unknown'
-- HINT: this is best written with a CASE statement drawing from 2 subqueries(!!) that each have an aggregated alias like 'AutoUnits' and 'TotalBucksKitchen'
 
SELECT (CASE
   WHEN (AutoUnits < '20') AND (TotalBucksKitchen < '800')
       THEN 'Blue'
   WHEN (AutoUnits BETWEEN '20' AND '30') AND (TotalBucksKitchen < '800')
       THEN 'Green'
   WHEN (AutoUnits BETWEEN '31' AND '45') AND (TotalBucksKitchen < '800')
       THEN 'Orange'
   WHEN (AutoUnits BETWEEN '46' AND '60') AND (TotalBucksKitchen BETWEEN '801' AND '3000')
       THEN 'Purple'
   ELSE 'Unknown'
   END) AS LabelOfCustomer, COUNT(*) AS NumberOfCustomers
FROM (
   (SELECT tblCUSTOMER.CustomerID, SUM(Quantity) AS AutoUnits
   FROM tblCUSTOMER
       JOIN tblORDER ON tblCUSTOMER.CustomerID = tblORDER.CustomerID
       JOIN tblORDER_PRODUCT ON tblORDER.OrderID = tblORDER_PRODUCT.OrderID
       JOIN tblPRODUCT ON tblORDER_PRODUCT.ProductID = tblPRODUCT.ProductID
       JOIN tblPRODUCT_TYPE ON tblPRODUCT.ProdTypeID = tblPRODUCT_TYPE.ProdTypeID
   WHERE ProdTypeName = 'Automotive'
   GROUP BY tblCUSTOMER.CustomerID) AS A
   JOIN
   (SELECT tblCUSTOMER.CustomerID, SUM(Calc_LineTotal) AS TotalBucksKitchen
   FROM tblCUSTOMER
       JOIN tblORDER ON tblCUSTOMER.CustomerID = tblORDER.CustomerID
       JOIN tblORDER_PRODUCT ON tblORDER.OrderID = tblORDER_PRODUCT.OrderID
       JOIN tblPRODUCT ON tblORDER_PRODUCT.ProductID = tblPRODUCT.ProductID
       JOIN tblPRODUCT_TYPE ON tblPRODUCT.ProdTypeID = tblPRODUCT_TYPE.ProdTypeID
   WHERE ProdTypeName = 'Kitchen'
   GROUP BY tblCUSTOMER.CustomerID) AS B
   ON A.CustomerID = B.CustomerID)
 
GROUP BY (CASE
   WHEN (AutoUnits < '20') AND (TotalBucksKitchen < '800')
       THEN 'Blue'
   WHEN (AutoUnits BETWEEN '20' AND '30') AND (TotalBucksKitchen < '800')
       THEN 'Green'
   WHEN (AutoUnits BETWEEN '31' AND '45') AND (TotalBucksKitchen < '800')
       THEN 'Orange'
   WHEN (AutoUnits BETWEEN '46' AND '60') AND (TotalBucksKitchen BETWEEN '801' AND '3000')
       THEN 'Purple'
   ELSE 'Unknown'
   END)
  
-- Q4) Write the SQL to create a stored procedure to INSERT a new row into tblPRODUCT under the following conditions:
-- a) pass in parameters of @ProdName, @ProdTypeName, and @Price
-- b) DECLARE a variable to look-up the associated ProdTypeID for @ProdTypeName parameter (no error-handling required)
-- c) make the INSERT statement inside an explicit transaction
 
CREATE PROCEDURE INSERT_PRODUCT_ROW
@ProdName VARCHAR(100),
@ProdTypeName VARCHAR(50),
@Price NUMERIC(8,2)
 
AS
DECLARE @ProdTypeID INT
 
SET @ProdTypeID = (SELECT ProdTypeID
   FROM tblPRODUCT_TYPE
   WHERE ProdTypeName = @ProdTypeName
   )
 
BEGIN TRANSACTION T1
   INSERT INTO tblPRODUCT(ProductName, ProdTypeID, Price)
   VALUES (@ProdName, @ProdTypeID, @Price)
COMMIT TRANSACTION T1
GO
 
-- Q5) Write the SQL to create a stored procedure to UPDATE the price of a single product in SampleSuperStore database with the following conditions:
-- a) be sure to affect only a single row (hint: populate a variable and set that to the PK of tblPRODUCT)
-- b) make the UPDATE statement inside an explicit transaction
-- c) pass in parameters of @ProdName and @NewPrice
 
CREATE PROCEDURE UPDATE_PRODUCT_PRICE
@ProdName VARCHAR(100),
@NewPrice NUMERIC(8,2)
 
AS
DECLARE @ProductID INT
 
SET @ProductID = (SELECT ProductID
   FROM tblPRODUCT
   WHERE ProductName = @ProdName
   )
 
IF @ProductID IS NULL
   BEGIN
       PRINT 'ProductID has come back NULL; check spelling of all parameters';
       THROW 50001,'ProductID cannot be NULL; process is terminating', 1;
   END
 
BEGIN TRANSACTION T2
   UPDATE tblPRODUCT
   SET Price = @NewPrice
   WHERE ProductID = @ProductID
COMMIT TRANSACTION T2
GO
