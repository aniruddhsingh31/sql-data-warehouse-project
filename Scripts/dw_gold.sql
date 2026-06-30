CREATE VIEW dw_gold.dim_customers as
SELECT
ROW_NUMBER () OVER (order by cst_id) as customer_key,
cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as first_name,
ci.cst_lastname as last_name,
la.cntry as country,
ci.cst_marital_status as marital_status,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	ELSE COALESCE(ca.gen,'n/a')
END as gender,
ca.bdate as birthdate,
ci.cst_create_date as create_date
FROM crm_cust_info ci
LEFT JOIN erp_cust_az12 ca
ON ci.cst_key=ca.cid
LEFT JOIN erp_loc_a101 la
ON ci.cst_key = la.cid;

select * FROM erp_loc_a101 ;

SELECT DISTINCT gender FROM dw_gold.dim_customers;

DROP VIEW dw_gold.dim_products;
CREATE VIEW dw_gold.dim_products AS
SELECT 
	ROW_NUMBER () OVER (ORDER BY pn.prd_start_dt,pn.prd_key) as product_key,
	pn.prd_id as product_id,
    pn.prd_key as product_number,
    pn.prd_nm as  product_name,
	pn.cat_id as category_id,
    pc.cat as category,
    pc.subcat as subcategory,
	pc.maintenance,
	pn.prd_cost AS cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date
from crm_prd_info pn
LEFT JOIN dw_silver.erp_px_cat_g1v2 pc
ON pn.cat_id =pc.id
WHERE prd_end_dt IS NULL; -- TO filter out the historical orders

SELECT * FROM dw_gold.dim_products;

DROP VIEW dw_gold.fact_sales;
CREATE VIEW dw_gold.fact_sales AS 
SELECT 
	sd.sls_ord_num as order_number,
    pr.product_key,
    cu.customer_key,
	sd.sls_order_dt as order_date,
	sd.sls_ship_dt as shipping_date,
	sd.sls_due_dt as due_date,
	sd.sls_sales as sales_amount,
	sd.sls_quantity as sales_quantity,
	sd.sls_price
FROM crm_sales_details sd
LEFT JOIN dw_gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN dw_gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id;

SELECT * FROM dw_gold.fact_sales;
SELECT * FROM dw_gold.dim_customers;