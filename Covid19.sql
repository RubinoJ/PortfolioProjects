--Create Table
DROP TABLE

IF EXISTS #totalpopwithvacandboosters
	CREATE TABLE #totalpopwithvacandboosters (
		continent NVARCHAR(255)
		,location NVARCHAR(255)
		,DATE DATETIME
		,population FLOAT
		,total_vaccinations NUMERIC
		,total_boosters NVARCHAR(255)
		)

INSERT INTO #totalpopwithvacandboosters
SELECT d.continent
	,d.location
	,d.DATE
	,d.population
	,v.total_vaccinations
	,v.total_boosters
FROM coviddeaths d
JOIN covidvacc v ON d.location = v.location
	AND d.DATE = v.DATE
WHERE d.continent IS NOT NULL
	AND v.total_boosters IS NOT NULL
GROUP BY d.continent
	,d.location
	,d.DATE
	,d.population
	,v.total_vaccinations
	,v.total_boosters;

SELECT *
FROM #totalpopwithvacandboosters


--How many people took covid tests and what's the positivity rate?
SELECT CONVERT(varchar, d.date, 101) as date
	,d.continent
	,d.location
	,v.total_tests
	,v.positive_rate
FROM coviddeaths d
JOIN covidvacc v ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY date
	,continent;


--Whats the average number of people who required hospitalization per country?
SELECT d.location
	,AVG(CAST(d.hosp_patients AS INT)) AS avg_hosp_pt
	,AVG(CAST(d.icu_patients AS INT)) AS avg_icu_pt
FROM coviddeaths d
JOIN covidvacc v ON d.location = v.location
	AND d.DATE = v.DATE
WHERE (
		d.hosp_patients IS NOT NULL
		AND d.icu_patients IS NOT NULL
		)
GROUP BY d.location
ORDER BY avg_hosp_pt DESC;


--Does having at least one covid vaccine shot help prevent deaths?
SELECT DISTINCT d.date
	,d.continent
	,d.location
	,d.new_deaths
	,v.people_vaccinated
FROM coviddeaths d
JOIN covidvacc v ON d.location = v.location
	AND d.date = v.date
WHERE (
		d.continent IS NOT NULL
		AND v.people_vaccinated IS NOT NULL
		)
ORDER BY d.date
	,v.people_vaccinated;


--How many people died of Covid 19 in each continent?
SELECT continent
	,max(cast(total_deaths as int)) as total_death_count
FROM coviddeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY continent;


--How many people died of Covid 19 by country?
SELECT location
	,MAX(CAST(total_deaths as int)) as total_death_count
FROM coviddeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY total_death_count DESC;


--What is the chance of dying in United States?
SELECT SUM(new_cases) AS total_cases
	,SUM(new_deaths) AS total_deaths
	,ROUND(SUM(new_deaths) / SUM(new_cases) * 100, 2) AS DeathPercentage
FROM coviddeaths
WHERE location = 'United States'
	AND continent IS NOT NULL
ORDER BY 1
	,2;


--Which top 10 countries had the highest percentage infection?
SELECT TOP 10 location
	,population
	,MAX(total_cases) AS total_cases
	,ROUND(MAX((total_cases / population)) * 100, 2) AS Percentpopulationinfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
	,population
ORDER BY Percentpopulationinfected DESC;


--Where were the most confirmed cases?
SELECT location
	,max(CAST(total_cases AS INT)) AS total_confirmed_cases
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_confirmed_cases DESC;

--Which year had the most Covid cases?
SELECT DATENAME(YEAR, DATE) AS 'Year'
	,SUM(new_cases) AS new_cases
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY DATENAME(YEAR, DATE)
ORDER BY new_cases DESC; 







