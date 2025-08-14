/*
========================================================================
Stored Procedure: Load Gold Layer (Silver -> Gold)
========================================================================
Script Purpose:
	This stored procedure loads data into the 'gold' schema from
	silver schema. It performs the following actions:
	- Truncates the gold tables before loading data
	- Processes and standardizes the data from the silver layer
	- Inserts data into gold tables
Usage Example:
	EXEC gold.load_gold;
========================================================================
*/

CREATE OR ALTER PROCEDURE gold.load_gold AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=================================================================================';
		PRINT 'Loading Gold Layer';
		PRINT '=================================================================================';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: gold.geo_codes';
		TRUNCATE TABLE gold.geo_codes;

		PRINT '>> Inserting Data Into: gold.geo_codes';
		INSERT INTO gold.geo_codes(
			geo_level,
			state_ansi,
			county_ansi,
			state,
			area_name)
		SELECT
			geo_level,
			state_ansi,
			county_ansi,
			state,
			area_name
		FROM silver.geo_codes;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: gold.population';
		TRUNCATE TABLE gold.population;

		PRINT '>> Inserting Data Into: gold.population';
		INSERT INTO gold.population(
			state_ansi,
			county_ansi,
			rural_urban_code_2013,
			population_1990,
			population_2000,
			population_2010,
			population_2020)
		SELECT
			state_ansi,
			county_ansi,
			rural_urban_code_2013,
			population_1990,
			population_2000,
			population_2010,
			population_2020
		FROM silver.population_estimates_trimmed;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: gold.ag_codes';
		TRUNCATE TABLE gold.population;

		PRINT '>> Inserting Data Into: gold.ag_codes';
		INSERT INTO gold.ag_codes(
			state_ansi,
			ag_district_code,
			ag_district)
		SELECT DISTINCT
			state_ansi,
			ag_district_code,
			ag_district
		FROM silver.bee_colonies_county_column_subset;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';


		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: gold.bee_colonies';
		TRUNCATE TABLE gold.bee_colonies;

		PRINT '>> Inserting Data Into: gold.bee_colonies';
		INSERT INTO gold.bee_colonies(
			state_ansi,
			county_ansi,
			ag_district_code)
		SELECT DISTINCT
			state_ansi,
			county_ansi,
			ag_district_code
		FROM silver.bee_colonies_county_column_subset;

		UPDATE gold.bee_colonies 
		SET colonies_2002 = (
								SELECT 
								value 
								FROM silver.bee_colonies_county_column_subset b
								WHERE gold.bee_colonies.state_ansi = b.state_ansi 
								AND gold.bee_colonies.county_ansi = b.county_ansi 
								AND year = 2002);

		UPDATE gold.bee_colonies 
		SET colonies_2007 = (
								SELECT 
								value 
								FROM silver.bee_colonies_county_column_subset b
								WHERE gold.bee_colonies.state_ansi = b.state_ansi 
								AND gold.bee_colonies.county_ansi = b.county_ansi 
								AND year = 2007);

		UPDATE gold.bee_colonies 
		SET colonies_2012 = (
								SELECT 
								value 
								FROM silver.bee_colonies_county_column_subset b
								WHERE gold.bee_colonies.state_ansi = b.state_ansi 
								AND gold.bee_colonies.county_ansi = b.county_ansi 
								AND year = 2012);

		UPDATE gold.bee_colonies 
		SET colonies_2017 = (
								SELECT 
								value 
								FROM silver.bee_colonies_county_column_subset b
								WHERE gold.bee_colonies.state_ansi = b.state_ansi 
								AND gold.bee_colonies.county_ansi = b.county_ansi 
								AND year = 2017);

		UPDATE gold.bee_colonies 
		SET colonies_2002 = (
								SELECT 
								value 
								FROM silver.bee_colonies_state_column_subset b 
								WHERE gold.bee_colonies.state_ansi = b.state_ansi 
								AND gold.bee_colonies.county_ansi = b.county_ansi 
								AND year = 2002) 
		WHERE colonies_2002 IS NULL;

		UPDATE gold.bee_colonies 
		SET colonies_2007 = (
								SELECT 
								value 
								FROM silver.bee_colonies_state_column_subset b 
								WHERE gold.bee_colonies.state_ansi = b.state_ansi 
								AND gold.bee_colonies.county_ansi = b.county_ansi 
								AND year = 2007) 
		WHERE colonies_2007 IS NULL;

		UPDATE gold.bee_colonies 
		SET colonies_2012 = (
								SELECT 
								value 
								FROM silver.bee_colonies_state_column_subset b 
								WHERE gold.bee_colonies.state_ansi = b.state_ansi 
								AND gold.bee_colonies.county_ansi = b.county_ansi 
								AND year = 2012) 
		WHERE colonies_2012 IS NULL;

		UPDATE gold.bee_colonies 
		SET colonies_2017 = (
								SELECT 
								value 
								FROM silver.bee_colonies_state_column_subset b 
								WHERE gold.bee_colonies.state_ansi = b.state_ansi 
								AND gold.bee_colonies.county_ansi = b.county_ansi 
								AND year = 2017) 
		WHERE colonies_2017 IS NULL;
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
