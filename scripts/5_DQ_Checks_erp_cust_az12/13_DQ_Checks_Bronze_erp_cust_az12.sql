/********************************************************************************************
 Script Name : DQ_Checks_Bronze_erp_cust_az12.sql
 Purpose     : Perform data quality validation and standardization on bronze.erp_cust_az12 table.

 Checks Performed :
   1. Out-of-range Birthdate (bdate).
      - Rule: bdate should not be greater than current date.
      - Expectation: No records returned.
   
   2. Gender (gen) Standardization and Consistency.
      - Rule: gen should only contain standardized values: 'Male', 'Female', or 'n/a'.
      - Expectation: Only these values are present after transformation.

********************************************************************************************/


--------------------------------------------------------
-- 1. Out of range birthdate check
--    Expectation: No records should be returned
--------------------------------------------------------
SELECT DISTINCT
    bdate
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE();


--------------------------------------------------------
-- 2. Profile distinct gender values
--    Purpose: Identify variations in raw gender data
--------------------------------------------------------
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;


--------------------------------------------------------
-- 3. Gender standardization logic
--    Expectation after transformation:
--      'F', 'FEMALE', 'female' -> 'Female'
--      'M', 'MALE', 'male'     -> 'Male'
--      Any other value (NULL, blanks, others) -> 'n/a'
--------------------------------------------------------
SELECT DISTINCT 
    gen,
    CASE 
        WHEN UPPER(LTRIM(RTRIM(gen))) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(LTRIM(RTRIM(gen))) IN ('M', 'MALE')   THEN 'Male'
        ELSE 'n/a'
    END AS standardized_gen
FROM bronze.erp_cust_az12;


