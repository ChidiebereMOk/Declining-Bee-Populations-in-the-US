/*
========================================================================
DDL Script: Create Bronze Tables
========================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing
    tables if they already exist.
    Run this script to re-define the DDL structure of 'bronze' tables
========================================================================
*/

USE BeePopulations;

-- Data Definition Language - Defining layer, source system & table names
IF OBJECT_ID ('bronze.bee_colonies_county_column_subset', 'U') IS NOT NULL
    DROP TABLE bronze.bee_colonies_county_column_subset
CREATE TABLE bronze.bee_colonies_county_column_subset(
    year INT,
    geo_level NVARCHAR(50),
    state NVARCHAR(50),
    state_ansi INT,
    ag_district NVARCHAR(50),
    ag_district_code INT,
    county NVARCHAR(50),
    county_ansi INT,
    value NVARCHAR(50));

IF OBJECT_ID ('bronze.bee_colonies_state_column_subset', 'U') IS NOT NULL
    DROP TABLE bronze.bee_colonies_state_column_subset
CREATE TABLE bronze.bee_colonies_state_column_subset(
    year INT,
    geo_level NVARCHAR(50),
    state NVARCHAR(50),
    state_ansi INT,
    ag_district NVARCHAR(50),
    ag_district_code INT,
    county NVARCHAR(50),
    county_ansi INT,
    value NVARCHAR(50));

IF OBJECT_ID ('bronze.population_estimates_trimmed', 'U') IS NOT NULL
    DROP TABLE bronze.population_estimates_trimmed
CREATE TABLE bronze.population_estimates_trimmed(
    fipstxt INT,
    state NVARCHAR(50),
    area_name NVARCHAR(50),
    rural_urban_code_2013 NVARCHAR(50),
    population_1990 NVARCHAR(50),
    population_2000 NVARCHAR(50),
    population_2010 NVARCHAR(50),
    population_2020 NVARCHAR(50));
