/*
========================================================================
DDL Script: Create Silver Tables
========================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing
    tables if they already exist.
    Run this script to re-define the DDL structure of 'silver' tables
========================================================================
*/

USE BeePopulations;

-- Data Definition Language - Defining layer, source system & table names
IF OBJECT_ID ('silver.bee_colonies_county_column_subset', 'U') IS NOT NULL
    DROP TABLE silver.bee_colonies_county_column_subset
CREATE TABLE silver.bee_colonies_county_column_subset(
    year INT,
    geo_level NVARCHAR(50),
    state NVARCHAR(50),
    state_ansi NVARCHAR(50),
    ag_district NVARCHAR(50),
    ag_district_code NVARCHAR(50),
    county NVARCHAR(50),
    county_ansi NVARCHAR(50),
    value NVARCHAR(50));

IF OBJECT_ID ('silver.bee_colonies_state_column_subset', 'U') IS NOT NULL
    DROP TABLE silver.bee_colonies_state_column_subset
CREATE TABLE silver.bee_colonies_state_column_subset(
    year INT,
    geo_level NVARCHAR(50),
    state NVARCHAR(50),
    state_ansi INT,
    ag_district NVARCHAR(50),
    ag_district_code INT,
    county NVARCHAR(50),
    county_ansi INT,
    value NVARCHAR(50));

IF OBJECT_ID ('silver.population_estimates_trimmed', 'U') IS NOT NULL
    DROP TABLE silver.population_estimates_trimmed
CREATE TABLE silver.population_estimates_trimmed(
    fipstxt INT,
    state NVARCHAR(50),
    area_name NVARCHAR(50),
    rural_urban_code_2013 NVARCHAR(50),
    population_1990 NVARCHAR(50),
    population_2000 NVARCHAR(50),
    population_2010 NVARCHAR(50),
    population_2020 NVARCHAR(50),
    geo_level NVARCHAR(50),
    state_ansi INT,
    county_ansi INT);

IF OBJECT_ID ('silver.geo_codes', 'U') IS NOT NULL
    DROP TABLE silver.geo_codes;
CREATE TABLE silver.geo_codes(
    geo_level NVARCHAR(25), 
    state_ansi INT, 
    county_ansi INT, 
    state NVARCHAR(25), 
    area_name NVARCHAR(50),
    PRIMARY KEY (state_ansi, county_ansi));
