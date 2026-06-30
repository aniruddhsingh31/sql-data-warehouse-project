CREATE database IF NOT exists DATAWAREHOUSE;
-- 1. Create the database for the Raw Staging Layer
CREATE DATABASE IF NOT EXISTS dw_bronze;

-- 2. Create the database for the Cleaned Master Layer
CREATE DATABASE IF NOT EXISTS dw_silver;

-- 3. Create the database for the Analytical View Layer
CREATE DATABASE IF NOT EXISTS dw_gold;

CREATE TABLE dw_bronze.crm_cust_info(
cst_id VARCHAR(50),
cst_key VARCHAR (50),
cst_firstname VARCHAR (50),
cst_lastname VARCHAR (50),
cst_marital_status VARCHAR (50),
cst_gndr VARCHAR (50),
cst_create_date VARCHAR(50)
);
DROP TABLE dw_bronze.crm_cust_info;

CREATE TABLE dw_bronze.crm_prd_info(
prd_id INT,
prd_key VARCHAR (50),
prd_nm VARCHAR (50),
prd_cost INT,
prd_line VARCHAR (50),
prd_start_dt DATETIME,
prd_end_dt DATETIME
);

CREATE TABLE dw_bronze.crm_sales_details(
sls_ord_num VARCHAR (50),
sls_prd_key VARCHAR (50),
sls_cust_id INT,
sls_order_dt INT,
sls_ship_dt INT,
sls_due_dt INT,
sls_sales INT,
sls_quantity INT,
sls_price INT
);

CREATE TABLE dw_bronze.erp_loc_a101(
	cid VARCHAR (50),
    cntry varchar(50)
);

CREATE TABLE dw_bronze.erp_cust_az12(
	cid VARCHAR (50),
    bdate DATE,
    gen VARCHAR (50)
);

CREATE TABLE dw_bronze.erp_px_cat_g1v2(
id VARCHAR (50),
cat VARCHAR (50),
subcat VARCHAR (50),
maintenance VARCHAR (50)
);

SELECT * FROM crm_cust_info;

LOAD DATA INFILE 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\cust_info.csv'
INTO TABLE dw_bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'              
LINES TERMINATED BY '\r\n'   
IGNORE 1 ROWS;               

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE dw_bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


DROP TABLE IF EXISTS dw_bronze.crm_cust_info;

CREATE TABLE dw_bronze.crm_cust_info (
    cst_id VARCHAR(50),               
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),   
    cst_gndr VARCHAR(50),
    cst_create_date VARCHAR(50)       
);



SET @@session.sql_mode = '';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE dw_bronze.crm_cust_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT * FROM crm_cust_info;
SELECT count(*) FROM crm_cust_info;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE dw_bronze.crm_prd_info
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE dw_bronze.crm_sales_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT * FROM crm_prd_info;
SELECT * FROM crm_sales_details;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
INTO TABLE dw_bronze.erp_cust_az12
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE dw_bronze.erp_loc_a101
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE dw_bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

------ SILVER TABELE

SELECT cst_id,COUNT(*)
FROM crm_cust_info
GROUP BY cst_id
HAVING COUNT(*)>1 OR cst_id is NULL;
