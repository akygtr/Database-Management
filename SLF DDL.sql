CREATE DATABASE SLF;

DROP TABLE SLF.dbo.PRODUCT;
DROP TABLE SLF.dbo.CUSTOMER;
DROP TABLE SLF.dbo.SUPPLIER;
DROP TABLE SLF.dbo.EMPLOYEE;
DROP TABLE SLF.dbo.CUSTORDERDETAIL;
DROP TABLE SLF.dbo.CUSTORDERHEADER;
DROP TABLE SLF.dbo.SUPPLIERORDERDETAIL;
DROP TABLE SLF.dbo.SUPPLIERORDERHEADER;


CREATE TABLE SLF.dbo.CUSTOMER ( 
	CustomerID 			INT	PRIMARY KEY, 
	CustomerFirstName	VARCHAR(100) NOT NULL, 
	CustomerLastName	VARCHAR(100) NOT NULL, 
	CustomerAddress		VARCHAR(200) NOT NULL, 
	CustomerCity		VARCHAR(50) NOT NULL,
	CustomerState		VARCHAR(2) NOT NULL,
	CustomerZIP			NUMERIC(5) NOT NULL,
	CustomerEmail		VARCHAR(100) NOT NULL) ;

CREATE TABLE SLF.dbo.SUPPLIER ( 
	SupplierID			INT	PRIMARY KEY, 
	SupplierName		VARCHAR(200) NOT NULL, 
	SupplierAddress		VARCHAR(300), 
	SupplierCity		VARCHAR(50) NOT NULL,
	SupplierState		VARCHAR(2) NOT NULL,
	SupplierRegion		VARCHAR(100) NOT NULL,
	SupplierZIP			NUMERIC(5) NOT NULL,
	SupplierEmail		VARCHAR(100) NOT NULL) ;

CREATE TABLE SLF.dbo.PRODUCT ( 
	ProductID			INT PRIMARY KEY, 
	ProductName			VARCHAR(200) NOT NULL, 
	SupplierID			INT NOT NULL,	 
	UnitCostPrice		DECIMAL (5, 2) NOT NULL, 
	UnitSellingPrice	DECIMAL (5, 2) NOT NULL, 
	ProductUnit			VARCHAR(20), 
	AvailableQty		INT DEFAULT (0), 
	ReOrderQty			INT DEFAULT (0), 
	ReOrderStatus		VARCHAR(1) DEFAULT 'N',
	CONSTRAINT CHK_ReOrderStatus
		CHECK (ReOrderStatus IN ('Y', 'N')), 
	FOREIGN KEY (SupplierID) REFERENCES SUPPLIER (SupplierID) ON DELETE CASCADE) ;

CREATE TABLE SLF.dbo.EMPLOYEE ( 
	EmployeeID			INT PRIMARY KEY,  
	EmployeeFirstName	VARCHAR(100) NOT NULL,  
	EmployeeLastName	VARCHAR(100) NOT NULL,  
	Department			VARCHAR(50) NOT NULL,  
	Role				VARCHAR(50),  
	Salary				DECIMAL (10, 2) NOT NULL,  
	SupervisorID		INT, 
	FOREIGN KEY (SupervisorID) REFERENCES EMPLOYEE (EmployeeID) ON DELETE NO ACTION) ;

CREATE TABLE SLF.dbo.CUSTORDERHEADER  ( 
	CustOrderID 		INT PRIMARY KEY,  
	CustomerID			INT, 
	OrderDate			DATE NOT NULL,  
	ShipDate			DATE NOT NULL,
	PaymentDue			DECIMAL (7, 2) DEFAULT 0, 
	FOREIGN KEY (CustomerID) REFERENCES CUSTOMER (CustomerID) ON DELETE CASCADE) ;

CREATE TABLE SLF.dbo.CUSTORDERDETAIL ( 
	CustOrderID 		INT,  
	ProductID			INT,  
	OrderQty			INT NOT NULL, 
	PRIMARY KEY (CustOrderID, ProductID), 
	FOREIGN KEY (CustOrderID) REFERENCES CUSTORDERHEADER  (CustOrderID) ON DELETE CASCADE, 
	FOREIGN KEY (ProductID) REFERENCES PRODUCT (ProductID) ON DELETE CASCADE);

CREATE TABLE SLF.dbo.SUPPLIERORDERHEADER ( 
	SupplierOrderID		INT PRIMARY KEY,  
	SupplierID			INT,  
	PurchaseOfficerID	INT,  
	OrderDate			DATE NOT NULL,  
	ReceiptDate			DATE,  
	OrderStatus			VARCHAR(10) DEFAULT 'Pending',
	PaymentAmount		DECIMAL (7, 2) DEFAULT 0, 
	CONSTRAINT CHK_OrderStatus
		CHECK (OrderStatus IN ('Pending', 'Complete') ),  
	FOREIGN KEY (SupplierID) REFERENCES SUPPLIER (SupplierID) ON DELETE CASCADE, 
	FOREIGN KEY (PurchaseOfficerID) REFERENCES EMPLOYEE (EmployeeID) ON DELETE CASCADE) ;

CREATE TABLE SLF.dbo.SUPPLIERORDERDETAIL ( 
	SupplierOrderID		INT,  
	ProductID			INT,  
	OrderQty			INT NOT NULL, 
	PRIMARY KEY (SupplierOrderID, ProductID), 
	FOREIGN KEY (SupplierOrderID) REFERENCES SUPPLIERORDERHEADER (SupplierOrderID) ON DELETE NO ACTION, 
	FOREIGN KEY (ProductID) REFERENCES PRODUCT (ProductID) ON DELETE NO ACTION);


-- Database Validation 
-- 10 Suppliers
select count( distinct SupplierID) as SupplierCount
from SLF.dbo.SUPPLIER s

-- new supplier field region 2 suppliers per region
select count(distinct SupplierID) as SupplierCount, SupplierRegion
from SLF.dbo.SUPPLIER s
group by SupplierRegion

-- 20 Employees . 
select count(EmployeeID) as EmployeeCount
from SLF.dbo.EMPLOYEE

-- Employees with roles of managing director, accountant, hr specialist, purchasing officer and order fulfillment officier.
select count(EmployeeID) as EmployeeCount, Role
from SLF.dbo.EMPLOYEE
group by Role

-- managing director does not have a supervisor assigned but all other employees do
select count(SupervisorID) as SupervisorCount, Role
from SLF.dbo.EMPLOYEE
group by Role

-- 50 products
select count(ProductID) as ProductCount
from SLF.dbo.PRODUCT

-- make sure the product cost price is between 10-20 and the unit price is between 20 and 25.
select min(UnitCostPrice) as MinProductPrice
	, max(UnitCostPrice) as MaxProductPrice
	, min(UnitSellingPrice) as MinSellingPrice
	, max(UnitSellingPrice) as MaxSellingPrice
from SLF.dbo.Product


-- Products have only one supplier.
select max(SupplierCount) as MaxSupplierCount
FROM (
	select count(SupplierID) as SupplierCount
	, ProductName 
	from SLF.dbo.PRODUCT
	group by ProductName) subquery 

-- 250 customers
select count(CustomerID)
from SLF.dbo.CUSTOMER 
	
-- all customers in USA
select count(CustomerID) as CustomerCount, CustomerState
from SLF.dbo.CUSTOMER 
group by CustomerState

-- 500 Customer orders and Customer Orders with a date range on order recieved before shipping date
-- NOTE: We don't have a paid date because it's implied that the order date is payment date. 
select count(CustOrderID) as OrderCount,
max(OrderDate) as MaxOrderDate,
min(ShipDate) as MinShipDate
from SLF.dbo.CUSTORDERHEADER c 

-- 500 supplier orders with a date range on order recieved before ship date 
select count(SupplierOrderID) as OrderCount, 
max(OrderDate) as MaxOrderDate,
min(ReceiptDate) as MinShipDate
from SLF.dbo.SUPPLIERORDERHEADER c 
