CREATE DATABASE PortfolioProject;
USE PortfolioProject;

 -- 1️⃣ Check the Total Number of Records
 SELECT COUNT(*) AS total_rows FROM PortfolioProject.CovidDeaths;

-- How many rows are present in the CovidDeaths table?
SELECT COUNT(*) AS total_rows FROM PortfolioProject.CovidDeaths;


-- 2️⃣ Check the Date Range of Data Available
-- What is the earliest and latest recorded date in the dataset?
SELECT MIN(date) AS start_date, MAX(date) AS end_date
FROM PortfolioProject.CovidDeaths;


-- 3️⃣ Total COVID Cases and Deaths by Country
-- Which countries had the highest number of COVID-19 cases and deaths?
SELECT location, SUM(new_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_cases DESC;


-- 4️⃣ Global COVID-19 Statistics
-- What are the total global COVID-19 cases and deaths?
SELECT SUM(new_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM PortfolioProject.CovidDeaths;


-- 5️⃣ Find Countries with the Highest Death Rate
-- Which countries had the highest COVID-19 death rate?
SELECT location, SUM(total_deaths) AS total_deaths, SUM(new_cases) AS total_cases, 
       (SUM(total_deaths) / SUM(new_cases)) * 100 AS death_rate
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_rate DESC
LIMIT 10;

-- 6️⃣ Check the Population Impact (Cases Per Population)
-- Which countries had the highest infection rate relative to their population?
SELECT location, population, SUM(new_cases) AS total_cases, 
       (SUM(new_cases) / population) * 100 AS infection_rate
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;


-- Intermediate-Level Queries:
-- 7️⃣ Monthly COVID-19 Trends by Country
-- How did COVID-19 cases and deaths fluctuate over months in different countries?
SELECT location, YEAR(date) AS year, MONTH(date) AS month, 
       SUM(new_cases) AS monthly_cases, SUM(new_deaths) AS monthly_deaths
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, YEAR(date), MONTH(date)
ORDER BY location, year, month;


-- 8️⃣ Most Affected Continents
-- Which continents had the highest number of cases and deaths?
SELECT continent, SUM(new_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC;

-- 9️⃣ Which countries had more than 10% of their population infected?
SELECT location, population, SUM(new_cases) AS total_cases, 
       (SUM(new_cases) / population) * 100 AS percentage_infected
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING percentage_infected > 10
ORDER BY percentage_infected DESC;


-- 🔟 Comparing COVID-19 Cases & Vaccinations
-- How do COVID-19 cases compare with vaccination trends over time?
SELECT d.location, d.date, d.new_cases, v.new_vaccinations, 
       SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.date) AS rolling_vaccinations
FROM PortfolioProject.CovidDeaths d
JOIN PortfolioProject.CovidVaccinations v 
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;


-- 1️⃣1️⃣ Find the First Case & First Death for Each Country
-- When did each country report its first COVID-19 case?
SELECT location, MIN(date) AS first_case_date
FROM PortfolioProject.CovidDeaths
WHERE new_cases > 0
GROUP BY location
ORDER BY first_case_date;

-- When did each country report its first COVID-19 death?
SELECT location, MIN(date) AS first_death_date
FROM PortfolioProject.CovidDeaths
WHERE new_deaths > 0
GROUP BY location
ORDER BY first_death_date;


-- 1️⃣2️⃣ Finding Days with the Highest Daily Cases & Deaths
-- Which days had the highest number of new cases and deaths recorded?
SELECT location, date, new_cases, new_deaths
FROM PortfolioProject.CovidDeaths
WHERE new_cases = (SELECT MAX(new_cases) FROM PortfolioProject.CovidDeaths)
   OR new_deaths = (SELECT MAX(new_deaths) FROM PortfolioProject.CovidDeaths);


-- 1️⃣3️⃣ Vaccination Coverage by Country
-- What percentage of the population in each country has been vaccinated?
SELECT v.location, v.date, v.new_vaccinations, d.population,
       SUM(v.new_vaccinations) OVER (PARTITION BY v.location ORDER BY v.date) AS total_vaccinations,
       (SUM(v.new_vaccinations) OVER (PARTITION BY v.location ORDER BY v.date) / d.population) * 100 AS vaccination_rate
FROM PortfolioProject.CovidVaccinations v
JOIN PortfolioProject.CovidDeaths d 
ON v.location = d.location AND v.date = d.date
WHERE d.continent IS NOT NULL;


-- 1️⃣4️⃣ Finding the Country with the Best Recovery Rate
-- Which country had the highest COVID-19 recovery rate?
SELECT location, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
       ((SUM(new_cases) - SUM(new_deaths)) / SUM(new_cases)) * 100 AS recovery_rate
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY recovery_rate DESC;

-- Here are some additional SQL queries involving Window Functions, CTEs, and Subqueries
-- 1️⃣ Using Window Functions
-- 1a)Rolling Total of COVID-19 Cases Over Time (Per Country)
-- This query calculates the cumulative number of cases over time for each country.
SELECT location, date, new_cases, 
       SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS rolling_total_cases
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;

-- 1b)7-Day Moving Average of New Cases
-- This calculates a rolling 7-day moving average of new cases per country.
SELECT location, date, new_cases, 
       AVG(new_cases) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg_cases
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL;

-- 1c)Ranking Countries by Total Cases
-- Ranks countries based on total COVID-19 cases.
SELECT location, SUM(new_cases) AS total_cases, 
       RANK() OVER (ORDER BY SUM(new_cases) DESC) AS case_rank
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location;

-- 1d)Finding the Day with the Highest Cases for Each Country
-- Ranks days based on new cases per country to find peak infection days.
SELECT location, date, new_cases,
       RANK() OVER (PARTITION BY location ORDER BY new_cases DESC) AS rank_per_country
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL;


--  2️⃣ Using CTEs (Common Table Expressions)
-- 2a)CTE for Calculating Case Fatality Rate (CFR) Per Country
-- This calculates the fatality rate per country using a CTE.
WITH CaseFatalityRate AS (
    SELECT location, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
           (SUM(new_deaths) / NULLIF(SUM(new_cases), 0)) * 100 AS case_fatality_rate
    FROM PortfolioProject.CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY location
)
SELECT * FROM CaseFatalityRate
ORDER BY case_fatality_rate DESC;
-- 2b)CTE to Compare Cases & Vaccinations
-- This joins two CTEs to compare daily cases and vaccinations for each country
WITH Cases AS (
    SELECT location, date, SUM(new_cases) AS total_cases
    FROM PortfolioProject.CovidDeaths
    WHERE continent IS NOT NULL
    GROUP BY location, date
),
Vaccinations AS (
    SELECT location, date, SUM(new_vaccinations) AS total_vaccinations
    FROM PortfolioProject.CovidVaccinations
    GROUP BY location, date
)
SELECT c.location, c.date, c.total_cases, v.total_vaccinations
FROM Cases c
JOIN Vaccinations v ON c.location = v.location AND c.date = v.date;


--  3️⃣ Using Subqueries
-- 3a)Find Countries with Above-Average Total Cases
-- Finds countries with total cases above the average total cases worldwide.
SELECT location, SUM(new_cases) AS total_cases
FROM PortfolioProject.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
HAVING SUM(new_cases) > (SELECT AVG(total_cases) 
                         FROM (SELECT SUM(new_cases) AS total_cases FROM PortfolioProject.CovidDeaths WHERE continent IS NOT NULL GROUP BY location) AS avg_cases);

-- 3b)Find the Country with the Highest Daily Increase
-- Identifies the highest single-day increase in cases worldwide.
SELECT location, date, new_cases
FROM PortfolioProject.CovidDeaths
WHERE new_cases = (SELECT MAX(new_cases) FROM PortfolioProject.CovidDeaths);


-- 3c)Percentage of Population Infected for Each Country
-- Calculates what percentage of the population was infected in each country.
SELECT location, population, 
       (SELECT SUM(new_cases) FROM PortfolioProject.CovidDeaths d WHERE d.location = c.location) AS total_cases,
       ((SELECT SUM(new_cases) FROM PortfolioProject.CovidDeaths d WHERE d.location = c.location) / population) * 100 AS infection_rate
FROM PortfolioProject.CovidDeaths c
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;


-- 3d)Countries Where More Than 50% of Population is Vaccinated
-- Finds countries where more than 50% of the population has been vaccinated.
SELECT location, population, 
       (SELECT SUM(new_vaccinations) FROM PortfolioProject.CovidVaccinations v WHERE v.location = d.location) AS total_vaccinated,
       ((SELECT SUM(new_vaccinations) FROM PortfolioProject.CovidVaccinations v WHERE v.location = d.location) / population) * 100 AS vaccination_rate
FROM PortfolioProject.CovidDeaths d
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING vaccination_rate > 50
ORDER BY vaccination_rate DESC;

-- ADVANCED SQL QUERY
-- Combining CTEs, Window Functions & Subqueries
-- Rolling Vaccination Rate vs. Cases Over Time
-- This tracks the cumulative number of cases and vaccinations for each country while also calculating the percentage of the population vaccinated over time.

WITH VaccinationProgress AS (
    SELECT location, date, new_vaccinations, 
           SUM(new_vaccinations) OVER (PARTITION BY location ORDER BY date) AS rolling_vaccinations
    FROM PortfolioProject.CovidVaccinations
),
CaseProgress AS (
    SELECT location, date, new_cases,
           SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS rolling_cases
    FROM PortfolioProject.CovidDeaths
)
SELECT v.location, v.date, v.rolling_vaccinations, c.rolling_cases,
       (v.rolling_vaccinations / (SELECT population FROM PortfolioProject.CovidDeaths p WHERE p.location = v.location LIMIT 1)) * 100 AS vaccination_percentage
FROM VaccinationProgress v
JOIN CaseProgress c ON v.location = c.location AND v.date = c.date
WHERE v.rolling_vaccinations IS NOT NULL AND c.rolling_cases IS NOT NULL
ORDER BY v.location, v.date;

 


