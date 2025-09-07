/********************************************************************************************
 Script Name : Load_silver_erp_cust_az12.sql
 Purpose     : Standardize and load data from bronze.erp_cust_az12 into silver.erp_cust_az12.

 Transformation Rules :
   1. Customer ID (cid)
      - Rule: If cid starts with 'NAS%', remove the prefix 'NAS' and retain the remaining part.
      - Expectation: All customer IDs in silver are stored without the 'NAS' prefix.

   2. Birthdate (bdate)
      - Rule: If bdate is greater than the current date, set it to NULL.
      - Expectation: No future dates are present in silver.

   3. Gender (gen)
      - Rule: Standardize gender values as follows:
            'F', 'FEMALE', 'female' -> 'Female'
            'M', 'MALE', 'male'     -> 'Male'
            Any other value (NULL, blanks, invalids) -> 'n/a'
      - Expectation: Only 'Male', 'Female', or 'n/a' values are present in silver.

********************************************************************************************/


--------------------------------------------------------
-- Insert transformed data into Silver layer
--------------------------------------------------------
INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid,

    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END AS bdate,

    CASE 
        WHEN UPPER(LTRIM(RTRIM(gen))) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(LTRIM(RTRIM(gen))) IN ('M', 'MALE')   THEN 'Male'
        ELSE 'n/a'
    END AS gen
FROM bronze.erp_cust_az12;
