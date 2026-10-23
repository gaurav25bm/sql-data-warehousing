# sql-data-warehousing
Building a modern warehouse with SQL Server, including ETL processes, data modelling and analytics.

/*
===============================================================================
Master DDL & ETL Script: End-to-End Data Warehouse (Bronze, Silver, Gold)
===============================================================================
Script Purpose:
    This script initializes the DataWarehouse database, sets up schemas, 
    creates Bronze raw tables, Silver cleaned tables, Gold analytical views 
    (Star Schema), and runs data quality validation checks.
===============================================================================
*/

USE master;
GO

-- Drop and recreate DataWarehouse database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    CREATE DATABASE DataWarehouse;
END;
GO

USE DataWarehouse;
GO

-- ============================================================================
-- 1. CREATE SCHEMAS
-- ============================================================================
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze') EXEC('CREATE SCHEMA bronze;');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver') EXEC('CREATE SCHEMA silver;');
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold') EXEC('CREATE SCHEMA gold;');
GO

-- ============================================================================
-- 2. BRONZE LAYER (Tables)
-- ============================================================================
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL DROP TABLE bronze.crm_cust_info;
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL DROP TABLE bronze.crm_prd_info;
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL DROP TABLE bronze.crm_sales_details;
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL DROP TABLE bronze.erp_loc_a101;
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL DROP TABLE bronze.erp_cust_az12;
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

CREATE TABLE bronze.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

CREATE TABLE bronze.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);
GO

-- ============================================================================
-- 3. SILVER LAYER (Tables)
-- ============================================================================
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL DROP TABLE silver.crm_cust_info;
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL DROP TABLE silver.crm_prd_info;
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL DROP TABLE silver.crm_sales_details;
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL DROP TABLE silver.erp_loc_a101;
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL DROP TABLE silver.erp_cust_az12;
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id VARCHAR(50),
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE silver.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- ============================================================================
-- 4. GOLD LAYER (Views - Star Schema)
-- ============================================================================

-- Create Dimension: gold.dim_customers
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    ci.cst_marital_status             AS marital_status,
    CASE 
        WHEN UPPER(TRIM(ci.cst_gndr)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(ci.cst_gndr)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END                                AS gender,
    ca.bdate                           AS birth_date,
    ca.gen                             AS generation,
    la.cntry                           AS country
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid;
GO

-- Create Dimension: gold.dim_products
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;
GO

-- Create Fact Table: gold.fact_sales
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
GO

-- ============================================================================
-- 5. QUALITY CHECKS (Gold Layer Validation)
-- ============================================================================

-- Check Uniqueness of Customer Key (Expectation: 0 rows)
SELECT customer_key, COUNT(*) AS duplicate_count 
FROM gold.dim_customers 
GROUP BY customer_key 
HAVING COUNT(*) > 1;

-- Check Uniqueness of Product Key (Expectation: 0 rows)
SELECT product_key, COUNT(*) AS duplicate_count 
FROM gold.dim_products 
GROUP BY product_key 
HAVING COUNT(*) > 1;

-- Check Referential Integrity: Fact Sales vs Customers (Expectation: 0 rows)
SELECT * FROM gold.fact_sales f 
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key 
WHERE c.customer_key IS NULL;

-- Check Referential Integrity: Fact Sales vs Products (Expectation: 0 rows)
SELECT * FROM gold.fact_sales f 
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key 
WHERE p.product_key IS NULL;
GO
