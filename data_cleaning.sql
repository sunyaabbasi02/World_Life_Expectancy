# Data Cleaning for World Life Expectancy Project
# Sunya Abbasi 

USE World_Life_Expectancy;

SELECT * 
FROM world_life_expectancy
;

#checking if there are any duplicate rows

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year
HAVING COUNT(CONCAT(Country, Year)) > 1;


#finding which rows are duplicates
SELECT *
FROM (
	SELECT Row_ID,
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
	FROM world_life_expectancy
    ) AS row_table
WHERE row_num > 1
;


#removing duplicate rows from table
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
	SELECT ROW_ID
	FROM (
		SELECT Row_ID,
		CONCAT(Country, Year),
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
		FROM world_life_expectancy
		) AS row_table
	WHERE row_num > 1
)
;

# Checking that no one country transitions from Developing to Developed
# in the included data -> found there are no such Countries
SELECT Country, COUNT(DISTINCT(Status))
FROM world_life_expectancy
WHERE Status != ''
GROUP BY Country
HAVING COUNT(DISTINCT(Status)) = 2
;

# finding countries with Status = "Developing" to help fill blank Statuses
SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE Status = 'Developing'
;

# Updating Table
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.status <> ''
AND t2.status = 'Developing';

SELECT *
FROM world_life_expectancy
WHERE Status = '';
# United States still has blank status, is a Developed country

#Updating Table
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.status <> ''
AND t2.status = 'Developed';

SELECT *
FROM world_life_expectancy
WHERE `Life Expectancy` = '';
# Found there are two missing Life Expectancies, 
# I will take average of year before and after to populate


#finding averages
SELECT t1.Country, t1.Year, t1.`Life Expectancy`,
	t2.Country, t2.Year, t2.`Life Expectancy`,
    t3.Country, t3.Year, t3.`Life Expectancy`,
    ROUND(((t2.`Life Expectancy` + t3.`Life Expectancy`) / 2), 1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
WHERE t1.`Life Expectancy` = ''
;

#Updating Table
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country AND t1.Year = t3.Year + 1
SET t1.`Life Expectancy` = ROUND(((t2.`Life Expectancy` + t3.`Life Expectancy`) / 2), 1)
WHERE t1.`Life Expectancy` = ''
;

