/********************************************************************************************
 Script Name : DQ_Checks_Bronze_CRM_Prd_Info.sql
 Purpose     : Run data quality checks on bronze.crm_prd_info to ensure readiness for promotion
               to Silver layer.
 
 Checks Performed :
   1. Primary Key integrity (nulls/duplicates in prd_id).
   2. Text quality (unwanted leading/trailing spaces in product name).
   3. Numeric validation (nulls or negative values in prd_cost).
   4. Data standardization (distinct values of prd_line for consistency).
   5. Date consistency (no overlaps in start/end dates, start < end).
 
 Expectations :
   - All checks should return no rows, except distinct prd_line (for manual review).
 
 WARNING :
   - This script does not fix issues, it only reports them.
   - Use findings to adjust ETL cleansing before Silver load.
********************************************************************************************/

--------------------------------------------
-- 1. Primary Key Integrity
-- Expectation : prd_id should be unique and not null
--------------------------------------------
SELECT
    prd_id,
    COUNT(*) AS cnt
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


--------------------------------------------
-- 2. Text Quality Checks
-- Expectation : product name (prd_nm) should not contain unwanted spaces
--------------------------------------------
SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


--------------------------------------------
-- 3. Numeric Validation
-- Expectation : prd_cost must be >= 0 and not null
--------------------------------------------
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


--------------------------------------------
-- 4. Data Standardization & Consistency
-- Expectation : prd_line values should belong to a known set 
-- (M, R, S, T) or be corrected in cleansing step
--------------------------------------------
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;


--------------------------------------------
-- 5. Date Consistency Checks
-- Logic :
--   - start date should not be null
--   - start date < end date
--   - no overlapping ranges for same product key
--   - if overlap detected, end date should align with 
--     (next start date - 1) using LEAD()
--------------------------------------------

-- a) Start date cannot be null or greater than end date
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt IS NULL
   OR (prd_end_dt IS NOT NULL AND prd_start_dt > prd_end_dt);

-- b) Overlap test using LEAD()
--    Expectation : current end date = (next start date - 1)
SELECT 
    prd_id,
    prd_key,
    prd_nm,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS expected_end_dt
FROM bronze.crm_prd_info
WHERE prd_end_dt IS NOT NULL;
