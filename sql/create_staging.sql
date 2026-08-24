-- staging.sql
CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.raw_supply_chain_data;

CREATE TABLE raw_supply_chain_data (
    order_type TEXT, -- 'Type' is a reserved SQL word, so we use order_type
    days_for_shipping_real INTEGER,
    days_for_shipment_scheduled INTEGER,
    benefit_per_order NUMERIC,
    sales_per_customer NUMERIC,
    delivery_status TEXT,
    late_delivery_risk INTEGER,
    category_id INTEGER,
    category_name TEXT,
    customer_city TEXT,
    customer_country TEXT,
    customer_email TEXT,
    customer_fname TEXT,
    customer_id INTEGER,
    customer_lname TEXT,
    customer_password TEXT,
    customer_segment TEXT,
    customer_state TEXT,
    customer_street TEXT,
    customer_zipcode TEXT, -- ZIP codes can have letters or leading zeros
    department_id INTEGER,
    department_name TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    market TEXT,
    order_city TEXT,
    order_country TEXT,
    order_customer_id INTEGER,
    order_date TIMESTAMP,
    order_id INTEGER,
    order_item_cardprod_id INTEGER,
    order_item_discount NUMERIC,
    order_item_discount_rate NUMERIC,
    order_item_id INTEGER,
    order_item_product_price NUMERIC,
    order_item_profit_ratio NUMERIC,
    order_item_quantity INTEGER,
    sales NUMERIC,
    order_item_total NUMERIC,
    order_profit_per_order NUMERIC,
    order_region TEXT,
    order_state TEXT,
    order_status TEXT,
    order_zipcode TEXT,
    product_card_id INTEGER,
    product_category_id INTEGER,
    product_description TEXT,
    product_image TEXT,
    product_name TEXT,
    product_price NUMERIC,
    product_status INTEGER,
    shipping_date TIMESTAMP,
    shipping_mode TEXT
);

-- Check total row count (DataCo dataset should have 180,519 rows)
SELECT COUNT(*) AS total_staging_rows 
FROM staging.raw_supply_chain_data;

-- test query to check if the data is loaded correctly
SELECT 
    order_id, 
    order_date, 
    shipping_date, 
    shipping_mode, 
    delivery_status, 
    late_delivery_risk, 
    sales 
FROM staging.raw_supply_chain_data 
WHERE order_id IS NOT NULL 
LIMIT 5;
