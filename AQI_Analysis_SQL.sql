-- Create a Database for Store a data 
CREATE DATABASE air_quality_db;

-- Create a table Structure before the data import for analysis
CREATE TABLE air_quality (
     id SERIAL PRIMARY KEY,
	 country VARCHAR(100),
	 state VARCHAR(100),
	 city VARCHAR(100),
	 station VARCHAR(150),
	 last_update TIMESTAMP,
	 latitude DECIMAL(9,6),
	 longitude DECIMAL(9,6),
     pollutant_id VARCHAR(50),
	 pollutant_min NUMERIC(10,2),
     pollutant_max NUMERIC(10,2),
     pollutant_avg NUMERIC(10,2),
	 pollution_range VARCHAR(50),
     pollution_category VARCHAR(50)
)

SELECT * FROM air_quality;

-- Grap the Data 
COPY air_quality(country, state, city, station, last_update, latitude, longitude,
pollutant_id, pollutant_min, pollutant_max, pollutant_avg,
pollution_range, pollution_category)
FROM 'D:\All\Complete Data Analyst Project\AQI_Project\AQI_Dateset.csv'
DELIMITER ','
CSV HEADER
NULL 'NA';

-- Data Cleaning Process -- 

-- 1.First Check's Null Values
SELECT * FROM air_quality
WHERE pollutant_min IS NULL 
    OR pollutant_max IS NULL
	OR pollutant_avg IS NULL;

-- 2.Remove Completely Useless Rows
DELETE FROM air_quality
WHERE pollutant_avg IS NULL;

-- 3.Remove Duplicates (Very Important)
SELECT country, state, city, station, pollutant_id, last_update, COUNT(*)
FROM air_quality
GROUP BY country, state, city, station, pollutant_id, last_update
HAVING COUNT(*) > 1;

-- Duplicate Values Delete
DELETE FROM air_quality a
USING air_quality b
WHERE a.id > b.id
AND a.station = b.station
AND a.last_update = b.last_update
AND a.pollutant_id = b.pollutant_id;

-- 4.Standardize Text (Very Important)
UPDATE air_quality
SET state = INITCAP(state);

UPDATE air_quality
SET city = INITCAP(city);

-- 5.Remove Extra Spaces
UPDATE air_quality
SET state = TRIM(state),
    city = TRIM(city),
    station = TRIM(station),
    pollutant_id = TRIM(pollutant_id);

-- 6.Check Outliers (Extreme AQI)
SELECT *
FROM air_quality
WHERE pollutant_avg > 1000;

-- 7.Validate Latitude & Longitude
SELECT *
FROM air_quality
WHERE latitude NOT BETWEEN -90 AND 90
        OR longitude NOT BETWEEN -180 AND 180;

-- 8.Standardize Pollution Category
SELECT DISTINCT pollution_category
FROM air_quality;

UPDATE air_quality
SET pollution_category = INITCAP(pollution_category);

-- 9.Check All Data With Sorting 
SELECT * FROM air_quality
ORDER BY id ASC;

-- Business Question to Solve Problem

-- KPI Calculations

-- 1.Overall Average AQI
SELECT ROUND(AVG(pollutant_avg),2) AS avg_aqi
FROM air_quality;

-- 2.Most Polluted State
SELECT
   state,
   ROUND(AVG(pollutant_avg),2) AS avg_aqi
FROM air_quality
GROUP BY state
ORDER BY avg_aqi DESC
LIMIT 1;

-- 3.Most Dangerous Station
SELECT 
       station,
       ROUND(AVG(pollutant_avg),2) AS avg_aqi
FROM air_quality
GROUP BY station
ORDER BY avg_aqi DESC
LIMIT 1;

-- 4.% Severe Pollution
SELECT 
      pollution_category,
      ROUND(
         SUM(CASE WHEN pollution_category = 'Severe' THEN 1 ELSE 0 END)
		 * 100 / COUNT(*),2
	  ) AS severe_percentage
FROM air_quality
GROUP BY pollution_category
ORDER BY severe_percentage DESC;

-- 5.AQI by State
SELECT 
     state,
	 ROUND(AVG(pollutant_avg),2) AS avg_aqi
FROM air_quality
GROUP BY state
ORDER BY avg_aqi DESC;

-- 6.Top 5 Most Polluted Stations
SELECT station,
       ROUND(AVG(pollutant_avg),2) AS avg_aqi
FROM air_quality
GROUP BY station
ORDER BY avg_aqi DESC
LIMIT 5;

-- 7.AQI by City
SELECT 
     city,
	 ROUND(AVG(pollutant_avg),2) AS avg_aqi
FROM air_quality
GROUP BY city
ORDER BY avg_aqi DESC;

-- 8.Pollutant Contribution (%)
SELECT pollutant_id,
       ROUND(AVG(pollutant_avg),2) AS avg_value
FROM air_quality
GROUP BY pollutant_id
ORDER BY avg_value DESC;

-- 9.Pollution Category Distribution
SELECT 
pollutant_id,
pollution_category,
       COUNT(*) AS total_count,
       ROUND(COUNT(*) * 100.0 / 
            (SELECT COUNT(*) FROM air_quality), 2) AS percentage
FROM air_quality
GROUP BY pollution_category,pollutant_id
ORDER BY percentage DESC;

-- 10. Delhi + PM2.5
SELECT *
FROM air_quality
WHERE state = 'Delhi'
AND pollutant_id = 'PM2.5';
