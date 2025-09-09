/********************************************************************************************
 Script Name   : gold.fact_sales.sql
 Purpose       : Create a fact view for capturing sales transactions.
 
 Description   :
   - This view creates a sales fact table (gold.fact_sales).
   - Contains transactional measures such as sales amount, quantity, and price.
   - Joins sales details with product and customer dimensions to replace natural keys 
     with surrogate keys.
   - Represents business events (sales orders) at the line-item grain.
 
 Business Notes:
   - order_number is the transaction identifier (degenerate dimension).
   - product_key and customer_key link to corresponding dimension tables.
   - Measures include sales_amount, quantity, and price for analytical aggregations.
   - Fact table is usually large, growing over time, and queried for aggregations.
********************************************************************************************/


CREATE VIEW gold.fact_sales AS
SELECT
       sd.sls_ord_num   AS order_number,   -- order identifier (degenerate dimension)
       pr.product_key   AS product_key,    -- surrogate FK to dim_products
       cu.customer_key  AS customer_key,   -- surrogate FK to dim_customers
       sd.sls_order_dt  AS order_date,     
       sd.sls_ship_dt   AS shipping_date,  
       sd.sls_due_dt    AS due_date,       
       sd.sls_sales     AS sales_amount,   
       sd.sls_quantity  AS quantity,      
       sd.sls_price     AS price           
FROM   silver.crm_sales_details AS sd
       LEFT JOIN gold.dim_products AS pr
              ON sd.sls_prd_key = pr.product_number
       LEFT JOIN gold.dim_customers AS cu
              ON sd.sls_cust_id = cu.customer_id;



/*

Why this is a Fact View and not a Dimension View:

Nature of Data : A fact table stores business events or transactions (e.g., sales, payments, clicks).
A dimension table stores descriptive attributes (e.g., product details, customer info, location).
Here, fact_sales is storing each sales transaction (order line), which is an event.



Measures vs. Attributes : Fact tables contain measures (numeric values you can aggregate like SUM, AVG, COUNT).
Dimension tables contain attributes (textual/contextual details used for slicing and dicing).
sales_amount, quantity, and price are measures — clear signs of a fact table.



Foreign Keys : Fact tables store foreign keys to dimensions to provide context.
Dimension tables rarely have many-to-many links like this.
Here, product_key and customer_key link back to dimensions.

*/