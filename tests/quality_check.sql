-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Result

--STEP 1: CHECKING DUPLICATES IN PRIMARY KEY
SELECT 
	customer_id,
	COUNT(*)
FROM bronze.crm_customer_info
GROUP BY customer_id
HAVING COUNT(*) > 1 OR customer_id IS NULL
;
===========================================================================================
-- STEP 2: REMOVING DUPLICATES FROM PRIMARY KEY

SELECT
*
FROM

(SELECT
*,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_create_date DESC) AS flag_last
FROM bronze.crm_customer_info
)AS inner_query
WHERE flag_last = 1 

=============================================================================================
SELECT * FROM bronze.crm_customer_info;
--STEP 3: CHECKING UNWANTED SPACES IN STRING TYPE TABLES

SELECT customer_gender
FROM bronze.crm_customer_info
WHERE customer_gender != TRIM(customer_gender)

==============================================================================================
--SELECT * FROM bronze.crm_customer_info;
-- STEP 4: GETTING THE CLEAN COLUMNS AFTER REMOVING DUPLICATES FROM PRIMARY KEY AND
-- UN WANTED SPACES FROM STRING COLUMNS.
SELECT
	customer_id,
	customer_key,
	TRIM(customer_firstname) AS customer_firstname,
	TRIM(customer_lastname) AS customer_lastname,
	customer_marital_status,
	customer_gender,
	customer_create_date
FROM

(SELECT
*,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_create_date DESC) AS flag_last
FROM bronze.crm_customer_info
)AS inner_query
WHERE flag_last = 1

==============================================================================================
--STEP 5: CHECKING DISTINCT VALUES FOR MARITAL STATUS AND GENDER AND REPLACING WITH FULL NAME

SELECT 
	DISTINCT customer_marital_status
FROM bronze.crm_customer_info

;
-- SEE MAIN DATA CLEANISING QUERY TO SEE IMPLEMENTAION OF THIS

===============================================================================================
-- IF ALL COULMNS ARE OK THEN INSERT DATA INTO DISIRED TABLE
===============================================================================================
