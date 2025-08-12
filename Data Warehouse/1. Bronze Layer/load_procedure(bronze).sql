/*
========================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
========================================================================
Script Purpose:
	This stored procedure loads data into the 'bronze' schema from
	external CSV files. It performs the following actions:
	- Truncates the bronze tables before loading data
	- Uses the 'BULK INSERT' command to load data from csv files
	  to bronze tables
Parameters:
	None.
	This stored procedure does not accept any parameters or return any values.

Usage Example:
	EXEC bronze.load_bronze;
========================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=================================================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '=================================================================================';


		PRINT '---------------------------------------------------------------------------------';
		PRINT 'Loading Source Tables';
		PRINT '---------------------------------------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.bee_colonies_county_column_subset';
		TRUNCATE TABLE bronze.bee_colonies_county_column_subset;

		PRINT '>> Inserting Data Into: bronze.bee_colonies_county_column_subset';
		BULK INSERT bronze.bee_colonies_county_column_subset
		FROM 'C:\Users\Mitch\Desktop\Practice Projects\Honey Bee Analysis\bee_colonies_county_column_subset.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';
		

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.bee_colonies_state_column_subset';
		TRUNCATE TABLE bronze.bee_colonies_state_column_subset;

		PRINT '>> Inserting Data Into: bronze.bee_colonies_state_column_subset';
		BULK INSERT bronze.bee_colonies_state_column_subset
		FROM 'C:\Users\Mitch\Desktop\Practice Projects\Honey Bee Analysis\bee_colonies_state_column_subset.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '>> ------------------------';
		

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.population_estimates_trimmed';
		TRUNCATE TABLE bronze.population_estimates_trimmed;

		PRINT '>> Inserting Data Into: bronze.population_estimates_trimmed';
		BULK INSERT bronze.population_estimates_trimmed
		FROM 'C:\Users\Mitch\Desktop\Practice Projects\Honey Bee Analysis\population_estimates_trimmed.csv'
		WITH (
			FORMAT = 'CSV',
			FIELDQUOTE = '"',
			FIRSTROW = 2);
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