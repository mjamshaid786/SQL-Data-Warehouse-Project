
-- AFTER COMBINING TABLES CHECKING IF THE PRIMARY KEY HAVE ANY DUPLICATES
SELECT customer_id, COUNT(*)
FROM
	(SELECT 
		ci.customer_id,
		ci.customer_key,
		ci.customer_firstname,
		ci.customer_lastname,
		ci.customer_marital_status,
		ci.customer_gender,
		ci.customer_create_date,
		ca.birth_date,
		ca.gender,
		cl.country
	FROM silver.crm_customer_info AS ci
	LEFT JOIN silver.erp_cust_az12 AS ca
	ON		  ci.customer_key = ca.cid
	LEFT JOIN silver.erp_locations_a101 AS cl
	ON		  ci.customer_key = cl.cid)AS inner_query
GROUP BY customer_id
HAVING COUNT(*) > 1
;
--==================================================================
--			GENDER CONFLICTION
--==================================================================
SELECT DISTINCT

	ci.customer_gender,
	ca.gender,
	CASE
		WHEN ci.customer_gender != 'n/a' THEN ci.customer_gender
		ELSE COALESCE(ca.gender, 'n/a')
	END AS gender
FROM silver.crm_customer_info AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
ON		  ci.customer_key = ca.cid
LEFT JOIN silver.erp_locations_a101 AS cl
ON		  ci.customer_key = cl.cid

ORDER BY 1, 2
;

--==================================================================
--			GENDER CONFLICTION
--==================================================================
