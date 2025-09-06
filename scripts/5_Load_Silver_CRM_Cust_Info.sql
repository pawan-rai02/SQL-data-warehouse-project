/********************************************************************************************
 Script Name : Load_Silver_CRM_Cust_Info.sql
 Purpose     : Cleanse and standardize CRM customer data from bronze to silver layer.
               - Remove duplicates (retain most recent by cst_create_date)
               - Eliminate null primary keys
               - Standardize categorical values
               - Trim unwanted spaces
********************************************************************************************
 WARNING:
   1. This script overwrites data in silver.crm_cust_info by inserting cleansed records. 
   2. Ensure silver.crm_cust_info is empty or truncated before execution.
   3. Transformation rules:
        - cst_material_status: 'S' -> 'Single', 'M' -> 'Married', else 'n/a'
        - cst_gndr           : 'F' -> 'Female', 'M' -> 'Male', else 'n/a'
********************************************************************************************/

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date
)
SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname)  AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
        ELSE 'n/a' 
    END AS cst_material_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a' 
    END AS cst_gndr,
    cst_create_date
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rnk
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t
WHERE rnk = 1;
