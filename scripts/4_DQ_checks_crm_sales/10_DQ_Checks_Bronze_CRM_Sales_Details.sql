/********************************************************************************************
 Script Name : DQ_Checks_Bronze_CRM_Sales_Details.sql
 Purpose     : Perform data quality validation on bronze.crm_sales_details table.
 
 Checks Performed :
   1. Invalid date formats and lengths (order, ship, due dates).
   2. Date relationship checks (order date should not be after ship/due dates).
   3. Business rule validation (sales = quantity * price; no negatives/nulls).
   4. Derivation logic for correcting invalid sales/price values.
 
 Expectations :
   - All checks should return no rows.
   - If results are found, corrections must be applied in transformation logic.
 
 WARNING :
   - This script only validates and demonstrates correction logic.
   - Do not directly update Bronze tables from here.
********************************************************************************************/


--------------------------------------------
-- 1. Invalid Date Checks
-- sls_order_dt must be valid (8-digit, not <= 0)
--------------------------------------------
SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0;   -- invalid, should be treated as NULL

SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE LEN(sls_order_dt) != 8;   -- invalid length, should be treated as NULL


--------------------------------------------
-- 2. Date Relationship Validation
-- Order date must not be greater than ship date or due date
--------------------------------------------
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;


--------------------------------------------
-- 3. Business Rule Validation
-- sls_sales = sls_quantity * sls_price
-- None of these fields can be NULL or negative
--------------------------------------------
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


--------------------------------------------
-- 4. Correction / Derivation Logic
--   - If sales is null/negative/incorrect -> derive as (quantity * ABS(price)).
--   - If price is null/zero -> derive from (sales / quantity).
--   - If price is negative -> convert to positive.
--------------------------------------------
SELECT DISTINCT
    sls_sales     AS old_sls_sales,
    sls_quantity  AS old_quantity,
    sls_price     AS old_price,

    CASE 
        WHEN sls_sales IS NULL 
          OR sls_sales <= 0 
          OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS new_sls_sales,

    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0
        THEN sls_sales / NULLIF(sls_quantity, 0)   -- avoid divide by zero
        ELSE ABS(sls_price)
    END AS new_sls_price

FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
