--==================================================================
--			GOLD LAYER
--==================================================================

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
	ci.customer_id,
	ci.customer_key AS customer_number,
	ci.customer_firstname AS first_name,
	ci.customer_lastname AS last_name,
	cl.country,
	ci.customer_marital_status,
	CASE
		WHEN ci.customer_gender != 'n/a' THEN ci.customer_gender
		ELSE COALESCE(ca.gender, 'n/a')
	END AS gender,
	ca.birth_date,
	ci.customer_create_date
FROM silver.crm_customer_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON		  ci.customer_key = ca.cid
LEFT JOIN silver.erp_locations_a101 AS cl
ON		  ci.customer_key = cl.cid
;

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER()  OVER (ORDER BY pi.product_start_date, pi.product_key) AS product_key,
	pi.product_id,
	pi.product_key AS product_number,
	pi.product_name,
	pi.product_category_id,
	pc.category,
	pc.subcategory,
	pc.maintenance,
	pi.product_cost AS cost,
	pi.product_line,
	pi.product_start_date
FROM silver.crm_products_info AS pi
LEFT JOIN silver.erp_px_category_g1v2 AS pc
ON pi.product_category_id = pc.id
WHERE pi.product_end_date IS NULL --Filter out all historical data



CREATE VIEW gold.fact_sales AS
SELECT 
	sd.sls_order_num AS order_number,
	pr.product_key,
	cu.customer_key,
	sd.sls_order_date AS order_date,
	sd.sls_ship_date AS ship_date,
	sd.sls_due_date AS due_date,
	sd.sls_sales AS sales,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products AS pr
ON sd.sls_product_id = pr.product_number
LEFT JOIN gold.dim_customers AS cu
ON sd.sls_customer_id = cu.customer_id
