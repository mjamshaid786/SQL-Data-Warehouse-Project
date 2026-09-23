TRUNCATE TABLE silver.crm_customer_info;
INSERT INTO silver.crm_customer_info(
	customer_id,
	customer_key,
	customer_firstname,
	customer_lastname,
	customer_marital_status,
	customer_gender,
	customer_create_date
)
SELECT
	customer_id,
	customer_key,
	--STEP 3
	TRIM(customer_firstname) AS customer_firstname,
	TRIM(customer_lastname) AS customer_lastname,
	--STEP 5
	CASE 
		WHEN UPPER(TRIM(customer_marital_status)) = 'M' THEN 'Married'
		WHEN UPPER(TRIM(customer_marital_status) )= 'S' THEN 'Single'
		ELSE 'n/a'
	END AS customer_marital_status,
	CASE 
		WHEN UPPER(TRIM(customer_gender)) = 'M' THEN 'Male'
		WHEN UPPER(TRIM(customer_gender)) = 'F' THEN 'Female'
		ELSE 'n/a'
	END AS customer_gender,
	customer_create_date
FROM
--STEP 2
(SELECT
*,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_create_date DESC) AS flag_last
FROM bronze.crm_customer_info
WHERE customer_id IS NOT NULL
)AS inner_query
WHERE flag_last = 1 
;
--================================================================================================
TRUNCATE TABLE silver.crm_products_info;
INSERT INTO silver.crm_products_info(
	product_id,
	product_category_id,
	product_key,
	product_name,
	product_cost,
	product_line,
	product_start_date,
	product_end_date	
)
SELECT 
	product_id,
	--Siplitting product_key into two sections, first 5 as category)id and matching it with erp_px_cat_g1v2 table for joining them later
	REPLACE(SUBSTRING(product_key, 1, 5), '-', '_') AS prd_cat_id,
	SUBSTRING(product_key, 7, LENGTH(product_key)) AS product_key,
	product_name,
	COALESCE(product_cost, 0) AS product_cost,

	CASE
		WHEN UPPER(TRIM(product_line)) = 'S' THEN 'Other Sales'
		WHEN UPPER(TRIM(product_line)) = 'R' THEN 'Road'
		WHEN UPPER(TRIM(product_line)) = 'T' THEN 'Touring'
		WHEN UPPER(TRIM(product_line)) = 'M' THEN 'Mountain'
		ELSE 'n/a'
	END AS product_line,
	CAST(product_start_date AS DATE) AS product_start_date,
	CAST(LEAD(product_start_date) OVER(PARTITION BY product_key ORDER BY product_start_date)- INTERVAL '1 day' AS DATE)  AS product_end_date
FROM bronze.crm_products_info
;

--================================================================================================
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details(
	sls_order_num,
	sls_product_id,
	sls_customer_id,
	sls_order_date,
	sls_ship_date,
	sls_due_date,
	sls_sales,
	sls_quantity,
	sls_price
)

SELECT
	sls_order_num,
	sls_product_id,
	sls_customer_id,
	CASE
		WHEN sls_order_date = 0 OR LENGTH(sls_order_date::text) != 8 THEN NULL
		ELSE TO_DATE(sls_order_date::text, 'YYYYMMDD')
	END AS sls_order_date,
		CASE
		WHEN sls_ship_date = 0 OR LENGTH(sls_ship_date::text) != 8 THEN NULL
		ELSE TO_DATE(sls_ship_date::text, 'YYYYMMDD')
	END AS sls_ship_date,
	CASE
		WHEN sls_due_date = 0 OR LENGTH(sls_due_date::text) != 8 THEN NULL
		ELSE TO_DATE(sls_due_date::text, 'YYYYMMDD')
	END AS sls_due_date,
	CASE
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * sls_price
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE
		WHEN sls_price IS NULL OR sls_price <= 0 
			THEN sls_sales / NULLIF(sls_quantity, 0)
		ELSE sls_price
	END AS sls_price
FROM bronze.crm_sales_details;

--================================================================================================
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12(cid, birth_date, gender)

SELECT
	CASE
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		ELSE cid
	END AS cid,
	CASE
		WHEN birth_date > CURRENT_TIMESTAMP THEN NULL
		ELSE birth_date
	END AS birth_date,
	CASE 
		WHEN UPPER(TRIM(gender)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gender)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END AS gender
	

FROM  bronze.erp_cust_az12;

--================================================================================================
TRUNCATE TABLE silver.erp_locations_a101;
INSERT INTO silver.erp_locations_a101(
	cid,
	country
)
SELECT
	REPLACE(cid, '-', '') AS cid,
	CASE
		WHEN country IS NULL OR TRIM(country) = '' THEN 'n/a' 
		WHEN TRIM(country) IN ('US', 'USA')  THEN 'United States'
		WHEN TRIM(country) = 'DE' THEN 'Germany'
		ELSE TRIM(country)
	END AS country
FROM bronze.erp_locations_a101;

--================================================================================================
TRUNCATE TABLE silver.erp_px_category_g1v2;
INSERT INTO silver.erp_px_category_g1v2(
	id, category, subcategory, maintenance
)

SELECT
	 id,
	 category,
	 subcategory,
	 maintenance
FROM bronze.erp_px_category_g1v2;
