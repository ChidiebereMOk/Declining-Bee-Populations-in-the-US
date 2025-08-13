/* 
This script creates a new database named 'BeePopulations' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three
schemas within the database: 'bronze', 'silver', and 'gold'.

WARNING:
Running this script will drop the entire 'BeePopulations' database if it exists.
All data in the database will be permanently deleted. Proceed with caution and
ensure you have proper backups before running the script.
*/
-- Create Database 'BeePopulations'
USE master;
GO

USE BeePopulations;
-- Drop and recreate database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'BeePopulations')

BEGIN
	ALTER DATABASE BeePopulations SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE BeePopulations;

CREATE DATABASE BeePopulations;

USE BeePopulations;
GO
-- Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
