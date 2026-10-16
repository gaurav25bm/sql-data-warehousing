/*
===============================================================================
Quality Checks & Data Validation Script: Silver Layer
===============================================================================
Script Purpose:
    This script contains quality check queries used during the Silver layer ETL development.
    It includes both pre-load data profiling against Bronze tables and post-load
    validation against Silver tables to ensure data integrity, cleanliness, and consistency.

Usage:
    Run these queries to verify that data quality rules (uniqueness, null checks,
    trimming, standardization, range validation, and business rule consistency)
    are strictly met in the Silver layer.
===============================================================================
*/

USE DataWarehouse;
GO

-- ============================================================================
-- 1. CRM Customer Info (`crm_cust_info`)
-- ============================================================================

-- [Bronze Check] Check for Nulls or Duplicates in Primary Key
-- Expectation: Identify duplicates to filter out during load
SELECT
    cst_id,
    COUNT(*) AS record_count
FROM bronze.crm_cust_info 
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- [Bronze Check] Check for unwanted spaces in string columns
-- Expectation: Identify records needing TRIM
SELECT cst_firstname FROM bronze.crm_cust_info WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname  FROM bronze.crm_cust_info WHERE cst_lastname != TRIM(cst_lastname);
SELECT cst_gndr      FROM bronze.crm_cust_info WHERE cst_gndr != TRIM(cst_gndr);

-- [Bronze Check] Inspect distinct categorical values prior to standardization
SELECT DISTINCT cst_gndr FROM bronze.crm_cust_info;
SELECT DISTINCT cst_marital_status FROM bronze.crm_cust_info;
GO

-- ============================================================================
-- 2. CRM Product Info (`crm_prd_info`)
-- ============================================================================

-- [Bronze Check] Check for Nulls or Duplicates in Primary Key
SELECT
    prd_id,
    COUNT(*) AS record_count
FROM bronze.crm_prd_info 
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- [Silver Validation] Check Primary Key Uniqueness & Nulls
-- Expectation: No Results
SELECT
    prd_id,
    COUNT(*) AS record_count
FROM silver.crm_prd_info 
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- [Silver Validation] Check for unwanted trailing/leading spaces
-- Expectation: No Results
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- [Silver Validation] Check for Nulls or Negative Costs
-- Expectation: No Results
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- [Silver Validation] Verify Product Line Standardization
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

-- [Silver Validation] Check for Invalid Date Sequence (End Date before Start Date)
-- Expectation: No Results
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- [Silver Validation] Inspect full table output
SELECT * FROM silver.crm_prd_info;
GO

-- ============================================================================
-- 3. CRM Sales Details (`crm_sales_details`)
-- ============================================================================

-- [Bronze Check] Check for Invalid Dates in integer/raw date columns
SELECT
    NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- [Silver Validation] Check for Invalid Date Chronology
-- Expectation: No Results
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- [Silver Validation] Check Business Rule Consistency (Sales = Quantity * Price)
-- Expectation: No Results
SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL 
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price = 0
ORDER BY old_sls_sales, sls_quantity, sls_price;

-- [Silver Validation] Inspect full table output
SELECT * FROM silver.crm_sales_details;
GO

-- ============================================================================
-- 4. ERP Customer Info (`erp_cust_az12`)
-- ============================================================================

-- [Bronze Check] Check distinct gender values prior to mapping
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

-- [Silver Validation] Identify Out-of-Range Birth Dates
-- Expectation: No Results
SELECT DISTINCT bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- [Silver Validation] Inspect full table output
SELECT * FROM silver.erp_cust_az12;
GO

-- ============================================================================
-- 5. ERP Location (`erp_loc_a101`)
-- ============================================================================

-- [Bronze Check] Verify country standardization logic prior to loading
SELECT DISTINCT 
    cntry AS old_cntry,
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;

-- [Silver Validation] Check distinct standardized countries in Silver
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- [Silver Validation] Inspect full table output
SELECT * FROM silver.erp_loc_a101;
GO
