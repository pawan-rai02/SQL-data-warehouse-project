/********************************************************************************************
 Script Name : DQ_Checks_silver_erp_cust_az12.sql
 Purpose     : Perform data quality validation and standardization checks on silver.erp_cust_az12.

 Checks Performed :
   1. Out-of-range Birthdate (bdate)
      - Rule: bdate should not be greater than the current date.
      - Expectation: No records returned.

   2. Gender (gen) Standardization and Consistency
      - Rule: gen should only contain standardized values: 'Male', 'Female', or 'n/a'.
      - Expectation: Only these values are present after transformation.

   3. Sample Data Inspection
      - Purpose: Inspect first 50 records for quick validation.
********************************************************************************************/


--------------------------------------------------------
-- 1. Out-of-range birthdate check
--    Expectation: No records should be returned
--------------------------------------------------------
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();


--------------------------------------------------------
-- 2. Profile distinct gender values
--    Purpose: Check all variations in gender column
--------------------------------------------------------
SELECT DISTINCT gen
FROM silver.erp_cust_az12;


--------------------------------------------------------
-- 3. Gender standardization logic (validation)
--    Expectation: Only 'Male', 'Female', or 'n/a' values should appear
--------------------------------------------------------
SELECT DISTINCT 
    gen,
    CASE 
        WHEN UPPER(LTRIM(RTRIM(gen))) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(LTRIM(RTRIM(gen))) IN ('M', 'MALE')   THEN 'Male'
        ELSE 'n/a'
    END AS standardized_gen
FROM silver.erp_cust_az12;


--------------------------------------------------------
-- 4. Sample data inspection
--    Purpose: View top 50 records for quick validation
--------------------------------------------------------
SELECT TOP 50 *
FROM silver.erp_cust_az12;
