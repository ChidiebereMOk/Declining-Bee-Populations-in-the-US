/*
========================================================================
DDL Script: Create Gold Tables
========================================================================
Script Purpose:
    This script creates tables in the 'gold' schema, dropping existing
    tables if they already exist.
    Run this script to re-define the DDL structure of 'gold' tables
========================================================================
*/

USE BeePopulations;

-- Data Definition Language - Defining layer & table names
IF OBJECT_ID ('gold.geo_codes', 'U') IS NOT NULL
    DROP TABLE gold.geo_codes;
CREATE TABLE gold.geo_codes(
    geo_level NVARCHAR(25), 
    state_ansi INT, 
    county_ansi INT, 
    state NVARCHAR(25), 
    area_name NVARCHAR(25),
    PRIMARY KEY (state_ansi, county_ansi));

IF OBJECT_ID ('gold.population', 'U') IS NOT NULL
    DROP TABLE gold.population;
CREATE TABLE gold.population(
    State_ANSI INT, 
    County_ANSI INT, 
    Rural_Urban_Code_2013 INT, 
    Population_1990 NVARCHAR(50), 
    Population_2000 NVARCHAR(50), 
    Population_2010 NVARCHAR(50), 
    Population_2020 NVARCHAR(50),
    PRIMARY KEY (state_ansi, county_ansi), 
    FOREIGN KEY(state_ansi, county_ansi) REFERENCES gold.geo_codes(state_ansi, county_ansi));

IF OBJECT_ID ('gold.ag_codes', 'U') IS NOT NULL
    DROP TABLE gold.ag_codes;
CREATE TABLE gold.ag_codes(
    state_ansi INT, 
    ag_district_code INT, 
    ag_district NVARCHAR(50),
    PRIMARY KEY(state_ansi, ag_district_code));

IF OBJECT_ID('gold.bee_colonies', 'U') IS NOT NULL
    DROP TABLE gold.bee_colonies;
CREATE TABLE gold.bee_colonies(
		State_ANSI INT, 
        County_ANSI INT, 
        Ag_District_Code INT, 
        Colonies_2002 INT,
		Colonies_2007 INT, 
        Colonies_2012 INT, 
        Colonies_2017 INT, 
        PRIMARY KEY(State_ANSI, county_ansi), 
        FOREIGN KEY (state_ansi, county_ansi) REFERENCES gold.geo_codes(state_ansi, county_ansi), 
        FOREIGN KEY (State_ansi, ag_district_code) REFERENCES gold.ag_codes(State_ansi, ag_district_code));



