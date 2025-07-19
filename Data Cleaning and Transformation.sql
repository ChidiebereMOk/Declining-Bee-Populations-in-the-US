USE honey_bee_populationsdb;
-- Data cleaning
UPDATE population_estimates_trimmed 
SET population_1990 = replace(population_1990, ',','');
    
UPDATE population_estimates_trimmed 
SET population_1990 = replace(population_2000, ',','');

UPDATE population_estimates_trimmed 
SET population_1990 = replace(population_2010, ',','');

UPDATE population_estimates_trimmed 
SET population_1990 = replace(population_2020, ',','');

-- Checking for empty strings
SELECT 
	* 
FROM 
	population_estimates_trimmed 
WHERE rural_urban_code_2013 = '';

-- Converting empty strings into null values
UPDATE population_estimates_trimmed 
SET rural_urban_code_2013 = null 
WHERE rural_urban_code_2013 = '';

-- Formatting tables for readability
ALTER TABLE population_estimates_trimmed 
DROP COLUMN geo_level;

ALTER TABLE population_estimates_trimmed 
ADD Geo_Level varchar(12);

UPDATE population_estimates_trimmed 
SET geo_level = null;

UPDATE population_estimates_trimmed 
SET geo_level = 'COUNTRY' 
WHERE (fipstxt%1000 = 0) AND (state = 'us');

UPDATE population_estimates_trimmed 
SET geo_level = 'STATE' 
WHERE (fipstxt%1000 = 0) AND (state != 'us');

UPDATE population_estimates_trimmed 
SET geo_level = 'county' 
WHERE fipstxt%1000 != 0;

ALTER TABLE population_estimates_trimmed 
DROP COLUMN state_ansi;

ALTER TABLE population_estimates_trimmed 
DROP COLUMN county_ansi;

ALTER TABLE population_estimates_trimmed 
ADD State_ANSI integer;

ALTER TABLE population_estimates_trimmed 
ADD County_ANSI integer;

UPDATE population_estimates_trimmed 
SET state_ansi = floor(fipstxt/1000);

UPDATE population_estimates_trimmed 
SET county_ansi = fipstxt%1000;


-- Creating population, Geographic Codes, Agricultural Codes, and Bee Colonies tables
DROP TABLE IF EXISTS population;
DROP TABLE IF EXISTS geo_codes;
DROP TABLE IF EXISTS bee_colonies;
DROP TABLE IF EXISTS ag_codes;


CREATE TABLE 
	Geo_Codes(
		Geo_Level VARCHAR(12), 
        State_ANSI INT, 
        County_ANSI INT, 
        State VARCHAR(2), 
        Area_Name VARCHAR(50),
		PRIMARY KEY (state_ansi, county_ansi));
        
INSERT INTO
	geo_codes 
SELECT DISTINCT 
	geo_level, 
    state_ansi, 
    county_ansi, 
    state, 
    area_name 
FROM
	population_estimates_trimmed;

CREATE TABLE 
	population(
		State_ANSI INT, 
        County_ANSI INT, 
        Rural_Urban_Code_2013 INT, 
        Population_1990 TEXT, 
        Population_2000 TEXT, 
        Population_2010 TEXT, 
        Population_2020 TEXT,
		PRIMARY KEY (state_ansi, county_ansi), 
        FOREIGN KEY(state_ansi, county_ansi) REFERENCES geo_codes(state_ansi, county_ansi));

INSERT INTO 
	population 
SELECT 
	state_ansi, 
    county_ansi, 
    rural_urban_code_2013, 
    population_1990, 
    population_2000, 
    population_2010, 
    population_2020 
FROM 
	population_estimates_trimmed;
    
UPDATE bee_colonies_county_column_subset 
SET county_ansi = null 
WHERE county_ansi = '';

UPDATE bee_colonies_county_column_subset 
SET VALUE = null 
WHERE VALUE LIKE '%D%';

UPDATE bee_colonies_county_column_subset 
SET VALUE = REPLACE(VALUE,',', '');


SELECT 
	* 
FROM 
	geo_codes 
JOIN(
	SELECT * 
	FROM bee_colonies_county_column_subset 
	WHERE county_ansi is null)B 
ON geo_codes.state_ansi = B.state_ansi 
AND area_name LIKE concat ('%', B.county,'%');


UPDATE bee_colonies_county_column_subset 
SET county_ansi = (
					SELECT geo_codes.county_ansi 
					FROM geo_codes 
                    WHERE geo_codes.state_ansi = bee_colonies_county_column_subset.state_ansi 
                    AND geo_codes.area_name LIKE concat('%', bee_colonies_county_column_subset.county, '%')) 
WHERE county_ansi IS NULL;

CREATE TABLE 
	Ag_Codes(
		State_ANSI INT, 
        Ag_District_Code INT, 
        Ag_District VARCHAR(50),
		PRIMARY KEY(state_ansi, ag_district_code));

INSERT INTO 
	ag_codes
SELECT DISTINCT 
	state_ansi, 
    ag_district_code, 
    ag_district
FROM 
	bee_colonies_county_column_subset;


CREATE TABLE 
	Bee_Colonies(
		State_ANSI INT, 
        County_ANSI INT, 
        Ag_District_Code INT, 
        Colonies_2002 INT,
		Colonies_2007 INT, 
        Colonies_2012 INT, 
        Colonies_2017 INT, 
        PRIMARY KEY(State_ANSI, county_ansi), 
        FOREIGN KEY (state_ansi, county_ansi) REFERENCES geo_codes(state_ansi, county_ansi), 
        FOREIGN KEY (State_ansi, ag_district_code) REFERENCES Ag_Codes(State_ansi, ag_district_code));


ALTER TABLE bee_colonies_county_column_subset 
CHANGE state_ansi state_ansi INT;
    
ALTER TABLE bee_colonies_county_column_subset 
CHANGE county_ansi county_ansi INT;
    
ALTER TABLE bee_colonies_county_column_subset 
CHANGE year year integer;

INSERT INTO
	bee_colonies(state_ansi, county_ansi, ag_district_code) 
SELECT DISTINCT 
	state_ansi, 
	county_ansi, 
    ag_district_code
FROM 
	bee_colonies_county_column_subset;

-- Creating subquery index to improve speed and efficiency
CREATE INDEX subquery_idx
ON 
	bee_colonies_county_column_subset(state_ansi, county_ansi, year);

UPDATE bee_colonies 
SET colonies_2002 = (
						SELECT value 
						FROM bee_colonies_county_column_subset B
						WHERE bee_colonies.state_ansi = b.state_ansi 
                        AND bee_colonies.county_ansi = b.county_ansi 
                        AND year = 2002);

UPDATE bee_colonies 
SET colonies_2007 = (
						SELECT value 
						FROM bee_colonies_county_column_subset B
						WHERE bee_colonies.state_ansi = b.state_ansi 
                        AND bee_colonies.county_ansi = b.county_ansi 
                        AND year = 2007);

UPDATE bee_colonies 
SET colonies_2012 = (
						SELECT value 
						FROM bee_colonies_county_column_subset B
						WHERE bee_colonies.state_ansi = b.state_ansi 
                        AND bee_colonies.county_ansi = b.county_ansi 
						AND year = 2012);

UPDATE bee_colonies 
SET colonies_2017 = (
						SELECT VALUE 
						FROM bee_colonies_county_column_subset B
                        WHERE bee_colonies.state_ansi = b.state_ansi 
                        AND bee_colonies.county_ansi = b.county_ansi 
                        AND year = 2017);

DROP INDEX subquery_idx 
ON 
	bee_colonies_county_column_subset;

-- Cleaning source tables
UPDATE bee_colonies_state_column_subset 
SET ag_district_code = null 
WHERE ag_district_code = '';

UPDATE bee_colonies_state_column_subset 
SET county_ansi = 0 
where county_ansi = '';

UPDATE bee_colonies_state_column_subset 
SET value = replace(value, ',', '');

ALTER TABLE 
	bee_colonies_state_column_subset 
CHANGE 
	state_ansi state_ansi INT;
    
ALTER TABLE bee_colonies_state_column_subset 
CHANGE county_ansi county_ansi INT;
    
ALTER TABLE bee_colonies_state_column_subset 
CHANGE year year integer;

INSERT INTO 
	bee_colonies (state_ansi, county_ansi, ag_district_code) 
SELECT DISTINCT 
	state_ansi,
    county_ansi, 
    ag_district_code 
FROM 
	bee_colonies_state_column_subset;


UPDATE bee_colonies 
SET colonies_2002 = (
						SELECT value 
						FROM bee_colonies_state_column_subset b 
                        WHERE bee_colonies.state_ansi = b.state_ansi 
                        AND bee_colonies.county_ansi = b.county_ansi 
                        AND year = 2002) 
WHERE colonies_2002 IS NULL;

UPDATE bee_colonies 
SET colonies_2007 = (
						SELECT value 
						FROM bee_colonies_state_column_subset b 
                        WHERE bee_colonies.state_ansi = b.state_ansi 
                        AND bee_colonies.county_ansi = b.county_ansi 
                        AND year = 2007) 
WHERE colonies_2002 IS NULL;

UPDATE bee_colonies 
SET colonies_2012 = (	
						SELECT value 
						FROM bee_colonies_state_column_subset b 
                        WHERE bee_colonies.state_ansi = b.state_ansi 
                        AND bee_colonies.county_ansi = b.county_ansi 
                        AND year = 2012) 
WHERE colonies_2002 IS NULL;

UPDATE bee_colonies 
SET colonies_2017 = (
						SELECT value 
						FROM bee_colonies_state_column_subset b 
						WHERE bee_colonies.state_ansi = b.state_ansi 
                        AND bee_colonies.county_ansi = b.county_ansi 
                        AND year = 2017) 
WHERE colonies_2002 IS NULL;