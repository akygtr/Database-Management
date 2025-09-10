# SLF Database Design
Table of Contents

---

# SLF Database Design
This repository contains the database design for the SLF (Shipping & Logistics Fulfillment) system, including the Entity-Relationship Diagram (ERD), Logical Design, and Physical Design (SQL DDL statements). The design is built to manage customer orders, supplier orders, product inventory, and employee information for a small business.

* **Entity-Relationship Diagram (ERD)**
* **Logical Design (Schema)**
* **Physical Design (SQL DDL statements)**

The design supports operations such as customer management, product inventory tracking, supplier management, employee supervision, and order processing.

---

## Table of Contents

* Overview
* Assumptions
* Database Schema
* Entity-Relationship Diagram (ERD)
* Physical Design (SQL DDL)](#physical-design-sql-ddl
* Getting Started
* Future Enhancements
* Author

---

## Overview

The SLF database is built to manage a small business’s core shipping and logistics workflows, including:

* **Customer Management** → Storing customer details with billing and delivery addresses.
* **Product & Supplier Management** → Tracking product details, costs, pricing, stock levels, and suppliers.
* **Employee Management** → Maintaining employee details, roles, and reporting structures.
* **Order Processing** → Handling customer and supplier orders, updating order status, and managing inventory.

---

## Assumptions & Business Rules

The design is based on the following rules:

1. All employees (except the **Managing Director**) report to a supervisor.
2. Each product has exactly **one supplier**.
3. Reordering is triggered when `AvailableQty < ReOrderQty`.
4. The **Purchasing Officer** creates supplier orders when notified.
5. Supplier orders begin in a `Pending` state and switch to `Complete` upon receipt.
6. When a supplier order is completed:

   * Product `AvailableQty` is updated.
   * The `ReOrderStatus` is reset.

---

## Database Schema

### **Logical Design (Tables & Keys)**

* **CUSTOMER**(`CustomerID`, `CustomerFirstName`, `CustomerLastName`, `CustomerAddress`, `CustomerEmail`, `BillingAddress`)
* **SUPPLIER**(`SupplierID`, `SupplierName`, `SupplierAddress`, `SupplierEmail`)
* **PRODUCT**(`ProductID`, `ProductName`, `SupplierID`, `UnitCostPrice`, `UnitSellingPrice`, `ProductUnit`, `AvailableQty`, `ReOrderQty`, `ReOrderStatus`)
* **EMPLOYEE**(`EmployeeID`, `EmployeeFirstName`, `EmployeeLastName`, `Department`, `Role`, `Salary`, `SupervisorID`)
* **CUSTORDERHEADER**(`CustOrderID`, `CustomerID`, `OrderDate`, `ShipDate`, `DeliveryAddress`, `PaymentDue`)
* **CUSTORDERDETAIL**(`CustOrderID`, `ProductID`, `Order_Qty`)
* **SUPPLIERORDERHEADER**(`SupplierOrderID`, `SupplierID`, `PurchaseOfficerID`, `Order_Date`, `Receipt_Date`, `Order_Status`, `Payment_Amount`)
* **SUPPLIERORDERDETAIL**(`SupplierOrderID`, `ProductID`, `Order_Qty`)

---

## Entity-Relationship Diagram (ERD)

<img width="670" height="482" alt="Screenshot 2025-09-10 171940" src="https://github.com/user-attachments/assets/8b87fdd5-735b-4f10-9230-06131174abb0" />

---

## Physical Design (SQL DDL)

```sql
-- CUSTOMER Table
CREATE TABLE CUSTOMER (
    CustomerID INT PRIMARY KEY,
    CustomerFirstName VARCHAR(100) NOT NULL,
    CustomerLastName VARCHAR(100) NOT NULL,
    CustomerAddress VARCHAR(200) NOT NULL,
    CustomerEmail VARCHAR(100) NOT NULL,
    CustomerBillingAddress VARCHAR(200)
);

-- SUPPLIER Table
CREATE TABLE SUPPLIER (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(200) NOT NULL,
    SupplierAddress VARCHAR(300),
    SupplierEmail VARCHAR(100) NOT NULL
);

-- PRODUCT Table
CREATE TABLE PRODUCT (
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

-- EMPLOYEE Table
CREATE TABLE EMPLOYEE (
    EmployeeID INT PRIMARY KEY,
    EmployeeFirstName VARCHAR(100) NOT NULL,
    EmployeeLastName VARCHAR(100) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Salary DECIMAL (10, 2) NOT NULL,
    SupervisorID INT,
    FOREIGN KEY (SupervisorID) REFERENCES EMPLOYEE (EmployeeID) ON DELETE CASCADE
);

-- CUSTORDERHEADER Table
CREATE TABLE CUSTORDERHEADER (
    CustOrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE NOT NULL,
    ShipDate DATE NOT NULL,
    DeliveryAddress VARCHAR(200) NOT NULL,
    PaymentDue DECIMAL (7, 2) DEFAULT 0,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER (CustomerID) ON DELETE CASCADE
);

-- CUSTORDERDETAIL Table
CREATE TABLE CUSTORDERDETAIL (
    CustOrderID INT,
    ProductID INT,
    Order_Qty INT NOT NULL,
    PRIMARY KEY (CustOrderID, ProductID),
    FOREIGN KEY (CustOrderID) REFERENCES CUSTORDERHEADER (CustOrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES PRODUCT (ProductID) ON DELETE CASCADE
);

-- SUPPLIERORDERHEADER Table
CREATE TABLE SUPPLIERORDERHEADER (
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

-- SUPPLIERORDERDETAIL Table
CREATE TABLE SUPPLIERORDERDETAIL (
    SupplierOrderID INT,
    ProductID INT,
    Order_Qty INT NOT NULL,
    PRIMARY KEY (SupplierOrderID, ProductID),
    FOREIGN KEY (SupplierOrderID) REFERENCES SUPPLIERORDERHEADER (SupplierOrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES PRODUCT (ProductID) ON DELETE CASCADE
);
```

---

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/your-username/SLF-Database-Design.git
   ```
2. Run the SQL script in your preferred database (MySQL, PostgreSQL, SQL Server).
3. Verify the schema using the ERD provided in the `/assets` folder.

---

## Future Enhancements

* Stored procedures for automatic reorder triggers.
* Triggers for updating stock levels after supplier order completion.
* Views for simplified reporting (e.g., low stock, pending orders).

---

## Author

Developed by **Akshara Kumari**

---

Do you also want me to **add sample `INSERT` statements** (seed data for Customers, Products, Suppliers, etc.) so that someone testing your repo can run queries immediately, or keep it schema-only?
