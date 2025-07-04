
-- Basic bitmap index creation
CREATE BITMAP INDEX idx_bitmap_column ON table_name (column_name);

-- Bitmap index on multiple columns
CREATE BITMAP INDEX idx_bitmap_multi ON table_name (column1, column2);

-- Bitmap index with tablespace specification
CREATE BITMAP INDEX idx_bitmap_ts ON table_name (column_name)
TABLESPACE index_tablespace;

-- Bitmap join index (Oracle advanced feature)
CREATE BITMAP INDEX idx_bitmap_join ON fact_table (dimension_table.attribute)
FROM fact_table, dimension_table
WHERE fact_table.dimension_id = dimension_table.dimension_id;

-- Drop bitmap index
DROP INDEX idx_bitmap_column;

-- Rebuild bitmap index
ALTER INDEX idx_bitmap_column REBUILD;

-- Note: MySQL and PostgreSQL do not natively support bitmap indexes
-- Alternative approaches for similar functionality in MySQL:
-- - Use multiple B-tree indexes and let optimizer combine them
-- - Consider third-party storage engines like TokuDB


-- =============================================
-- SCENARIO: Retail Data Warehouse with Bitmap Index Optimization
-- Large retail chain analyzing sales data across multiple dimensions
-- with millions of transactions requiring fast analytical queries
-- =============================================

-- =============================================
-- PROBLEM ANALYSIS: Low-Cardinality Analytical Dimensions
-- =============================================

-- Business Requirements:
-- 1. Fast filtering on categorical dimensions (store type, product category, region)
-- 2. Complex analytical queries combining multiple filters
-- 3. Aggregate reporting across dimensional hierarchies
-- 4. Read-heavy workload with minimal real-time updates
-- 5. Support for ad-hoc business intelligence queries

-- Original performance issues:
-- - B-tree indexes inefficient for low-cardinality columns
-- - Multiple index scans expensive for complex WHERE clauses
-- - Large storage overhead for traditional indexes on categorical data
-- - Slow COUNT and SUM operations on filtered datasets

-- =============================================
-- DATA WAREHOUSE SCHEMA DESIGN
-- =============================================

-- Sales fact table with dimensional attributes (Oracle syntax)
CREATE TABLE sales_fact (
    sale_id NUMBER(12) PRIMARY KEY,
    transaction_date DATE NOT NULL,
    store_id NUMBER(6) NOT NULL,
    product_id NUMBER(8) NOT NULL,
    customer_id NUMBER(10),
    
    -- Low-cardinality dimensional attributes (ideal for bitmap indexes)
    store_type VARCHAR2(20) NOT NULL,           -- 8 distinct values
    store_region VARCHAR2(30) NOT NULL,         -- 12 distinct values
    product_category VARCHAR2(50) NOT NULL,     -- 25 distinct values
    product_subcategory VARCHAR2(50),           -- 150 distinct values
    customer_segment VARCHAR2(20),              -- 6 distinct values
    sales_channel VARCHAR2(20) NOT NULL,        -- 5 distinct values
    payment_method VARCHAR2(20),                -- 8 distinct values
    promotion_type VARCHAR2(30),                -- 15 distinct values
    
    -- Boolean flags (perfect for bitmap indexes)
    weekend_sale CHAR(1) CHECK (weekend_sale IN ('Y', 'N')),
    holiday_sale CHAR(1) CHECK (holiday_sale IN ('Y', 'N')),
    clearance_sale CHAR(1) CHECK (clearance_sale IN ('Y', 'N')),
    loyalty_discount CHAR(1) CHECK (loyalty_discount IN ('Y', 'N')),
    
    -- Continuous measures (not suitable for bitmap indexes)
    quantity_sold NUMBER(8,2) NOT NULL,
    unit_price NUMBER(10,2) NOT NULL,
    discount_amount NUMBER(8,2) DEFAULT 0,
    net_sales_amount NUMBER(12,2) NOT NULL,
    cost_amount NUMBER(12,2),
    profit_amount NUMBER(12,2)
);

-- Customer dimension table for bitmap join indexes
CREATE TABLE customers (
    customer_id NUMBER(10) PRIMARY KEY,
    customer_type VARCHAR2(20) NOT NULL,        -- 4 distinct values
    age_group VARCHAR2(20),                      -- 6 distinct values
    income_bracket VARCHAR2(20),                -- 8 distinct values
    geographic_region VARCHAR2(30),             -- 12 distinct values
    loyalty_tier VARCHAR2(15)                   -- 5 distinct values
);

-- Product dimension table
CREATE TABLE products (
    product_id NUMBER(8) PRIMARY KEY,
    product_category VARCHAR2(50) NOT NULL,
    product_brand VARCHAR2(50),                 -- 200 distinct values
    price_tier VARCHAR2(15),                    -- 5 distinct values
    seasonal_indicator VARCHAR2(10)             -- 4 distinct values
);

-- =============================================
-- STRATEGIC BITMAP INDEX IMPLEMENTATION
-- =============================================

-- 1. CORE DIMENSIONAL BITMAP INDEXES

-- Store-related bitmap indexes for geographic analysis
CREATE BITMAP INDEX bmp_idx_store_type ON sales_fact (store_type);
CREATE BITMAP INDEX bmp_idx_store_region ON sales_fact (store_region);

-- Product-related bitmap indexes for merchandise analysis
CREATE BITMAP INDEX bmp_idx_product_category ON sales_fact (product_category);
CREATE BITMAP INDEX bmp_idx_product_subcategory ON sales_fact (product_subcategory);

-- Customer segmentation bitmap indexes
CREATE BITMAP INDEX bmp_idx_customer_segment ON sales_fact (customer_segment);

-- Sales channel and payment analysis
CREATE BITMAP INDEX bmp_idx_sales_channel ON sales_fact (sales_channel);
CREATE BITMAP INDEX bmp_idx_payment_method ON sales_fact (payment_method);

-- Promotional analysis bitmap indexes
CREATE BITMAP INDEX bmp_idx_promotion_type ON sales_fact (promotion_type);

-- 2. BOOLEAN FLAG BITMAP INDEXES (EXTREMELY EFFICIENT)

-- Time-based promotional flags
CREATE BITMAP INDEX bmp_idx_weekend_sale ON sales_fact (weekend_sale);
CREATE BITMAP INDEX bmp_idx_holiday_sale ON sales_fact (holiday_sale);
CREATE BITMAP INDEX bmp_idx_clearance_sale ON sales_fact (clearance_sale);
CREATE BITMAP INDEX bmp_idx_loyalty_discount ON sales_fact (loyalty_discount);

-- 3. COMPOSITE BITMAP INDEXES FOR RELATED DIMENSIONS

-- Store analysis combining type and region
CREATE BITMAP INDEX bmp_idx_store_type_region ON sales_fact (store_type, store_region);

-- Product hierarchy analysis
CREATE BITMAP INDEX bmp_idx_product_cat_subcat ON sales_fact (product_category, product_subcategory);

-- Promotional analysis combining flags
CREATE BITMAP INDEX bmp_idx_promo_flags ON sales_fact (weekend_sale, holiday_sale, clearance_sale);

-- 4. BITMAP JOIN INDEXES (ORACLE ADVANCED FEATURE)

-- Customer demographic analysis through join
CREATE BITMAP INDEX bmp_idx_customer_type_join ON sales_fact (c.customer_type)
FROM sales_fact sf, customers c
WHERE sf.customer_id = c.customer_id;

-- Customer age group analysis
CREATE BITMAP INDEX bmp_idx_age_group_join ON sales_fact (c.age_group)
FROM sales_fact sf, customers c
WHERE sf.customer_id = c.customer_id;

-- Product brand analysis through join
CREATE BITMAP INDEX bmp_idx_product_brand_join ON sales_fact (p.product_brand)
FROM sales_fact sf, products p
WHERE sf.product_id = p.product_id;

-- =============================================
-- SAMPLE DATA INSERTION
-- =============================================

-- Insert sample customers
INSERT INTO customers VALUES 
(1001, 'Premium', '35-44', 'High', 'Northeast', 'Platinum'),
(1002, 'Standard', '25-34', 'Medium', 'Southeast', 'Gold'),
(1003, 'Budget', '18-24', 'Low', 'West', 'Silver'),
(1004, 'Premium', '45-54', 'High', 'Midwest', 'Platinum'),
(1005, 'Standard', '55+', 'Medium', 'Southwest', 'Bronze');

-- Insert sample products
INSERT INTO products VALUES
(2001, 'Electronics', 'TechBrand', 'Premium', 'Year-Round'),
(2002, 'Clothing', 'FashionCorp', 'Mid-Range', 'Seasonal'),
(2003, 'Home & Garden', 'HomeCorp', 'Budget', 'Seasonal'),
(2004, 'Sports', 'SportsCorp', 'Premium', 'Year-Round'),
(2005, 'Books', 'PublishCorp', 'Budget', 'Year-Round');

-- Insert sample sales transactions
INSERT INTO sales_fact VALUES
(100001, DATE '2024-06-15', 501, 2001, 1001, 'Flagship', 'Northeast', 'Electronics', 'Computers', 'Premium', 'Online', 'Credit Card', 'Summer Sale', 'N', 'N', 'Y', 'Y', 2, 1299.99, 100.00, 2499.98),
(100002, DATE '2024-06-16', 502, 2002, 1002, 'Outlet', 'Southeast', 'Clothing', 'Shirts', 'Standard', 'In-Store', 'Cash', 'None', 'Y', 'N', 'N', 'N', 3, 29.99, 5.00, 84.97),
(100003, DATE '2024-06-17', 503, 2003, 1003, 'Regular', 'West', 'Home & Garden', 'Furniture', 'Budget', 'Online', 'Debit Card', 'Clearance', 'N', 'N', 'Y', 'N', 1, 199.99, 50.00, 149.99),
(100004, DATE '2024-06-18', 504, 2004, 1004, 'Flagship', 'Midwest', 'Sports', 'Equipment', 'Premium', 'Phone', 'Credit Card', 'None', 'N', 'N', 'N', 'Y', 1, 499.99, 0.00, 499.99),
(100005, DATE '2024-06-19', 505, 2005, 1005, 'Regular', 'Southwest', 'Books', 'Fiction', 'Standard', 'In-Store', 'Cash', 'Weekend Special', 'Y', 'N', 'N', 'N', 5, 14.99, 2.00, 72.95);

-- =============================================
-- BITMAP INDEX OPTIMIZATION EXAMPLES
-- =============================================

-- Example 1: Fast categorical filtering using bitmap indexes
-- Query uses multiple bitmap indexes for efficient AND operations
-- EXPLAIN PLAN FOR
SELECT 
    store_region,
    product_category,
    COUNT(*) AS transaction_count,
    SUM(net_sales_amount) AS total_sales,
    AVG(net_sales_amount) AS avg_sale_amount
FROM sales_fact
WHERE store_type = 'Flagship'           -- Uses bmp_idx_store_type
AND product_category = 'Electronics'     -- Uses bmp_idx_product_category
AND sales_channel = 'Online'            -- Uses bmp_idx_sales_channel
AND weekend_sale = 'N'                  -- Uses bmp_idx_weekend_sale
GROUP BY store_region, product_category;

-- Example 2: Boolean flag combination analysis
-- Demonstrates efficient bitmap operations on flag columns
SELECT 
    promotion_type,
    weekend_sale,
    holiday_sale,
    clearance_sale,
    COUNT(*) AS promo_transaction_count,
    SUM(net_sales_amount) AS promo_sales_total,
    AVG(discount_amount) AS avg_discount
FROM sales_fact
WHERE (weekend_sale = 'Y' OR holiday_sale = 'Y' OR clearance_sale = 'Y')  -- Bitmap OR operations
AND store_region IN ('Northeast', 'Southeast')                             -- Bitmap IN operation
AND customer_segment = 'Premium'                                          -- Additional bitmap filter
GROUP BY promotion_type, weekend_sale, holiday_sale, clearance_sale
ORDER BY promo_sales_total DESC;

-- Example 3: Complex multi-dimensional analysis
-- Leverages multiple bitmap indexes for comprehensive filtering
SELECT 
    sf.store_type,
    sf.product_category,
    c.customer_type,
    c.age_group,
    COUNT(*) AS transaction_count,
    SUM(sf.net_sales_amount) AS category_sales,
    SUM(sf.profit_amount) AS category_profit,
    ROUND(AVG(sf.net_sales_amount), 2) AS avg_transaction_value
FROM sales_fact sf
JOIN customers c ON sf.customer_id = c.customer_id
WHERE sf.store_region IN ('Northeast', 'West', 'Midwest')    -- Bitmap index on store_region
AND sf.product_category IN ('Electronics', 'Sports')        -- Bitmap index on product_category
AND sf.sales_channel = 'Online'                            -- Bitmap index on sales_channel
AND sf.loyalty_discount = 'Y'                              -- Bitmap index on loyalty_discount
AND c.customer_type = 'Premium'                            -- Could use bitmap join index
AND sf.transaction_date >= DATE '2024-06-01'
GROUP BY sf.store_type, sf.product_category, c.customer_type, c.age_group
ORDER BY category_profit DESC;

-- Example 4: Ad-hoc analytical query with multiple filters
-- Shows bitmap index efficiency for unpredictable query patterns
SELECT 
    store_region,
    sales_channel,
    payment_method,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(*) AS total_transactions,
    SUM(net_sales_amount) AS region_revenue,
    SUM(CASE WHEN weekend_sale = 'Y' THEN net_sales_amount ELSE 0 END) AS weekend_revenue,
    ROUND(SUM(net_sales_amount) / COUNT(*), 2) AS revenue_per_transaction
FROM sales_fact
WHERE store_type IN ('Flagship', 'Regular')                 -- Bitmap index utilization
AND product_category NOT IN ('Books')                       -- Bitmap index with NOT operation
AND (clearance_sale = 'Y' OR promotion_type IS NOT NULL)   -- Complex bitmap conditions
AND customer_segment IN ('Premium', 'Standard')             -- Bitmap IN operation
GROUP BY store_region, sales_channel, payment_method
HAVING COUNT(*) > 10                                        -- Post-aggregation filtering
ORDER BY region_revenue DESC;

-- =============================================
-- BITMAP INDEX PERFORMANCE MONITORING
-- =============================================

-- Monitor bitmap index usage and effectiveness
SELECT 
    table_name,
    index_name,
    index_type,
    uniqueness,
    status,
    leaf_blocks,
    distinct_keys,
    clustering_factor
FROM user_indexes
WHERE table_name = 'SALES_FACT'
AND index_type = 'BITMAP'
ORDER BY index_name;

-- Analyze bitmap index compression ratios
SELECT 
    index_name,
    blevel,
    leaf_blocks,
    num_rows,
    distinct_keys,
    ROUND(num_rows / NULLIF(distinct_keys, 0), 2) AS avg_rows_per_key,
    ROUND(leaf_blocks / NULLIF(distinct_keys, 0), 4) AS blocks_per_key
FROM user_indexes
WHERE table_name = 'SALES_FACT'
AND index_type = 'BITMAP'
ORDER BY avg_rows_per_key DESC;

-- Check bitmap index storage efficiency
SELECT 
    segment_name AS index_name,
    segment_type,
    ROUND(bytes / 1024 / 1024, 2) AS size_mb,
    blocks,
    extents
FROM user_segments
WHERE segment_name LIKE 'BMP_IDX_%'
ORDER BY bytes DESC;

-- =============================================
-- BITMAP INDEX MAINTENANCE AND BEST PRACTICES
-- =============================================

-- Rebuild bitmap indexes for optimal performance (typically during maintenance windows)
-- ALTER INDEX bmp_idx_store_type REBUILD;
-- ALTER INDEX bmp_idx_product_category REBUILD;

-- Analyze bitmap index statistics for optimizer
-- ANALYZE INDEX bmp_idx_store_type COMPUTE STATISTICS;
-- ANALYZE INDEX bmp_idx_product_category COMPUTE STATISTICS;

-- Monitor bitmap index fragmentation
SELECT 
    index_name,
    blevel,
    leaf_blocks,
    used_space,
    pct_used,
    CASE 
        WHEN pct_used < 75 THEN 'Consider Rebuild'
        WHEN pct_used < 50 THEN 'Rebuild Recommended'
        ELSE 'Optimal'
    END AS maintenance_recommendation
FROM (
    SELECT 
        index_name,
        blevel,
        leaf_blocks,
        ROUND((num_rows * avg_row_len) / (leaf_blocks * 8192) * 100, 2) AS used_space,
        ROUND((num_rows * avg_row_len) / (leaf_blocks * 8192) * 100, 2) AS pct_used
    FROM user_indexes
    WHERE table_name = 'SALES_FACT'
    AND index_type = 'BITMAP'
);

-- Example of bitmap index cardinality analysis
-- Identifies columns suitable for bitmap indexing
SELECT 
    column_name,
    num_distinct,
    num_rows,
    ROUND(num_distinct / num_rows * 100, 4) AS cardinality_percentage,
    CASE 
        WHEN num_distinct / num_rows < 0.01 THEN 'Excellent for Bitmap'
        WHEN num_distinct / num_rows < 0.05 THEN 'Good for Bitmap'
        WHEN num_distinct / num_rows < 0.10 THEN 'Consider Bitmap'
        ELSE 'Use B-tree Instead'
    END AS index_recommendation
FROM user_tab_columns
WHERE table_name = 'SALES_FACT'
AND data_type IN ('VARCHAR2', 'CHAR', 'NUMBER')
ORDER BY cardinality_percentage;

-- Final verification of bitmap index implementation
SELECT 
    'Bitmap Index Implementation Summary' AS summary_type,
    COUNT(*) AS total_bitmap_indexes,
    SUM(CASE WHEN index_name LIKE '%_FLAGS' THEN 1 ELSE 0 END) AS boolean_indexes,
    SUM(CASE WHEN index_name LIKE '%_JOIN' THEN 1 ELSE 0 END) AS join_indexes,
    'Optimized for analytical workloads' AS optimization_focus
FROM user_indexes
WHERE table_name = 'SALES_FACT'
AND index_type = 'BITMAP';



