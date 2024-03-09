# US HOUSEHOLD INCOME PROJECT BY (SIDDHARTH GAJARE)

##########################
# CLEANING OF THE DATASET
##########################

# Checking the dataset to start working
SELECT *
FROM us_household_income;

SELECT *
FROM us_household_income.us_household_income_statistics;

# Renamed bad table name 
ALTER TABLE us_household_income.us_household_income_statistics RENAME COLUMN `ï»¿id` TO `id`;

# Checking out total number of rows in the datasets
SELECT COUNT(id)
FROM us_household_income.us_household_income_statistics; #32526

SELECT COUNT(id)
FROM us_household_income; #32292 (So this dataset is not aligned and missing some rows)

# Found out multiple data in the dataset
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1; #Found out few duplicates
 
SELECT id, COUNT(id)
FROM us_household_income.us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1; #Found None

#Finding out duplicate rows from the table
SELECT *
FROM(
	SELECT row_id, id,
	ROW_NUMBER () OVER (PARTITION BY id ORDER BY id) AS Row_Num
	FROM us_household_income
	) AS duplciates
WHERE Row_Num > 1;


#NOW DELETING THE DUPLICATE DATA
DELETE FROM us_household_income
WHERE row_id IN (
SELECT row_id
FROM(
	SELECT row_id, id,
	ROW_NUMBER () OVER (PARTITION BY id ORDER BY id) AS Row_Num
	FROM us_household_income
	) AS duplciates
WHERE Row_Num > 1
);

#Checking Names
SELECT DISTINCT(State_Name)
FROM us_household_income
GROUP BY State_name;   # Found out one miss spelled name.

#Changed the name
UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'; 

#Finding blanks in Place column
SELECT *
FROM us_household_income
WHERE Place = ''
ORDER BY 1;  # Found out 1 missing data in place

# ADDED THE BLANK WITH APPROPRIATE NAME
UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE City = 'Vinemont'
AND County = 'Autauga County';

# Checking Types in the dataset
SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY type;   #FOund out that 1 data type is misspelled 

#Corrected and merged the misspelled name to the correct one
UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

#Saw '0' in AWater dataset, So checking the dataset
SELECT ALand, Awater
FROM us_household_income
WHERE ALand = 0 or ALand = '' or ALand IS NULL;
#SAW 0 in both Land and Water, So not touching the values Since the area can have those values.


##########################
# EXPLORING THE DATASET
##########################

#Top 10 largest State by Land
SELECT State_Name, SUM(ALand)
FROM us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10; 

#Top 10 largest State by Water
SELECT State_Name, SUM(AWater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10; 

# Joining both the datasets
# Joining by id
SELECT *
FROM us_household_income as a
INNER JOIN us_household_income.us_household_income_statistics as b
	ON a.id = b.id
WHERE Mean <> 0;


#AVG INCOME BY STATE (MEAN AND MEDIAN)
SELECT a.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income as a
INNER JOIN us_household_income.us_household_income_statistics as b
	ON a.id = b.id
WHERE Mean <> 0
GROUP BY a.State_Name
ORDER BY 2 DESC
LIMIT 5;    # Found out top 5 and lower 5 by using code to DESC and ASC

#Type, Where the people live in
SELECT Type, COUNT(type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM us_household_income as a
INNER JOIN us_household_income.us_household_income_statistics as b
	ON a.id = b.id
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 3 DESC
LIMIT 15;

# Top Income by cities
SELECT a.State_Name, City, ROUND(AVG(Mean),1)
FROM us_household_income as a
INNER JOIN us_household_income.us_household_income_statistics as b
	ON a.id = b.id
GROUP BY a.State_Name, City
ORDER BY ROUND(AVG(Mean),1) DESC;

#CREATED NEW TABLE FOR FURTHER CALCULATIONS
CREATE TABLE MergedTable AS
SELECT a.id, a.State_Name, a.County, a.City, a.Place, a.Type, a.Primary, a.Zip_Code, a.Area_Code, a.ALand, a.AWater, a.Lat, a.Lon,
       b.Mean, b.Median, b.Stdev, b.sum_w
FROM us_household_income AS a
INNER JOIN us_household_income_statistics AS b
    ON a.id = b.id
WHERE b.Mean <> 0;

# Top Income by Zip-Code
SELECT Zip_Code, ROUND(AVG(Mean), 2) AS Avg_Income
FROM mergedtable
WHERE Mean <> 0
GROUP BY Zip_Code
ORDER BY Avg_Income DESC
LIMIT 10;
