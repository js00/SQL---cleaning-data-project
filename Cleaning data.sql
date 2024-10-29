#Database overwiev
SELECT *
FROM layoffs;

#Creating wokring space
CREATE TABLE layoffs_working
LIKE layoffs;

#Inserting data into new working space
INSERT INTO layoffs_working
SELECT *
FROM layoffs;

#Checking new table
SELECT *
FROM layoffs_working;

#STEP 1 - DELETING DUPLICATES

#Creating CTE to find duplicates
WITH duplicates_find AS(
	SELECT
		*,
        ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_working
)
SELECT *
FROM duplicates_find
WHERE row_num > 1;

#Checking duplicates
SELECT *
FROM layoffs_working
WHERE company = "Yahoo" OR company = "Wildlife Studios" OR company = "Hibob" OR company = "Cazoo" OR company = "Casper"
ORDER BY company; 

#Creating new table with new column row_num, which identify duplicates. In MySQL we cannot use DELETE like in PostgreSQL fo example
CREATE TABLE `layoffs_working_rows` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_working_rows;

#Inserting data into new space, with new column called row_num, which has value 1 if row is unique or 2 if row is a duplicate
INSERT INTO layoffs_working_rows
SELECT 
	*,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_working;

#Checking results of new spaces
SELECT *
FROM layoffs_working_rows;

#Checking duplicates in new sapce
SELECT *
FROM layoffs_working_rows
WHERE row_num > 1;

#Deleting duplicates
DELETE
FROM layoffs_working_rows
WHERE row_num > 1;

#Checking if deleting went properly
SELECT *
FROM layoffs_working_rows
WHERE row_num > 1;

#STEP 2 - STANDARDIZING DATA

#Checking if column 'company' has unnecessary spaces and TRIM them
SELECT
	company,
    LENGTH(company),
    TRIM(company)
FROM layoffs_working_rows;

#I see that column 'company' has those spaces so I have to update table
UPDATE layoffs_working_rows
SET company = TRIM(company);

#Checking values in column 'industry', because I spotted some mistakes
SELECT DISTINCT industry
FROM layoffs_working_rows
ORDER BY 1;

#Updating values, where were mistakes in spelling 'Crypto'
UPDATE layoffs_working_rows
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";

#Checking results
SELECT DISTINCT industry
FROM layoffs_working_rows
ORDER BY 1; #Good

SELECT *
FROM layoffs_working_rows;

#Checking values in location
SELECT DISTINCT location
FROM layoffs_working_rows
ORDER BY 1;

#Checking values in country
SELECT DISTINCT country
FROM layoffs_working_rows
ORDER BY 1;

#Correcting mistakes in spelling United States, beacuse there was 1 row 'United States.'
UPDATE layoffs_working_rows
SET country = "United States"
WHERE country = "United States.";

#In this table, column 'date' is in texr format, so I have to change this to date format
SELECT 
	`date`,
    STR_TO_DATE(`date`, "%m/%d/%Y") 
FROM layoffs_working_rows;

#Updating table, but that still would be in text format
UPDATE layoffs_working_rows
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");

#Checking values 
SELECT 
    SUBSTRING(`date`, 5, 5)
FROM layoffs_working_rows
ORDER BY 1;

#Now updating data type of 'data' column
ALTER TABLE layoffs_working_rows
MODIFY COLUMN `date` DATE;

#WORK WITH NULLS AND BLANKS VALUES

















