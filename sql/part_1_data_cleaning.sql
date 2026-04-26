-- ========================================
-- PART A - DATA CLEANING & PREPARATION
-- ========================================

-- 1. DATA LOADING & STRUCTURE CHECK
-- ----------------------------------------------------------
-- Action: Previewed first 10 rows of each table
-- Purpose: Confirm successful data load and understand structure
-- ----------------------------------------------------------
SELECT * FROM customers LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM orders LIMIT 10;
SELECT * FROM payments LIMIT 10;
SELECT * FROM products LIMIT 10;
SELECT * FROM reviews LIMIT 10;
SELECT * FROM sellers LIMIT 10;

-- 2. ROW COUNT CHECK
-- ----------------------------------------------
-- Action: Counted total records in all tables
-- Purpose: validate dataset size and detect incomplete loads
-- ----------------------------------------------
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM reviews;
SELECT COUNT(*) FROM sellers;

-- 3. SCHEMA INSPECTION
-- ----------------------------------------------
-- Action: Check information_schema for metadata review
-- Purpose: Understand column names, data types, and relationships across all tables
-- ----------------------------------------------
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='customers';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='order_items';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='orders';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='payments';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='products';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='reviews';

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name='sellers';

-- 4. DATE RANGE CHECK
-- Check minimum and maximum order dates
SELECT 
	MIN(order_date), 
	MAX(order_date)
FROM orders;

-- 5. DUPLICATE CHECK USING ROW_NUMBER()

-- Check for duplicates on customers table
WITH duplicate_customers AS 
	(
	SELECT *, 
		ROW_NUMBER() OVER(PARTITION BY customer_id, first_name, last_name, email, 
		city, state, signup_date, account_status
			) AS row_num
	FROM customers
	)
SELECT *
FROM duplicate_customers
WHERE row_num>1;

-- Check for duplicates on sellers table
SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY seller_id, seller_name, onboarding_date, product_category,
		city, state, account_status
			) AS row_num
	FROM sellers
	) sllrs
WHERE row_num>1;

-- Check for duplicates on orders table
SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY order_id, customer_id, seller_id, order_date,
			delivery_date, order_status, total_amount
				) AS row_num
	FROM orders
	) ord
WHERE row_num>1;

-- Check for duplicates on order_items table
SELECT *
FROM (
	SELECT *, 
		ROW_NUMBER() OVER(PARTITION BY item_id, order_id, product_id, quantity, 
		unit_price, line_total
			)AS row_num
	FROM order_items
	)ord_itm
WHERE row_num>1;

-- 6. NULL VALUE DETECTION

-- Check for NULL values in critical fields within the customers table
SELECT 
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE email IS NULL) AS null_email,
	COUNT(*) FILTER (WHERE signup_date IS NULL) AS null_signup_date
FROM customers;

-- Check for NULL values in critical fields within the order_items table
SELECT 
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS null_unit_price,
	COUNT(*) FILTER (WHERE line_total IS NULL) AS null_line_total,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS null_quantity
FROM order_items;

-- Check for NULL values in critical fields within the orders table
SELECT 
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS null_order_date,
    COUNT(*) FILTER (WHERE total_amount IS NULL) AS null_total_amount
FROM orders;

-- Check for NULL values in critical fields within the payments table
SELECT 
	COUNT(*) AS null_amount
FROM payments
WHERE amount IS NULL;

-- Check for NULL values in critical fields within the products table
SELECT 
	COUNT(*) AS null_unit_price
FROM products
WHERE unit_price IS NULL;

-- 7. DATA FIX: Handling of NULL Values in Key Numeric Fields

-- Identify order_items records with missing unit_price
SELECT 
	product_id,
	unit_price
FROM order_items
WHERE unit_price IS NULL;

-- Check for inconsistencies between order_items unit_price and products unit_price
SELECT 
	COUNT(*)
FROM order_items oi
JOIN products p
	ON oi.product_id = p.product_id
WHERE oi.unit_price IS NOT NULL
AND oi.unit_price != p.unit_price;

-- Update missing unit_price values in order_items using products table
UPDATE order_items oi
SET unit_price = p.unit_price
FROM products p
WHERE oi.product_id = p.product_id
AND oi.unit_price IS NULL;

-- Identify payments with missing transaction amounts
SELECT 
    p.order_id,
    p.amount,
    o.total_amount
FROM payments p
JOIN orders o 
	ON p.order_id = o.order_id
WHERE p.amount IS NULL;

-- Identify orders with missing total_amount values
SELECT 
	o.order_id,
	o.total_amount,
	SUM(oi.quantity * oi.unit_price) AS total
FROM orders o
JOIN order_items oi
	ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount IS NULL;

-- 8. STANDARDIZATION (CUSTOMERS, SELLERS & PRODUCTS)

-- Inspect & identify incosistencies on unique city & state in customers table
SELECT DISTINCT 
	city,
	state
FROM customers;

-- Remove extra space & normalize text format for city and state in customers table
UPDATE customers
SET city = INITCAP(TRIM(city)),
    state = INITCAP(TRIM(state));

-- Map inconsistent spellings & standardize city name variations in customers table
UPDATE customers
SET city = 
CASE
    WHEN LOWER(TRIM(city)) IN ('lagos', 'lago s', 'lagos ') THEN 'Lagos'
    WHEN LOWER(TRIM(city)) IN ('port harcourt', 'portharcourt', 'port-harcourt') THEN 'Port Harcourt'
    WHEN LOWER(TRIM(city)) = 'abuja' THEN 'Abuja'
    WHEN LOWER(TRIM(city)) = 'kano' THEN 'Kano'
    WHEN LOWER(TRIM(city)) = 'ibadan' THEN 'Ibadan'
    ELSE INITCAP(TRIM(city))
END;

-- Re-check distinct city after standardization
SELECT DISTINCT 
	city
FROM customers;

-- Inspect distinct products categories
SELECT DISTINCT 
	category
FROM products;

-- Standardize product categories
UPDATE products
SET category = 
CASE
    WHEN LOWER(TRIM(category)) IN ('electronics', 'electronis') THEN 'Electronics'
    WHEN LOWER(TRIM(category)) IN ('sports', 'sports & fitness', 'sports and fitness') THEN 'Sports & Fitness'
    WHEN LOWER(TRIM(category)) IN ('books', 'books & stationery', 'books and stationery') THEN 'Books & Stationery'
    WHEN LOWER(TRIM(category)) IN ('fashion', 'fashon') THEN 'Fashion'
    WHEN LOWER(TRIM(category)) IN ('home & garden', 'home and garden') THEN 'Home & Garden'
    WHEN LOWER(TRIM(category)) IN ('food', 'food & beverages', 'food and beverages') THEN 'Food & Beverages'
    WHEN LOWER(TRIM(category)) IN ('beauty', 'beauty & personal care', 'beauty and personal care') THEN 'Beauty & Personal Care'
    ELSE INITCAP(TRIM(category))
END;

-- Re-check distinct product categories after standardization
SELECT DISTINCT 
	category
FROM products;

-- Inspect sellers location and product category data
SELECT DISTINCT
	product_category,
	city,
	state
FROM sellers;

-- Standardize sellers city and state values
UPDATE sellers
SET city = 
CASE
	WHEN LOWER(TRIM(city)) IN ('lagos', 'lago s') THEN 'Lagos'
    WHEN LOWER(TRIM(city)) = 'ibadan' THEN 'Ibadan'
    WHEN LOWER(TRIM(city)) = 'abuja' THEN 'Abuja'
	WHEN LOWER(TRIM(city)) = 'kano' THEN 'Kano'
    WHEN LOWER(TRIM(city)) IN ('port harcourt', 'portharcourt', 'port-harcourt') THEN 'Port Harcourt'
    ELSE INITCAP(TRIM(city))
END,

    state = 
CASE
	WHEN LOWER(TRIM(state)) IN ('lagos') THEN 'Lagos'
    WHEN LOWER(TRIM(state)) IN ('oyo') THEN 'Oyo'
    WHEN LOWER(TRIM(state)) IN ('fct') THEN 'FCT'
    WHEN LOWER(TRIM(state)) IN ('rivers') THEN 'Rivers'
    ELSE INITCAP(TRIM(state))
END;

-- Standardize sellers product categories
UPDATE sellers
SET product_category = 
CASE
    WHEN LOWER(TRIM(product_category)) IN ('electronics', 'electronis') THEN 'Electronics'
    WHEN LOWER(TRIM(product_category)) IN ('sports', 'sports & fitness', 'sports and fitness') THEN 'Sports & Fitness'
    WHEN LOWER(TRIM(product_category)) IN ('fashion', 'fashon') THEN 'Fashion'
    WHEN LOWER(TRIM(product_category)) IN ('books', 'books and stationery', 'books & stationery') THEN 'Books & Stationery'
    WHEN LOWER(TRIM(product_category)) IN ('food', 'food & beverages', 'food and beverages') THEN 'Food & Beverages'
	WHEN LOWER(TRIM(product_category)) IN ('home & garden', 'home and garden') THEN 'Home & Garden'
    WHEN LOWER(TRIM(product_category)) IN ('beauty', 'beauty & personal care', 'beauty and personal care') THEN 'Beauty & Personal Care'
    ELSE INITCAP(TRIM(product_category))
END;

-- Re-check sellers data after standardization
SELECT DISTINCT
	product_category,
	city,
	state
FROM sellers;

-- 9. DATA VALIDATION

/* Validate order totals against order_items aggregation
Output: Orders with difference greater than ₦10 are marked as 'FLAGGED' */
SELECT 
    o.order_id,
    o.total_amount,
    SUM(oi.quantity * oi.unit_price) AS calculated_total,
    (o.total_amount - SUM(oi.quantity * oi.unit_price)) AS difference,
    CASE 
        WHEN ABS(o.total_amount - SUM(oi.quantity * oi.unit_price)) > 10 
        THEN 'Flagged'
        ELSE 'Ok'
    END AS validation_status
FROM orders o
JOIN order_items oi 
    ON o.order_id = oi.order_id
WHERE o.total_amount IS NOT NULL
GROUP BY o.order_id, o.total_amount;

/* Validate review ratings
Output: Classifies each review as VALID or INVALID */
SELECT *,
    CASE 
        WHEN rating BETWEEN 1 AND 5 THEN 'Valid'
        ELSE 'Invalid'
    END AS rating_status
FROM reviews;

/* Validate product pricing data
Output: Flags NULL prices as 'MISSING' and negative prices as 'INVALID' */

SELECT *,
    CASE 
        WHEN unit_price IS NULL THEN 'Missing'
        WHEN unit_price < 0 THEN 'Invalid'
        ELSE 'Valid'
    END AS price_status
FROM products;


-- SUMMARY OF DATA CLEANING & PREPARATION
-- ==============================================
-- 1. NULL Handling Strategy:
-- Missing values were identified across key tables:
-- customers (email), order_items (unit_price, line_total),
-- orders (total_amount), payments (amount), and products (unit_price).
--
-- Due to dependencies between pricing fields, missing values in
-- order_items and products could not be reliably imputed without
-- introducing potential bias in financial calculations.
--
-- 2. Decision on Imputation:
-- No imputation was performed on financial fields (unit_price,
-- line_total, total_amount, amount) to preserve data integrity.
--
-- 3. Analysis Approach:
-- Revenue and order-level metrics were computed dynamically using
-- available valid records, excluding NULL-based distortions where necessary.
--
-- 4. Data Quality Insight:
-- Missing pricing data indicates incomplete transaction records,
-- affecting full reconciliation of order and payment values.
--
-- 5. Conclusion:
-- The dataset was retained in its original structure, with cleaning
-- focused on standardization, validation, and analytical filtering
-- rather than destructive corrections.