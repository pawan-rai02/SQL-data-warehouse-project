/********************************************************************************************
 Script Name : Data_Quality_Checks_CRM_Cust_Info.sql
 Purpose     : Perform data quality checks on bronze.crm_cust_info table.
               - Validate primary key uniqueness & nulls
               - Identify duplicates (retain latest based on cst_create_date)
               - Standardize & check categorical values
               - Detect unwanted spaces in text fields
********************************************************************************************
 WARNING:
   1. These checks assume `cst_id` is the PRIMARY KEY.
   2. If any rows are returned, data quality issues exist and must be fixed 
      before loading into the silver layer.
********************************************************************************************/

-- ============================
-- 1. Check for nulls or duplicates in primary key (Expected: No Results)
-- ============================
SELECT 
    cst_id,  
    COUNT(*) AS cnt
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- ============================
-- 2. Identify duplicate/invalid records (retain latest by cst_create_date)
-- ============================
SELECT *
FROM (
    SELECT 
        *, 
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rnk
    FROM bronze.crm_cust_info
) t
WHERE rnk > 1 OR cst_id IS NULL;


-- ============================
-- 3. Data standardization & consistency checks
-- ============================
SELECT DISTINCT cst_gndr FROM bronze.crm_cust_info;
SELECT DISTINCT cst_material_status FROM bronze.crm_cust_info;


-- ============================
-- 4. Check for unwanted leading/trailing spaces (Expected: No Results)
-- ============================
SELECT cst_firstname 
FROM bronze.crm_cust_info 
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname 
FROM bronze.crm_cust_info 
WHERE cst_lastname != TRIM(cst_lastname);
