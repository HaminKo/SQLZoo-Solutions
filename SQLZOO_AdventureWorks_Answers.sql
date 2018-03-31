/*
SQLZOO Guest House Answers
Questions available at http://sqlzoo.net/wiki/AdventureWorks
*/


-- #1
/*
Show the first name and the email address of customer with CompanyName 'Bike World'
*/
SELECT
  FirstName,
  EmailAddress
FROM
  Customer
WHERE
  CompanyName = 'Bike World';

-- #2
/*
Show the CompanyName for all customers with an address in City 'Dallas'.
*/
SELECT
  CompanyName
FROM
  Customer
  JOIN
    CustomerAddress
    ON Customer.CustomerID = CustomerAddress.CustomerID
  JOIN
    Address
    ON CustomerAddress.AddressID = Address.AddressID
WHERE
  Address.City = 'Dallas';

-- #3
/*
How many items with ListPrice more than $1000 have been sold?
*/
SELECT
  COUNT(*) AS Total
FROM
  SalesOrderDetail
  JOIN
    Product
    ON SalesOrderDetail.ProductID = Product.ProductID
WHERE
  Product.ListPrice > 1000;

-- #4
/*
Give the CompanyName of those customers with orders over $100000. Include the subtotal plus tax plus freight.
*/
SELECT
  Customer.CompanyName
FROM
  SalesOrderHeader
  JOIN
    Customer
    ON SalesOrderHeader.CustomerID = Customer.CustomerID
WHERE
  SalesOrderHeader.SubTotal + SalesOrderHeader.TaxAmt + SalesOrderHeader.Freight > 100000;

-- #5
/*
Find the number of left racing socks ('Racing Socks, L') ordered by CompanyName 'Riding Cycles'
*/
SELECT
  SUM(SalesOrderDetail.OrderQty) As Total
FROM
  SalesOrderDetail
  JOIN
    Product
    ON SalesOrderDetail.ProductID = Product.ProductID
  JOIN
    SalesOrderHeader
    ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
  JOIN
    Customer
    ON SalesOrderHeader.CustomerID = Customer.CustomerID
WHERE
  Product.Name = 'Racing Socks, L'
  AND Customer.CompanyName = 'Riding Cycles';

-- #6
/*
A "Single Item Order" is a customer order where only one item is ordered. Show the SalesOrderID and the UnitPrice for every Single Item Order.
*/
SELECT
  SalesOrderID,
  UnitPrice
FROM
  SalesOrderDetail
WHERE
  OrderQty = 1;

-- #7
/*
Where did the racing socks go? List the product name and the CompanyName for all Customers who ordered ProductModel 'Racing Socks'.
*/
SELECT
  Product.name, Customer.CompanyName
FROM
  ProductModel
  JOIN
    Product
    ON ProductModel.ProductModelID = Product.ProductModelID
  JOIN
    SalesOrderDetail
    ON SalesOrderDetail.ProductID = Product.ProductID
  JOIN
    SalesOrderHeader
    ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID
  JOIN
    Customer
    ON SalesOrderHeader.CustomerID = Customer.CustomerID
WHERE
  ProductModel.Name = 'Racing Socks';

-- #8
/*
Show the product description for culture 'fr' for product with ProductID 736.
*/
SELECT
  ProductDescription.Description
FROM
  ProductDescription
  JOIN
     ProductModelProductDescription
     ON ProductDescription.ProductDescriptionID = ProductModelProductDescription.ProductDescriptionID
  JOIN
    ProductModel
    ON ProductModelProductDescription.ProductModelID = ProductModel.ProductModelID
  JOIN
    Product
    ON ProductModel.ProductModelID = Product.ProductModelID
WHERE
  ProductModelProductDescription.culture = 'fr'
  AND Product.ProductID = '736';

-- #9
/*
Use the SubTotal value in SaleOrderHeader to list orders from the largest to the smallest. For each order show the CompanyName and the SubTotal and the total weight of the order.
*/
SELECT
  Customer.CompanyName,
  SalesOrderHeader.SubTotal,
  SUM(SalesOrderDetail.OrderQty * Product.weight)
FROM
  Product
  JOIN
    SalesOrderDetail
    ON Product.ProductID = SalesOrderDetail.ProductID
  JOIN
    SalesOrderHeader
    ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesorderID
  JOIN
    Customer
    ON SalesOrderHeader.CustomerID = Customer.CustomerID
GROUP BY
  SalesOrderHeader.SalesOrderID, SalesOrderHeader.SubTotal, Customer.CompanyName
ORDER BY
  SalesOrderHeader.SubTotal DESC;

-- #10
/*
How many products in ProductCategory 'Cranksets' have been sold to an address in 'London'?
*/
SELECT
  SUM(SalesOrderDetail.OrderQty)
FROM
  ProductCategory
  JOIN
    Product
    ON ProductCategory.ProductCategoryID = Product.ProductCategoryID
  JOIN
    SalesOrderDetail
    ON Product.ProductID = SalesOrderDetail.ProductID
  JOIN
    SalesOrderHeader
    ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesorderID
  JOIN
    Address
    ON SalesOrderHeader.ShipToAddressID = Address.AddressID
WHERE
  Address.City = 'London'
  AND ProductCategory.Name = 'Cranksets';

-- #11
/*
For every customer with a 'Main Office' in Dallas show AddressLine1 of the 'Main Office' and AddressLine1 of the 'Shipping' address - if there is no shipping address leave it blank. Use one row per customer.
*/
SELECT
  Customer.CompanyName,
  MAX(CASE WHEN AddressType = 'Main Office' THEN AddressLine1 ELSE '' END) AS 'Main Office Address',
  MAX(CASE WHEN AddressType = 'Shipping' THEN AddressLine1 ELSE '' END) AS 'Shipping Address'
FROM
  Customer
  JOIN
    CustomerAddress
    ON Customer.CustomerID = CustomerAddress.CustomerID
  JOIN
    Address
    ON CustomerAddress.AddressID = Address.AddressID
WHERE
  Address.City = 'Dallas'
GROUP BY
  Customer.CompanyName;

-- #12
/*
For each order show the SalesOrderID and SubTotal calculated three ways:
A) From the SalesOrderHeader
B) Sum of OrderQty*UnitPrice
C) Sum of OrderQty*ListPrice
*/
SELECT
  SalesOrderHeader.SalesOrderID,
  SalesOrderHeader.SubTotal,
  SUM(SalesOrderDetail.OrderQty * SalesOrderDetail.UnitPrice),
  SUM(SalesOrderDetail.OrderQty * Product.ListPrice)
FROM
  SalesOrderHeader
  JOIN
    SalesOrderDetail
    ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
  JOIN
    Product
    ON SalesOrderDetail.ProductID = Product.ProductID
GROUP BY
  SalesOrderHeader.SalesOrderID,
  SalesOrderHeader.SubTotal;

-- @13
/*
Show the best selling item by value.
*/
SELECT
  Product.Name,
  SUM(SalesOrderDetail.OrderQty * SalesOrderDetail.UnitPrice) AS Total_Sale_Value
FROM
  Product
  JOIN
    SalesOrderDetail
    ON Product.ProductID = SalesOrderDetail.ProductID
GROUP BY
  Product.Name
ORDER BY
  Total_Sale_Value DESC;

-- #14
/*
Show how many orders are in the following ranges (in $):

    RANGE      Num Orders      Total Value
    0-  99
  100- 999
 1000-9999
10000-
*/
SELECT
  t.range AS 'RANGE',
  COUNT(t.Total) AS 'Num Orders',
  SUM(t.Total) AS 'Total Value'
FROM
  (
    SELECT
    CASE
      WHEN
        SalesOrderDetail.UnitPrice * SalesOrderDetail.OrderQty BETWEEN 0 AND 99
      THEN
        '0-99'
      WHEN
        SalesOrderDetail.UnitPrice * SalesOrderDetail.OrderQty BETWEEN 100 AND 999
      THEN
        '100-999'
      WHEN
        SalesOrderDetail.UnitPrice * SalesOrderDetail.OrderQty BETWEEN 1000 AND 9999
      THEN
        '1000-9999'
      WHEN
        SalesOrderDetail.UnitPrice * SalesOrderDetail.OrderQty > 10000
      THEN
        '10000-'
      ELSE
        'Error'
    END AS 'Range',
    SalesOrderDetail.UnitPrice * SalesOrderDetail.OrderQty AS Total
  FROM
    SalesOrderDetail
  ) t
GROUP BY
  t.range;

-- #15
/*
Identify the three most important cities. Show the break down of top level product category against city.
*/
SELECT
  Address.City,
  ProductCategory.Name AS Product_Category_Name,
  SUM(SalesOrderDetail.OrderQty * SalesOrderDetail.UnitPrice) AS Total_Sales
FROM
  Address
  JOIN
    SalesOrderHeader
    ON Address.AddressID = SalesOrderHeader.ShipToAddressID
  JOIN
    SalesOrderDetail
    ON SalesOrderHeader.SalesOrderID = SalesOrderDetail.SalesOrderID
  JOIN
    Product
    ON SalesOrderDetail.ProductID = Product.ProductID
  JOIN
    ProductCategory
    ON Product.ProductCategoryID = ProductCategory.ProductCategoryID
WHERE
  Address.City IN
  (
    SELECT
      t.City
    FROM
      (
      SELECT
        t.*,
        @counter := @counter + 1 AS counter
      FROM
        (
          SELECT
            @counter := 0
        )
        AS initvar,
        (
        SELECT
          Address.City,
          SUM(SalesOrderHeader.SubTotal) AS City_Total
        FROM
          Address
          JOIN
            SalesOrderHeader
            ON Address.AddressID = SalesOrderHeader.ShipToAddressID
        GROUP BY
          Address.City
        ORDER BY
          City_Total DESC
        ) AS t
      ) AS t
    WHERE t.counter <= 3
  )
GROUP BY
  Address.City,
  ProductCategory.Name;
