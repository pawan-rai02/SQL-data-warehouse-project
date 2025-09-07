/********************************************************************************************
 Script Name : Load_silver_erp_px_cat_g1v2.sql
 Purpose     : Standardize and load product category data from bronze.erp_px_cat_g1v2 into silver.erp_px_cat_g1v2.

 Transformation and Validation Rules :

 1. Category (cat), Subcategory (subcat), Maintenance (maintenance)
    - Rule: Remove unwanted leading/trailing spaces.
    - Expectation: No extra spaces in cat, subcat, or maintenance columns.

 2. Maintenance values
    - Rule: Only 'Yes' or 'No' values are expected.
    - Expectation: No other values in maintenance column.

 3. Category values
    - Rule: Only expected categories: 'Accessories', 'Bikes', 'Clothing', 'Components'.
    - Expectation: No other values in cat column.

********************************************************************************************/


--------------------------------------------------------
-- 1. Check for unwanted spaces in cat, subcat, maintenance
--    Expectation: No records should be returned
--------------------------------------------------------
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);


--------------------------------------------------------
-- 2. Profile distinct maintenance values
--    Purpose: Ensure only 'Yes' or 'No' values exist
--------------------------------------------------------
SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;


--------------------------------------------------------
-- 3. Profile distinct category values
--    Purpose: Check all unique categories in Bronze
--------------------------------------------------------
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;
-- Expected: Accessories, Bikes, Clothing, Components


--------------------------------------------------------
-- 4. Insert data into Silver layer
--------------------------------------------------------
INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;


--------------------------------------------------------
-- 5. Sample data inspection in Silver
--------------------------------------------------------
SELECT TOP 50 *
FROM silver.erp_px_cat_g1v2;
