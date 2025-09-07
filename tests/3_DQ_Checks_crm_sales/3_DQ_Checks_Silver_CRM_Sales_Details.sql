/********************************************************************************************
 Script   : DQ_Checks_silver.crm_sales_details
 Purpose  : Validate data in Silver layer for CRM Sales Details.
            Checks include invalid dates, business rules, and derivations.
********************************************************************************************/



-- ========================
-- 1. Check for invalid Order Dates
-- ========================
-- Expectation: no invalid format
SELECT sls_order_dt
FROM silver.crm_sales_details
WHERE TRY_CAST(sls_order_dt AS DATE) IS NULL;




-- ========================
-- 2. Check for invalid Ship and Due Dates
-- ========================
-- Expectation: no invalid format
SELECT sls_ship_dt
FROM silver.crm_sales_details
WHERE TRY_CAST(sls_ship_dt AS DATE) IS NULL;

SELECT sls_due_dt
FROM silver.crm_sales_details
WHERE TRY_CAST(sls_due_dt AS DATE) IS NULL;


-- ========================
-- 3. Logical Date Validation
-- ========================
-- Order date should not be greater than Ship Date or Due Date
-- Expectation: no result
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;




-- ========================
-- 4. Business Rule Validation
-- ========================
-- Rule: Sales = Quantity * Price
-- None of Sales, Quantity, Price should be NULL or <= 0
-- Expectation: no result
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;




-- ========================
-- 5. Derivation Rules (for invalid data cases)
-- ========================
-- a) If Sales is NULL/<=0 -> derive as Quantity * ABS(Price)
-- b) If Price is NULL/<=0 -> derive as Sales / Quantity
-- c) If Price < 0 -> convert to positive
SELECT DISTINCT
    sls_sales  AS old_sls_sales,
    sls_quantity AS old_quantity,
    sls_price AS old_price,

    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 
             OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS derived_sales,

    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS derived_price

FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ========================
-- 6. Final Lookup
-- ========================
SELECT TOP 50 *
FROM silver.crm_sales_details;
