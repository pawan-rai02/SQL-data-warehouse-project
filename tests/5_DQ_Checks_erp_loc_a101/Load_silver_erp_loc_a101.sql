/********************************************************************************************
 Script Name : Load_silver_erp_loc_a101.sql
 Purpose     : Standardize and load location data from bronze.erp_loc_a101 into silver.erp_loc_a101.

 Transformation and Validation Rules :

 1. Customer ID (cid)
    - Rule: Remove all '-' characters from cid for consistency.
    - Expectation: All customer IDs in Silver do not contain '-'.

 2. Country (cntry) Standardization
    - Rule:
        - 'DE'                  -> 'Germany'
        - 'US', 'USA'           -> 'United States'
        - NULL or empty string  -> 'n/a'
        - All other values      -> trimmed original value
    - Expectation: Only full country names or 'n/a' are present in Silver.

********************************************************************************************/


--------------------------------------------------------
-- 1. Identify unmatched cids after removing '-'
--    Expectation: No records should be returned
--------------------------------------------------------
SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM bronze.erp_loc_a101
WHERE REPLACE(cid, '-', '') NOT IN 
      (SELECT cst_key FROM silver.crm_cust_info);


--------------------------------------------------------
-- 2. Profile distinct countries in Bronze
--------------------------------------------------------
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;
/*
 Sample raw country values observed:
   DE
   USA
   Germany
   United States
   NULL
   Australia
   United Kingdom
   '' (empty string)
   Canada
   France
   US
*/


--------------------------------------------------------
-- 3. Country standardization logic (validation)
--    Expectation: Only standardized country names or 'n/a' should appear
--------------------------------------------------------
SELECT DISTINCT
    cntry AS old_cntry,
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;


--------------------------------------------------------
-- 4. Insert standardized data into Silver
--------------------------------------------------------
INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
    REPLACE(cid, '-', '') AS cid,
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;


--------------------------------------------------------
-- 5. Verify Silver table
--    Expectation: Only full country names or 'n/a' exist
--------------------------------------------------------
SELECT DISTINCT cntry
FROM silver.erp_loc_a101;


--------------------------------------------------------
-- 6. Sample data inspection
--------------------------------------------------------
SELECT TOP 50 *
FROM silver.erp_loc_a101;

