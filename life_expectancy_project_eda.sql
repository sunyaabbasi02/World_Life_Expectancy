# EDA for World Life Expectancy Project
# Sunya Abbasi

#Looking at maximum, minimum and range of Life Expectancies in each Country
SELECT Country, 
MIN(`Life Expectancy`), 
MAX(`Life Expectancy`),
ROUND( MAX(`Life Expectancy`) - MIN(`Life Expectancy`), 1) AS life_exp_range
FROM world_life_expectancy
GROUP By Country
HAVING MIN(`Life Expectancy`) <> 0
	AND MAX(`Life Expectancy`) <> 0
ORDER BY life_exp_range DESC;

# Average Life Expectancy per Year
SELECT Year, ROUND(AVG(`Life Expectancy`), 2)
FROM world_life_expectancy
WHERE `Life Expectancy` <> 0
GROUP BY Year
ORDER BY Year;

#Average Life Expectancy and GDP per Country
SELECT Country, ROUND(AVG(`Life Expectancy`), 1) AS Life_Exp, ROUND(AVG(GDP), 1) AS GDP
FROM world_life_expectancy
WHERE `Life Expectancy` > 0 AND GDP > 0
GROUP BY Country
ORDER BY GDP DESC
;


# Finding median of average GDP for all countries in the table
SELECT COUNT(DISTINCT Country)
FROM world_life_expectancy
;
#193 distinct countries so median is at position 97
SELECT GDP, row_num
FROM (
	SELECT ROUND(AVG(GDP), 1) AS GDP, 
	ROW_NUMBER() OVER() AS row_num
	FROM world_life_expectancy
	WHERE `Life Expectancy` > 0 AND GDP > 0
	GROUP BY Country
	ORDER BY GDP DESC ) new_table
WHERE row_num = 97
;
#median of average GDPs is 1936.5

# We will consider GDPs above 1936 to be high GDP
# and GDPs below 1936 to be low GDP
SELECT
SUM(CASE WHEN GDP >= 1936 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1936 THEN `Life Expectancy` ELSE NULL End) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1936 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1936 THEN `Life Expectancy` ELSE NULL End) Low_GDP_Life_Expectancy
FROM world_life_expectancy
;
# We find that the Life Expectancy in "High GDP" Countries is
# around 10 years higher on average than "Low GDP" Countries

SELECT Status, ROUND(AVG(`Life Expectancy`), 1)
FROM world_life_expectancy
GROUP BY Status
;
# We find that the Life Expectancy in Developed Countries is
# 66.8 while the average than in Developing Countries is 79.2

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life Expectancy`), 1)
FROM world_life_expectancy
GROUP BY Status
;
# However, there are way more Developing Countries in our Table


# Looking at average BMIs
SELECT Country, ROUND(AVG(`Life Expectancy`), 1) AS Life_Exp, ROUND(AVG(BMI), 1) AS BMI
FROM world_life_expectancy
WHERE `Life Expectancy` > 0 AND BMI > 0
GROUP BY Country
ORDER BY BMI ASC
;
# Noticing that Countries with very low BMI have low life expectancies

# Rolling Total of Adult Mortality per Country
SELECT Country,
Year,
`Life Expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS rolling_total
FROM world_life_expectancy
;
