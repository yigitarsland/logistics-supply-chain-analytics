-- 1. Create Customer Dimension
CREATE TABLE Dim_Customer (
    Customer_Id INT PRIMARY KEY,
    Customer_Fname VARCHAR(100),
    Customer_Lname VARCHAR(100),
    Customer_Segment VARCHAR(50),
    Customer_Country VARCHAR(100)
);

-- 2. Create Product Dimension
CREATE TABLE Dim_Product (
    Product_Card_Id INT PRIMARY KEY,
    Product_Name VARCHAR(255),
    Category_Name VARCHAR(100),
    Department_Name VARCHAR(100),
    Product_Price DECIMAL(10,2)
);

-- 3. Create Fulfillment Fact Table
CREATE TABLE Fact_Fulfillment (
    Order_Item_Id INT PRIMARY KEY,
    Order_Id INT,
    Customer_Id INT,
    Product_Card_Id INT,
    
    -- Routing/Geography (Degenerate Dimensions)
    Order_Country VARCHAR(100),
    Order_City VARCHAR(100),
    
    -- Timeline
    Order_Date TIMESTAMP,
    Shipping_Date TIMESTAMP,
    
    -- Supply Chain Metrics & Status
    Shipping_Mode VARCHAR(50),
    Delivery_Status VARCHAR(50),
    Late_Delivery_Risk INT,
    Days_For_Shipping_Real INT,
    Days_For_Shipment_Scheduled INT,
    
    -- Basic Financials (Context for the shipment)
    Order_Item_Quantity INT,
    Sales DECIMAL(10,2),

    -- Foreign Key Constraints
    FOREIGN KEY (Customer_Id) REFERENCES Dim_Customer(Customer_Id),
    FOREIGN KEY (Product_Card_Id) REFERENCES Dim_Product(Product_Card_Id)
);

-- Create indexes for foreign key optimization
CREATE INDEX idx_fact_fulfillment_customer
    ON Fact_Fulfillment(Customer_Id);

CREATE INDEX idx_fact_fulfillment_product
    ON Fact_Fulfillment(Product_Card_Id);

CREATE INDEX idx_fact_fulfillment_order_date
    ON Fact_Fulfillment(Order_Date);