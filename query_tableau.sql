-- Table 1
-- Mortes por casos
SELECT SUM(NEW_CASES) AS TOTAL_CASES, SUM(NEW_DEATHS) AS TOTAL_DEATHS,
SUM(NEW_DEATHS)/SUM(NEW_CASES) * 100 AS DEATHPERCENTAGE
FROM PUBLIC."CovidDeaths" 
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2;

-- Table 2
-- Total de mortes por continente
SELECT LOCATION, SUM(NEW_DEATHS) AS TOTALDEATHCOUNT
FROM PUBLIC."CovidDeaths" 
WHERE CONTINENT IS NULL
AND LOCATION IN('Europe','Asia','North America','South America', 'Africa', 'Oceania')
-- AND LOCATION NOT IN ('World','European Union','International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY LOCATION
ORDER BY TOTALDEATHCOUNT DESC;

-- Table 3
-- % Da populacao que fo infectada
SELECT LOCATION, POPULATION, MAX(TOTAL_CASES) AS HIGHESTINFECTIONCOUNT,
MAX((TOTAL_CASES / POPULATION)) * 100 AS PERCENTPOPULATIONINFECTED
FROM PUBLIC."CovidDeaths" 
WHERE (continent IS NOT NULL)
GROUP BY LOCATION, POPULATION
ORDER BY PERCENTPOPULATIONINFECTED DESC;

-- Table 4
-- NUM SEI
SELECT LOCATION, POPULATION, date, MAX(TOTAL_CASES) AS HIGHESTINFECTIONCOUNT,
MAX((TOTAL_CASES / POPULATION)) * 100 AS PERCENTPOPULATIONINFECTED
FROM PUBLIC."CovidDeaths"
WHERE TOTAL_CASES IS NOT NULL
GROUP BY LOCATION, POPULATION, date
ORDER BY PERCENTPOPULATIONINFECTED DESC;

-- Table 5
-- Total Cases x Population
-- Brazil
SELECT location, date, total_cases, population, ((total_cases/(population))*100) AS PorcentagemCovid
FROM PUBLIC."CovidDeaths"
WHERE location = 'Brazil'
ORDER BY location, date;

-- Table 6 (GRANDE)
-- Total Cases x Total deaths
-- Progressão de casos e mortes por local e dia
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS PorcentagemMortes
FROM PUBLIC."CovidDeaths"
ORDER BY location, date;

-- Table 6 (EXCEL)
-- Porcentagem de mortes pelo numero de casos
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS PorcentagemMortes
FROM PUBLIC."CovidDeaths"
WHERE location = 'Brazil'
ORDER BY location, date;
