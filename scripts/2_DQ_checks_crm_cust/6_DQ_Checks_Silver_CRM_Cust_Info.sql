/********************************************************************************************
 Script Name : DQ_Checks_Silver_CRM_Cust_Info.sql
 Purpose     : Perform data quality checks on silver.crm_cust_info table.
               - Validate primary key uniqueness & nulls
               - Detect duplicates (retain latest by cst_create_date)
               - Verify standardization of categorical values
               - Detect unwanted leading/trailing spaces
********************************************************************************************
 WARNING:
   1. These checks assume cst_id is the PRIMARY KEY.
   2. If any rows are returned, data quality issues exist and must be resolved.
********************************************************************************************/

-- =========================================================
-- 1. Check for nulls or duplicates in primary key (Expected: No Results)
-- =========================================================
SELECT 
    cst_id,
    COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- =========================================================
-- 2. Identify duplicate or invalid records (Expected: No Results)
--    Retain only the most recent record based on cst_create_date
-- =========================================================
SELECT *
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rnk
    FROM silver.crm_cust_info
) t
WHERE rnk > 1 OR cst_id IS NULL;


-- =========================================================
-- 3. Data standardization & consistency checks
-- =========================================================
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;
SELECT DISTINCT cst_material_status FROM silver.crm_cust_info;


-- =========================================================
-- 4. Check for unwanted spaces (Expected: No Results)
-- =========================================================
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


-- =========================================================
-- 5. Final Data Verification (Optional: Inspect Sample Data)
-- =========================================================
SELECT * 
FROM silver.crm_cust_info;
