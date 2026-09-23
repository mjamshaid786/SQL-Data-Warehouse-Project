TRUNCATE TABLE bronze.erp_px_category_g1v2; --FOR AVOIDING DUPLICATE INSERTION
COPY bronze.erp_px_category_g1v2
FROM 'D:\SQL\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
WITH (
	FORMAT csv,
	HEADER true,
	DELIMITER ','
);

SELECT * FROM bronze.erp_px_category_g1v2;
