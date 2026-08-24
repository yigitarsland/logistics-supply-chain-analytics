-- AUTOMATED CHECKS
-- QA: Check for Orphaned Records (Should return 0)
SELECT 
    'Orphaned Customers' AS defect_type, 
    COUNT(*) AS defect_count 
FROM "DW".fact_fulfillment 
WHERE Customer_Id NOT IN (SELECT Customer_Id FROM "DW".dim_customer)
UNION ALL
SELECT 
    'Orphaned Products', 
    COUNT(*) 
FROM "DW".fact_fulfillment 
WHERE Product_Card_Id NOT IN (SELECT Product_Card_Id FROM "DW".dim_product);

-- QA: Check for duplicate Primary Keys (Should return 0 rows)
SELECT 
    Order_Item_Id, 
    COUNT(*) as appearance_count
FROM "DW".fact_fulfillment
GROUP BY Order_Item_Id
HAVING COUNT(*) > 1;

-- QA: Check for illogical dates (Shipping before Ordering)
SELECT 
    Order_Item_Id, 
    Order_Date, 
    Shipping_Date
FROM "DW".fact_fulfillment
WHERE Shipping_Date < Order_Date;

-- QA: Check for unexpected NULLs in critical fields
SELECT 
    COUNT(*) AS rows_with_null_metrics
FROM "DW".fact_fulfillment
WHERE Order_Date IS NULL 
   OR Sales IS NULL 
   OR Order_Item_Quantity IS NULL;

-- Calculate the average variance between scheduled and real shipping days across different delivery statuses.
SELECT 
    Delivery_Status,
    COUNT(Order_Item_Id) as Total_Shipments,
    AVG(Days_For_Shipping_Real - Days_For_Shipment_Scheduled) as Avg_Days_Off_Schedule
FROM "DW".Fact_Fulfillment
GROUP BY Delivery_Status
ORDER BY Total_Shipments DESC;

-- Check for unmapped or broken country names
SELECT 
    Order_Country, 
    COUNT(*) as Affected_Rows
FROM "DW".fact_fulfillment
WHERE Order_Country IS NULL 
   OR Order_Country LIKE '%%'
GROUP BY Order_Country;

-- ONE TIME CHECKS
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

-- FK Checks
SELECT
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_schema ILIKE 'dw'
  AND tc.table_name ILIKE 'fact_fulfillment';