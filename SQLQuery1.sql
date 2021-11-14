
-- 1 --
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- 2 : total cases vs total deaths--
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Precentage
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- 3 : percentage of the population that got covid--
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS 'Infected percentage'
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- 4 : countries whth higest infection rate compared to the population--
SELECT location, population, MAX(total_cases) AS HIGHES_INFECTION_COUNTRIES,  MAX((total_cases/population))*100 AS Infected_percentage
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY Infected_percentage DESC

-- 5 : countries with highest death count per population--
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Deaths_Count, continent
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, continent
ORDER BY Total_Deaths_Count DESC

-- 6 : continents with highest death count (break things down by continents) --
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Deaths_Count
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NULL
GROUP BY  location
ORDER BY Total_Deaths_Count DESC

-- 7 : continents whth higest infection rate compared to the population--
SELECT location, population, MAX(total_cases) AS HIGHES_INFECTION_COUNTRIES,  MAX((total_cases/population))*100 AS Infected_percentage
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS  NULL
GROUP BY location,population
ORDER BY Infected_percentage DESC

-- 8 : percentage of the population that got covid per continent--
SELECT location,  population, MAX(total_cases),MAX (total_cases/population)*100 AS Infected_percentage
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS  NULL
GROUP BY location,population
ORDER BY Infected_percentage DESC

--  global numbers--

-- 9 : total number of cases and deaths worldwide per day
SELECT  date, SUM(new_cases) AS SUM_CASES, SUM(CAST(new_deaths AS INT)) AS SUM_DEATHS
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- 10 : deaths percentage worldwide per day
SELECT  date, SUM(new_cases) AS SUM_CASES, SUM(CAST(new_deaths AS INT)) AS SUM_DEATHS,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DEATHS_PERCENTAGE
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

-- 11 : total deaths cases and percentage worldwide 
SELECT   SUM(new_cases) AS SUM_CASES, SUM(CAST(new_deaths AS INT)) AS SUM_DEATHS,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DEATHS_PERCENTAGE
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- 12 : worldwide percentage of infected population per day
SELECT location, date, population, total_cases, 
(total_cases/population)*100 AS Infected_Percentage
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- 13 : total population vs vaccinations
WITH rolling_vaccinations (continent, location, date, population, new_vaccinations, rolling_vaccinations)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
,SUM(CAST(vaccine.new_vaccinations AS INT)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date ) AS rolling_vaccinations
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_vaccinations vaccine
ON deaths.location = vaccine.location AND
	deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL 
)
SELECT*, (rolling_vaccinations/population)*100 AS Porcentage_of_vaccinations
FROM rolling_vaccinations

-- 14 : the same query only using temp tablt
DROP TABLE IF EXISTS #vaccinate_percent
CREATE TABLE #vaccinate_percent
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccination nvarchar(255),

)
INSERT INTO #vaccinate_percent
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_vaccinations vaccine
ON deaths.location = vaccine.location AND
	deaths.date = vaccine.date

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
,SUM(CAST(vaccine.new_vaccinations AS float)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date ) AS rolling_vaccinations
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_vaccinations vaccine
ON deaths.location = vaccine.location AND
	deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL 

-- 15 : deaths per age by countries
SELECT deaths.location, deaths.date, deaths.new_deaths, age.aged_65_older,age.aged_70_older
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_per_age age
ON  deaths.location = age.location AND
		deaths.date = age.date
WHERE deaths.continent IS NOT NULL  

-- 15 : deaths per age by countries
SELECT deaths.location, deaths.date, deaths.new_deaths, age.aged_65_older,age.aged_70_older
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_per_age age
ON  deaths.location = age.location AND
		deaths.date = age.date
WHERE deaths.continent IS NOT NULL  

-- 16 : deaths per health conditions by contries
SELECT deaths.location, deaths.date, deaths.new_deaths, 
SUM(CAST(deaths.new_deaths AS float)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date ) AS total_deaths,
health.diabetes_prevalence, health.cardiovasc_death_rate,
health.female_smokers, health.male_smokers
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_pre_health_conditions health
ON deaths.location = health.location AND
deaths.date = health.date
WHERE deaths.continent IS NOT NULL  




--view1 : total cases vs total deaths 
CREATE VIEW cases_vs_deaths AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Precentage
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL

--view2 : highest infection rate per population
CREATE VIEW highest_infection_rate AS
SELECT location, population, MAX(total_cases) AS HIGHES_INFECTION_COUNTRIES,  MAX((total_cases/population))*100 AS Infected_percentage
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location,population

--view3 : highest death count
CREATE VIEW highest_death_count AS
SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Deaths_Count, continent
FROM Covid_portfolio_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, continent


-- view4 : creating view to store data for visualizations
CREATE VIEW percent_population_vaccinated AS
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccine.new_vaccinations
,SUM(CAST(vaccine.new_vaccinations AS float)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date ) AS rolling_vaccinations
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_vaccinations vaccine
ON deaths.location = vaccine.location AND
	deaths.date = vaccine.date
WHERE deaths.continent IS NOT NULL

-- view5 : deaths per age 
CREATE VIEW death_per_age AS
SELECT deaths.location, deaths.date, deaths.new_deaths, age.aged_65_older,age.aged_70_older
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_per_age age
ON  deaths.location = age.location AND
		deaths.date = age.date
WHERE deaths.continent IS NOT NULL  

-- view6 : death vs health conditions
CREATE VIEW death_vs_health_conditions AS
SELECT deaths.location, deaths.date, deaths.new_deaths, 
SUM(CAST(deaths.new_deaths AS float)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date ) AS total_deaths,
health.diabetes_prevalence, health.cardiovasc_death_rate,
health.female_smokers, health.male_smokers
FROM Covid_portfolio_project..covid_deaths deaths
JOIN Covid_portfolio_project..covid_pre_health_conditions health
ON deaths.location = health.location AND
deaths.date = health.date
WHERE deaths.continent IS NOT NULL  

SELECT*
FROM cases_vs_deaths



--, (rolling_vaccinations/population)*100 AS Porcentage_of_vaccinations
--and deaths.location='Israel'
--SELECT max(cast(total_deaths as int))
--FROM Covid_portfolio_project..covid_deaths
--WHERE continent='North America'
--SELECT max(cast(total_deaths as int))
--FROM Covid_portfolio_project..covid_deaths
--WHERE location = 'united states'
----ORDER BY 1,2
-- and location= 'united states'



