SLF Database DesignThis repository contains the database design for the SLF (Shipping & Logistics Fulfillment) system, including the Entity-Relationship Diagram (ERD), Logical Design, and Physical Design (SQL DDL statements). The design is built to manage customer orders, supplier orders, product inventory, and employee information for a small business.Table of ContentsOverviewAssumptionsDatabase SchemaEntity-Relationship Diagram (ERD)Physical Design (SQL DDL)OverviewThe database is designed to support core business operations, including:Customer Management: Storing customer details and their billing/delivery addresses.Product and Supplier Management: Tracking product information, including inventory levels and associated suppliers.Employee Management: Managing employee data, including their roles and reporting structure.Order Processing: Handling both customer and supplier orders, tracking their status, and updating inventory.AssumptionsThe design is based on the following key business rules and assumptions:All employees, except for the Managing Director, are supervised by another employee.Each product is associated with one and only one supplier.Product reordering is triggered when the AvailableQty falls below the ReOrderQty.A message is sent to the Purchasing Officer, who can then create a supplier order.Supplier orders start in a 'Pending' state and are updated to 'Complete' upon receipt.Upon completion of a supplier order, the AvailableQty for the ordered products is automatically updated, and the reorder status is reset.Database SchemaLogical DesignThis section provides a simplified view of the tables and their primary and foreign keys.CUSTOMER (CustomerID, CustomerFirstName, CustomerLastName, CustomerAddress, CustomerEmail, BillingAddress)PRODUCT (ProductID, ProductName, SupplierID, UnitCostPrice, UnitSellingPrice, ProductUnit, AvailableQty, ReOrderQty, ReOrderStatus)SUPPLIER (SupplierID, SupplierName, SupplierAddress, SupplierEmail)EMPLOYEE (EmployeeID, EmployeeFirstName, EmployeeLastName, Department, Role, Salary, SupervisorID)CUSTORDERHEADER (CustOrderID, CustomerID, OrderDate, ShipDate, DeliveryAddress, PaymentDue)CUSTORDERDETAIL (CustOrderID, ProductID, Order_Qty)SUPPLIERORDERHEADER (SupplierOrderID, SupplierID, PurchaseOfficerID, Order_Date, Receipt_Date, Order_Status, Payment_Amount)SUPPLIERORDERDETAIL (SupplierOrderID, ProductID, Order_Qty)Physical Design (SQL DDL)The following SQL Data Definition Language (DDL) statements can be used to create the tables in a database.CUSTOMER TableCREATE TABLE CUSTOMER (
    CustomerID INT PRIMARY KEY,
    CustomerFirstName VARCHAR(100) NOT NULL,
    CustomerLastName VARCHAR(100) NOT NULL,
    CustomerAddress VARCHAR(200) NOT NULL,
    CustomerEmail VARCHAR(100) NOT NULL,
    CustomerBillingAddress VARCHAR(200)
);
SUPPLIER TableCREATE TABLE SUPPLIER (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(200) NOT NULL,
    SupplierAddress VARCHAR(300),
    SupplierEmail VARCHAR(100) NOT NULL
);
PRODUCT TableCREATE TABLE PRODUCT (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(200) NOT NULL,
    SupplierID INT NOT NULL,
    UnitCostPrice DECIMAL (5, 2) NOT NULL,
    UnitSellingPrice DECIMAL (5, 2) NOT NULL,
    ProductUnit VARCHAR(20),
    AvailableQty INT DEFAULT 0,
    ReOrderQty INT DEFAULT 0,
    ReOrderStatus VARCHAR(1) DEFAULT 'N' CHECK (ReOrderStatus IN ('Y', 'N')),
    FOREIGN KEY (SupplierID) REFERENCES SUPPLIER (SupplierID) ON DELETE CASCADE
);
EMPLOYEE TableCREATE TABLE EMPLOYEE (
    EmployeeID INT PRIMARY KEY,
    EmployeeFirstName VARCHAR(100) NOT NULL,
    EmployeeLastName VARCHAR(100) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Salary DECIMAL (10, 2) NOT NULL,
    SupervisorID INT,
    FOREIGN KEY (SupervisorID) REFERENCES EMPLOYEE (EmployeeID) ON DELETE CASCADE
);
CUSTORDERHEADER TableCREATE TABLE CUSTORDERHEADER (
    CustOrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE NOT NULL,
    ShipDate DATE NOT NULL,
    DeliveryAddress VARCHAR(200) NOT NULL,
    PaymentDue DECIMAL (7, 2) DEFAULT 0,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER (CustomerID) ON DELETE CASCADE
);
CUSTORDERDETAIL TableCREATE TABLE CUSTORDERDETAIL (
    CustOrderID INT,
    ProductID INT,
    Order_Qty INT NOT NULL,
    PRIMARY KEY (CustOrderID, ProductID),
    FOREIGN KEY (CustOrderID) REFERENCES CUSTORDERHEADER (CustOrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES PRODUCT (ProductID) ON DELETE CASCADE
);
SUPPLIERORDERHEADER TableCREATE TABLE SUPPLIERORDERHEADER (
    SupplierOrderID INT PRIMARY KEY,
    SupplierID INT,
    PurchaseOfficerID INT,
    Order_Date DATE NOT NULL,
    Receipt_Date DATE,
    Order_Status VARCHAR(10) DEFAULT 'Pending' CHECK (Order_Status IN ('Pending', 'Complete')),
    Payment_Amount DECIMAL (7, 2) DEFAULT 0,
    FOREIGN KEY (SupplierID) REFERENCES SUPPLIER (SupplierID) ON DELETE CASCADE,
    FOREIGN KEY (PurchaseOfficerID) REFERENCES EMPLOYEE (EmployeeID) ON DELETE CASCADE
);
SUPPLIERORDERDETAIL TableCREATE TABLE SUPPLIERORDERDETAIL (
    SupplierOrderID INT,
    ProductID INT,
    Order_Qty INT NOT NULL,
    PRIMARY KEY (SupplierOrderID, ProductID),
    FOREIGN KEY (SupplierOrderID) REFERENCES SUPPLIERORDERHEADER (SupplierOrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES PRODUCT (ProductID) ON DELETE CASCADE
);

