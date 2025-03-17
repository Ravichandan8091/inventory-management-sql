-- Create Database
CREATE DATABASE AdvancedInventoryDB;
USE AdvancedInventoryDB;

-- Categories Table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

-- Suppliers Table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY AUTO_INCREMENT,
    SupplierName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(100)
);

-- Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT,
    SupplierID INT,
    UnitPrice DECIMAL(10, 2) CHECK (UnitPrice > 0),
    UnitsInStock INT CHECK (UnitsInStock >= 0),
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100) NOT NULL,
    ContactEmail VARCHAR(100)
);

-- Sales Table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT,
    CustomerID INT,
    SaleDate DATE NOT NULL,
    QuantitySold INT CHECK (QuantitySold > 0),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Trigger to Auto-Update Stock After Sale
DELIMITER //
CREATE TRIGGER UpdateStockAfterSale
AFTER INSERT ON Sales
FOR EACH ROW
BEGIN
    UPDATE Products
    SET UnitsInStock = UnitsInStock - NEW.QuantitySold
    WHERE ProductID = NEW.ProductID;
END;
//
DELIMITER ;

-- Stored Procedure to Record a Sale
DELIMITER //
CREATE PROCEDURE RecordSale(IN p_ProductID INT, IN p_CustomerID INT, IN p_Quantity INT)
BEGIN
    INSERT INTO Sales (ProductID, CustomerID, SaleDate, QuantitySold)
    VALUES (p_ProductID, p_CustomerID, CURDATE(), p_Quantity);
END;
//
DELIMITER ;

-- Sample Data
INSERT INTO Categories (CategoryName) VALUES ('Electronics'), ('Furniture');
INSERT INTO Suppliers (SupplierName, ContactEmail) VALUES ('TechCorp', 'techcorp@example.com'), ('FurniPro', 'furnipro@example.com');
INSERT INTO Products (ProductName, CategoryID, SupplierID, UnitPrice, UnitsInStock)
VALUES ('Laptop', 1, 1, 60000, 15), ('Table', 2, 2, 5000, 30);
INSERT INTO Customers (CustomerName, ContactEmail) VALUES ('Alice', 'alice@example.com'), ('Bob', 'bob@example.com');

-- Use the Stored Procedure to Record Sales
CALL RecordSale(1, 1, 3);
CALL RecordSale(2, 2, 5);

-- Create View for Sales Summary
CREATE VIEW SalesSummary AS
SELECT s.SaleID, p.ProductName, c.CustomerName, s.SaleDate, s.QuantitySold
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
JOIN Customers c ON s.CustomerID = c.CustomerID;

-- Select from the View
SELECT * FROM SalesSummary;

-- Report: Current Inventory Status
SELECT ProductName, UnitsInStock FROM Products;

-- Report: Total Sales by Product
SELECT p.ProductName, SUM(s.QuantitySold) AS TotalSold
FROM Sales s
JOIN Products p ON s.ProductID = p.ProductID
GROUP BY p.ProductName;
