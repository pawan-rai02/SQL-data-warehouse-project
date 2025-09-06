/********************************************************************************************
 Script Name : DQ_Checks_Silver_CRM_Prd_Info.sql
 Purpose     : Validate data quality of silver.crm_prd_info after cleansing and transformations.
 
 Checks Performed :
   1. Primary Key integrity (nulls/duplicates in prd_id).
   2. Text quality (leading/trailing spaces in prd_nm).
   3. Numeric validation (nulls or negative values in prd_cost).
   4. Data standardization (distinct prd_line values).
   5. Date consistency (no overlaps, start < end).
   6. Sample inspection (review loaded data).
 
 Expectations :
   - All checks should return no rows, except distinct prd_line (for manual review).
   - Final SELECT is for sampling only.
 
 WARNING :
   - This script only validates data. 
   - Any issues found must be resolved in the Bronze -> Silver load logic.
********************************************************************************************/

--------------------------------------------
-- 1. Primary Key Integrity
-- Expectation : prd_id should be unique and not null
--------------------------------------------
SELECT
    prd_id,
    COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;


--------------------------------------------
-- 2. Text Quality Checks
-- Expectation : product name (prd_nm) should not contain unwanted spaces
--------------------------------------------
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


--------------------------------------------
-- 3. Numeric Validation
-- Expectation : prd_cost must be >= 0 and not null
--------------------------------------------
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


--------------------------------------------
-- 4. Data Standardization & Consistency
-- Expectation : prd_line should only contain standardized values
--------------------------------------------
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;


--------------------------------------------
-- 5. Date Consistency Checks
-- Logic :
--   - start date cannot be null
--   - start date < end date
--   - no overlapping ranges for same prd_key
-- Expectation : no results
--------------------------------------------
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt IS NULL
   OR (prd_end_dt IS NOT NULL AND prd_start_dt > prd_end_dt);


--------------------------------------------
-- 6. Sample Data Inspection
-- Purpose : manual spot check after load
--------------------------------------------
SELECT TOP 50 *
FROM silver.crm_prd_info;
