INSERT INTO dw_silver.crm_cust_info (
    cst_id, 
    cst_key, 
    cst_firstname, 
    cst_lastname, 
    cst_marital_status,
    cst_gndr, 
    cst_create_date
)
SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) as cst_firstname,
TRIM(cst_lastname) as cst_lastname,
CASE 
    WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'   
    WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married' 
    ELSE 'n/a'
END as cst_marital_status,

CASE 
    WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'   
    WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' 
    ELSE 'n/a'
END as cst_gndr,
-- If the date is already YYYY-MM-DD
CASE 
    WHEN TRIM(cst_create_date) = '' OR cst_create_date IS NULL THEN NULL
    ELSE CAST(TRIM(cst_create_date) AS DATE)

END as cst_create_date
FROM(
select *,
row_number() over(partition by cst_id order by  cst_create_date DESC) flasg_last
FROM crm_cust_info)t
WHERE flasg_last =1;

select * FROM crm_cust_info;

CREATE TABLE dw_silver.crm_cust_info (
    cst_id VARCHAR(50),
    cst_key VARCHAR(50) NOT NULL,
    cst_firstname VARCHAR(100),
    cst_lastname VARCHAR(100),
    cst_marital_status VARCHAR(20),
    cst_gndr VARCHAR(10),
    cst_create_date DATE
);
drop table dw_silver.crm_cust_info;
select * FROM crm_cust_info;
TRUNCATE TABLE crm_cust_info;


CREATE TABLE dw_silver.crm_prd_info (
prd_id INT,
cat_id VARCHAR (50),
prd_key VARCHAR(50),
prd_nm VARCHAR (200),
prd_cost INT,
prd_line VARCHAR (100),
prd_start_dt DATE,
prd_end_dt date
);

INSERT INTO dw_silver.crm_prd_info (
prd_id ,
cat_id,
prd_key,
prd_nm ,
prd_cost ,
prd_line ,
prd_start_dt ,
prd_end_dt 
)
select 
prd_id,
REPLACE(substring(prd_key,1,5),'-','_')as cat_id,
substring(prd_key,7,LENGTH(prd_key)) as prd_key,
prd_nm,
coalesce(prd_cost,0) as prd_cost,
CASE UPPER(TRIM(prd_line))
	WHEN  'M' THEN 'Mountain'
    WHEN  'R' THEN 'Road'
    WHEN  'T' THEN 'Touring'
    WHEN  'S' THEN 'Other Sales'
    ELSE 'n/a'
END as prd_line,
CAST(prd_start_dt AS DATE) as prd_start_dt,
CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-INTERVAL 1 DAY AS DATE) as prd_end_dt
from crm_prd_info ;

select * FROM dw_silver.crm_prd_info;
DROP TABLE dw_silver.crm_sales_details;

CREATE TABLE dw_silver.crm_sales_details (
sls_ord_num VARCHAR (50),
sls_prd_key VARCHAR (50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

INSERT INTO dw_silver.crm_sales_details (
sls_ord_num, 
sls_prd_key ,
sls_cust_id ,
sls_order_dt,
sls_ship_dt ,
sls_due_dt ,
sls_sales ,
sls_quantity ,
sls_price 
)
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0  OR LENGTH(sls_order_dt) != 8  THEN null
	ELSE CAST(sls_order_dt AS DATE)
END as sls_order_dt,

CASE WHEN sls_ship_dt = 0  OR LENGTH(sls_ship_dt) != 8  THEN null
	ELSE CAST(sls_ship_dt AS DATE)
END as sls_ship_dt,

CASE WHEN sls_due_dt = 0  OR LENGTH(sls_due_dt) != 8  THEN null
	ELSE CAST(sls_due_dt AS DATE)
END as sls_due_dt,

CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity*ABS(sls_price)
			THEN sls_quantity*ABS(sls_price)
     ELSE sls_sales
END as sls_sales,
sls_quantity,
CASE WHEN sls_price <=0 or sls_price is NULL 
			THEN sls_price = sls_sales/NULLIF(sls_quantity,0)
	ELSE sls_price
END as sls_price
	
FROM dw_bronze.crm_sales_details
;

USE dw_silver;
SELECT * FROm crm_sales_details;

CREATE TABLE dw_silver.erp_cust_az12(
cid VARCHAR(50),
bdate DATE,
gen VARCHAR (20)
);

INSERT INTO dw_silver.erp_cust_az12(cid,bdate,gen)

SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,length(cid))
	ELSE cid
END as cid_new,
CASE 
	WHEN bdate > CURDATE() THEN NULL
    ELSE bdate
END as bdate,
CASE
	WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
    WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
    ELSE 'n/a'
END as gen
FROM erp_cust_az12;

SELECT DISTINCT gen
FROM dw_silver.erp_cust_az12;

CREATE TABLE dw_silver.erp_loc_a101(
cid VARCHAR(50),
cntry VARCHAR (50)
);

SELECT * FROM dw_silver.erp_loc_a101;
INSERT INTO dw_silver.erp_loc_a101(cid,cntry)

SELECT 
REPLACE (cid,'-','') as cid,
CASE 
WHEN TRIM(cntry) = 'DE' THEN 'Germany'
WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
WHEN TRIM(cntry) = '' OR cntry is null THEN 'n/a'
ELSE TRIM(cntry)
END as cntry
FROM erp_loc_a101;

create TABLE dw_silver.erp_px_cat_g1v2(
id VARCHAR(20),
cat VARCHAR (30),
subcat VARCHAR (50),
maintenance VARCHAR(100)
);
INSERT INTO dw_silver.erp_px_cat_g1v2( id,cat,subcat,maintenance)

SELECT id,cat,subcat,maintenance
FROM erp_px_cat_g1v2;

SELECT * FROM dw_silver.erp_px_cat_g1v2;