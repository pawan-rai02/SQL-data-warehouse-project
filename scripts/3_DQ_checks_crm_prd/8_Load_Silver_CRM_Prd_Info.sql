/********************************************************************************************
 Script Name : Load_Silver_CRM_Prd_Info.sql
 Purpose     : Create and load the Silver table crm_prd_info from Bronze layer with cleansing 
               and standardization applied.
 
 Description :
   - Creates silver.crm_prd_info table (if not exists).
   - Truncates Silver table before load (full refresh).
   - Cleans and transforms data from bronze.crm_prd_info:
        * Derives cat_id from prd_key.
        * Standardizes prd_line values (M, R, S, T -> descriptive names).
        * Sets missing prd_cost to 0.
        * Ensures start_dt is cast to DATE.
        * Derives end_dt as (next start_dt - 1).
   - Adds ingestion timestamp column (dwh_create_date).

 WARNING :
   - This script truncates the target Silver table before inserting.
   - Ensure no downstream processes depend on existing Silver data 
     when running this script.
********************************************************************************************/

-- Drop and recreate Silver table
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,
    cat_id          NVARCHAR(50),
    prd_key         NVARCHAR(50),
    prd_nm          NVARCHAR(50),
    prd_cost        INT,
    prd_line        NVARCHAR(50),
    prd_start_dt    DATE,
    prd_end_dt      DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);

-- Full refresh: remove old data
TRUNCATE TABLE silver.crm_prd_info;

-- Insert cleansed & standardized data from Bronze
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    -- cat_id derived from first 5 chars of prd_key (replace '-' with '_')
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

    -- prd_key standardized: take substring after position 7
    SUBSTRING(prd_key, 7, LEN(prd_key))         AS prd_key,

    prd_nm,

    -- Default cost to 0 if null
    ISNULL(prd_cost, 0)                         AS prd_cost,

    -- Map short codes to descriptive product lines
    CASE UPPER(TRIM(prd_line)) 
         WHEN 'M' THEN 'Mountain'
         WHEN 'R' THEN 'Road'
         WHEN 'S' THEN 'Other sales'
         WHEN 'T' THEN 'Touring'
         ELSE 'n/a'
    END                                        AS prd_line,

    -- Start date cast to DATE
    CAST(prd_start_dt AS DATE)                 AS prd_start_dt,

    -- End date = (next start date - 1) within same prd_key
    CAST(LEAD(prd_start_dt) 
            OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) 
                                             AS prd_end_dt
FROM bronze.crm_prd_info;
