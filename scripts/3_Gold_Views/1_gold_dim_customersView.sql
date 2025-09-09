/********************************************************************************************
 VIEW NAME   : gold.dim_customers
 PURPOSE     : Customer dimension table for reporting and analytics.
 NOTES       :
   - Generates a surrogate primary key using ROW_NUMBER().
   - CRM (silver.crm_cust_info) is the master source for most attributes.
   - Gender is taken from CRM; if 'n/a', falls back to ERP data.
   - Country information comes from ERP location table.
********************************************************************************************/

CREATE VIEW gold.dim_customers AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id)   AS customer_key,     -- surrogate primary key
    ci.cst_id                             AS customer_id,
    ci.cst_key                            AS customer_number,
    ci.cst_firstname                      AS first_name,
    ci.cst_lastname                       AS last_name,
    la.cntry                              AS country,
    ci.cst_material_status                AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' 
            THEN ci.cst_gndr              -- crm is the master
        ELSE COALESCE(ca.gen, 'n/a')
    END                                   AS gender,
    ca.bdate                              AS birthdate,
    ci.cst_create_date                    AS create_date
FROM silver.crm_cust_info AS ci

LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 AS la
    ON la.cid = ci.cst_key;



---------------------------------------
------------------------------------
/*
select distinct
ci.cst_gndr,
ca.gen,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr --CRM is the master
else coalesce(ca.gen, 'n/a')
end gndr

from silver.crm_cust_info ci
left join silver.erp_cust_az12 ca
on ca.cid = ci.cst_key
order by 1,2
--treat crm table as master

*/