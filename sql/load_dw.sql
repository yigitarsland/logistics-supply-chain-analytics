BEGIN;

-- Full Reload
TRUNCATE TABLE "DW".fact_fulfillment, "DW".dim_customer, "DW".dim_product CASCADE;

-- 1. Populate Dim_Customer
-- Using MAX() for names/segments handles edge cases where the staging 
-- table might have slight variations for the same Customer_Id.
INSERT INTO "DW".dim_customer (Customer_Id, Customer_Fname, Customer_Lname, Customer_Segment, Customer_Country)
SELECT 
    s.Customer_Id,
    MAX(s.Customer_Fname),
    MAX(s.Customer_Lname),
    MAX(s.Customer_Segment),
    MAX(COALESCE(m.country_en, s.Customer_Country))
FROM staging.raw_supply_chain_data s
LEFT JOIN "DW".country_mapping m ON TRIM(s.Customer_Country) = TRIM(m.country_es)
GROUP BY s.Customer_Id;

-- 2. Populate Dim_Product
INSERT INTO "DW".dim_product (Product_Card_Id, Product_Name, Category_Name, Department_Name, Product_Price)
SELECT 
    Product_Card_Id,
    MAX(Product_Name),
    MAX(Category_Name),
    MAX(Department_Name),
    MAX(Product_Price)
FROM staging.raw_supply_chain_data
GROUP BY Product_Card_Id;

-- 3. Populate Fact_Fulfillment
-- We pull directly from staging, using the unique Order_Item_Id as our primary key.
INSERT INTO "DW".fact_fulfillment (
    Order_Item_Id, Order_Id, Customer_Id, Product_Card_Id, 
    Order_Country, -- This will now receive the English name
    Order_City, Order_Date, Shipping_Date, 
    Shipping_Mode, Delivery_Status, Late_Delivery_Risk, 
    Days_For_Shipping_Real, Days_For_Shipment_Scheduled, 
    Order_Item_Quantity, Sales
)
SELECT 
    s.Order_Item_Id,
    s.Order_Id,
    s.Customer_Id,
    s.Product_Card_Id,
    COALESCE(m.country_en, s.Order_Country), -- Uses English if found, otherwise defaults to raw data
    s.Order_City,
    s.order_date, 
    s.shipping_date,
    s.Shipping_Mode,
    s.Delivery_Status,
    s.Late_delivery_risk,
    s.Days_for_shipping_real,
    s.Days_for_shipment_scheduled,
    s.Order_Item_Quantity,
    s.Sales
FROM staging.raw_supply_chain_data s
LEFT JOIN "DW".country_mapping m 
  ON TRIM(s.Order_Country) = TRIM(m.country_es);

COMMIT;

-- ROLLBACK;

-- Check row counts
SELECT 'Staging Table' AS table_name, COUNT(*) AS total_rows 
FROM staging.raw_supply_chain_data
UNION ALL
SELECT 'Dimension: Customer', COUNT(*) 
FROM "DW".dim_customer
UNION ALL
SELECT 'Dimension: Product', COUNT(*) 
FROM "DW".dim_product
UNION ALL
SELECT 'Fact: Fulfillment', COUNT(*) 
FROM "DW".fact_fulfillment;

-- Financial metric validation
SELECT 
    'Total Sales' AS metric_name,
    (SELECT SUM(Sales) FROM staging.raw_supply_chain_data) AS staging_total,
    (SELECT SUM(Sales) FROM "DW".fact_fulfillment) AS dw_total;

-- Visual data inspection
SELECT * 
FROM "DW".fact_fulfillment 
LIMIT 10;

-- Get a complete list of every unique country name exactly as it appears in staging table
SELECT DISTINCT order_country 
FROM staging.raw_supply_chain_data;

