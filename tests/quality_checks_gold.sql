/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage:
    - Run these checks after data loading Gold Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- Checking 'gold.dim_customers'
-- =============================================================================

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;
GO

-- =============================================================================
-- Checking 'gold.dim_products'
-- =============================================================================

-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;
GO

-- =============================================================================
-- Checking 'gold.fact_sales'
-- =============================================================================

-- Check Referential Integrity: Fact Sales vs. Customers Dimension
-- Expectation: No results (All customer_keys in fact should exist in dimension)
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;
GO

-- Check Referential Integrity: Fact Sales vs. Products Dimension
-- Expectation: No results (All product_keys in fact should exist in dimension)
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL;
GO
