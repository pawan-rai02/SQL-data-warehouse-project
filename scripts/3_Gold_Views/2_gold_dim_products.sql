/********************************************************************************************
 Script Name   : gold.dim_products.sql
 Purpose       : Create a dimension view for product-related information.
 
 Description   :
   - This view creates a product dimension (gold.dim_products).
   - Adds a surrogate primary key (product_key) using ROW_NUMBER().
   - Joins CRM product info with ERP product category mappings.
   - Includes descriptive attributes of products for analysis.
   - Filters out historical records by excluding rows with prd_end_dt not null.
 
 Business Notes:
   - product_key is a surrogate key (unique, sequential).
   - product_number (prd_key) should be checked for uniqueness at source level.
   - Dimension table suitable for star-schema joins with fact tables.
********************************************************************************************/

CREATE VIEW gold.dim_products AS
SELECT
       ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,  -- surrogate PK
       pn.prd_id        AS product_id,       
       pn.prd_key       AS product_number,   
       pn.prd_nm        AS product_name,     
       pn.cat_id        AS category_id,      -- foreign key reference to category
       pc.cat           AS category,       
       pc.subcat        AS sub_category,     
       pc.maintenance   AS maintenance,      
       pn.prd_cost      AS cost,            
       pn.prd_line      AS product_line,     
       pn.prd_start_dt  AS start_date        
FROM   silver.crm_prd_info AS pn
       LEFT JOIN silver.erp_px_cat_g1v2 AS pc
              ON pn.cat_id = pc.id
WHERE  pn.prd_end_dt IS NULL;  -- exclude inactive/historical products
