/*
========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
========================================================================
Script Purpose:
	This stored procedure loads data into the 'silver' schema from
	bronze schema. It performs the following actions:
	- Truncates the silver tables before loading data
	- Processes and standardizes the data from the bronze layer
	- Inserts data into silver tables
Usage Example:
	EXEC silver.load_silver;
========================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=================================================================================';
		PRINT 'Loading Silver Layer';
		PRINT '=================================================================================';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.population_estimates_trimmed';
		TRUNCATE TABLE silver.population_estimates_trimmed;

		PRINT '>> Inserting Data Into: silver.population_estimates_trimmed';
		INSERT INTO silver.population_estimates_trimmed(
			fipstxt,
			state,
			area_name,
			rural_urban_code_2013,
			population_1990,
			population_2000,
			population_2010,
			population_2020)
		SELECT
		fipstxt,
		state,
		area_name,
		rural_urban_code_2013,
		population_1990,
		population_2000,
		population_2010,
		population_2020
		FROM bronze.population_estimates_trimmed;

		UPDATE silver.population_estimates_trimmed 
		SET population_1990 = REPLACE(population_1990, ',','');
    
		UPDATE silver.population_estimates_trimmed 
		SET population_1990 = REPLACE(population_2000, ',','');

		UPDATE silver.population_estimates_trimmed 
		SET population_1990 = REPLACE(population_2010, ',','');

		UPDATE silver.population_estimates_trimmed 
		SET population_1990 = REPLACE(population_2020, ',','');

		UPDATE silver.population_estimates_trimmed 
		SET rural_urban_code_2013 = null 
		WHERE rural_urban_code_2013 = '';

		UPDATE silver.population_estimates_trimmed
		SET population_1990 = null
		WHERE population_1990 = '';

		UPDATE silver.population_estimates_trimmed
		SET population_2000 = null
		WHERE population_2000 = '';

		UPDATE silver.population_estimates_trimmed
		SET population_2010 = null
		WHERE population_2010 = '';

		UPDATE silver.population_estimates_trimmed
		SET population_2020 = null
		WHERE population_2020 = '';

		ALTER TABLE silver.population_estimates_trimmed
		DROP COLUMN geo_level;

		ALTER TABLE silver.population_estimates_trimmed
		ADD geo_level NVARCHAR(50);

		UPDATE silver.population_estimates_trimmed
		SET geo_level = null;

		UPDATE silver.population_estimates_trimmed
		SET geo_Level = 'STATE'
		WHERE (fipstxt%1000 = 0) AND (state != 'US');

		UPDATE silver.population_estimates_trimmed
		SET geo_Level = 'COUNTY'
		WHERE (fipstxt%1000 != 0)

		ALTER TABLE silver.population_estimates_trimmed
		DROP COLUMN state_ansi;

		ALTER TABLE silver.population_estimates_trimmed
		ADD state_ansi INT;

		ALTER TABLE silver.population_estimates_trimmed
		DROP COLUMN county_ansi;

		ALTER TABLE silver.population_estimates_trimmed
		ADD county_ansi INT;

		UPDATE silver.population_estimates_trimmed
		SET county_ansi = fipstxt%1000;

		UPDATE silver.population_estimates_trimmed
		SET state_ansi = floor(fipstxt/1000);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';



		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.geo_codes';
		TRUNCATE TABLE silver.geo_codes;

		PRINT '>> Inserting Data Into: silver.geo_codes';
		INSERT INTO silver.geo_codes(
			geo_level,
			state_ansi,
			county_ansi,
			state,
			area_name)
		SELECT DISTINCT
		geo_level,
		state_ansi,
		county_ansi,
		state,
		area_name
		FROM silver.population_estimates_trimmed;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table silver.bee_colonies_county_column_subset';
		TRUNCATE TABLE silver.bee_colonies_county_column_subset;

		PRINT 'Inserting Data Into: silver.bee_colonies_county_column_subset';
		INSERT INTO silver.bee_colonies_county_column_subset(
			year,
			geo_level,
			state,
			state_ansi,
			ag_district,
			ag_district_code,
			county,
			county_ansi,
			value)
		SELECT
			year,
			geo_level,
			state,
			state_ansi,
			ag_district,
			ag_district_code,
			county,
			county_ansi,
			value
		FROM bronze.bee_colonies_county_column_subset;

		UPDATE silver.bee_colonies_county_column_subset 
		SET county_ansi = null 
		WHERE county_ansi = '';

		UPDATE silver.bee_colonies_county_column_subset 
		SET value = null 
		WHERE value LIKE '%D%';

		UPDATE silver.bee_colonies_county_column_subset 
		SET value = REPLACE(value, ',','');

		UPDATE silver.bee_colonies_county_column_subset 
		SET county_ansi = (
		SELECT a.county_ansi 
		FROM silver.geo_codes a
		WHERE a.state_ansi = silver.bee_colonies_county_column_subset.state_ansi 
		AND a.area_name LIKE concat('%', bee_colonies_county_column_subset.county, '%')) 
		WHERE county_ansi IS NULL;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.bee_colonies_state_column_subset';
		TRUNCATE TABLE silver.bee_colonies_state_column_subset;

		PRINT '>> Inserting Data Into: silver.bee_colonies_state_column_subset';
		INSERT INTO silver.bee_colonies_state_column_subset(
			year,
			geo_level,
			state,
			state_ansi,
			ag_district,
			ag_district_code,
			county,
			county_ansi,
			value)
		SELECT
			year,
			geo_level,
			state,
			state_ansi,
			ag_district,
			ag_district_code,
			county,
			county_ansi,
			REPLACE(value,',','') AS value
		FROM bronze.bee_colonies_state_column_subset;

		UPDATE silver.bee_colonies_state_column_subset 
		SET ag_district_code = null 
		WHERE ag_district_code = '';

		UPDATE silver.bee_colonies_state_column_subset 
		SET county_ansi = 0 
		where county_ansi = '';

		UPDATE silver.bee_colonies_state_column_subset 
		SET value = replace(value, ',', '');
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';
		SET @batch_end_time = GETDATE();
		PRINT '=================================================================================';
		PRINT 'Loading Bronze Layer is Complete';
		PRINT '	- Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
	END TRY
	BEGIN CATCH
	PRINT '=================================================================================';
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
	PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
	PRINT 'ERROR MESSAGE' + CAST (ERROR_NUMBER() AS NVARCHAR);
	PRINT 'ERROR MESSAGE' + CAST (ERROR_STATE() AS NVARCHAR);
	PRINT '=================================================================================';
	END CATCH
END
