-- Comentarios (Primeira query)
-- Se quisermos TIRAR a coluna date (Ela ta em formato text)
-- Ai vamos colocar uma nova em formato date
/*
ALTER TABLE PUBLIC."CovidDeaths" ADD COLUMN new_date_column date;
UPDATE PUBLIC."CovidDeaths" SET new_date_column = TO_DATE(date, 'DD/MM/YYYY');
ALTER TABLE PUBLIC."CovidDeaths" DROP COLUMN date;
ALTER TABLE PUBLIC."CovidDeaths" RENAME COLUMN new_date_column TO date;
*/

-- So trocar o tipo da coluna, ja fiz isso uma vez agora ta salvo
/*ALTER TABLE PUBLIC."CovidDeaths" ALTER COLUMN date TYPE DATE
using TO_DATE(date, 'DD/MM/YYYY'); */
/*ALTER TABLE PUBLIC."CovidVaccinations" ALTER COLUMN date TYPE DATE
using TO_DATE(date, 'DD/MM/YYYY');  */

-- Primeiro SELECT, so para testar
-- ORDER BY vai ordenar pelas colunas 3 e 4
SELECT *
FROM PUBLIC."CovidDeaths"
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Segundo SELECT so para verificar
SELECT *
FROM PUBLIC."CovidVaccinations";

-- Data que vamos usar
-- So pra testar tambem
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PUBLIC."CovidDeaths"
ORDER BY location, date;

-- Total Cases x Total deaths
-- Progressão de casos e mortes por local e dia
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS PorcentagemMortes
FROM PUBLIC."CovidDeaths"
ORDER BY location, date;

-- Total Cases x Total deaths --> Brasil
-- Porcentagem de mortes pelo numero de casos
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS PorcentagemMortes
FROM PUBLIC."CovidDeaths"
WHERE location = 'Brazil'
ORDER BY location, date;

-- Total Cases x Population
-- Porcentagem da populacao com covid
SELECT location, date, total_cases, population, ((total_cases/(population))*100) AS PorcentagemCovid
FROM PUBLIC."CovidDeaths"
WHERE location = 'Brazil'
ORDER BY location, date;

-- Paises com maior taxa de infestação (Porcentagem em relação a populacao)
SELECT location, population, MAX(total_cases) AS MaxInfection, MAX((total_cases/population)*100) AS MaxPorcentagemCovid
FROM PUBLIC."CovidDeaths"
WHERE (continent IS NOT NULL) AND (total_cases IS NOT NULL)
GROUP BY location, population 
ORDER BY 4 DESC;

-- Ordenado por quantidade de mortos (Obviamente paises com população maior vem primeiro)
SELECT location, MAX(total_deaths) AS Total_Mortes
FROM PUBLIC."CovidDeaths"
WHERE (continent IS NOT NULL) AND (total_deaths IS NOT NULL)
GROUP BY location
ORDER BY 2 DESC;

-- Ordenar por Maior numero de mortes em um dia
-- Ta Certo agora
-- Criamos com WITH uma nova tabela temporaria chamada morte_dia (Com as colunas)
-- Usando o AS, a gente define oq vão popular cada coluna (Dentro do parenteses)
WITH morte_dia (location, date,Max_Mortes_Dia)
AS
(
SELECT location, date, MAX(new_deaths) AS Max_Mortes_Dia
FROM PUBLIC."CovidDeaths"
WHERE new_deaths > 0
GROUP BY location, date
ORDER BY 2 DESC
)
-- Depois a gente vem pra ca e faz um select normal, usando nossa nova tabela
-- temporaria chamada morte_dia, SELECT normal
-- O WHERE é um pouco diferente, leia que tu vai entender

SELECT *
FROM morte_dia
WHERE (location, max_mortes_dia) IN
(SELECT location, MAX(max_mortes_dia)
 FROM morte_dia
 GROUP BY location
) 

ORDER BY 3 DESC
;

------ USAR O NOVO DATASET, O CovidVaccinations
SELECT *
FROM PUBLIC."CovidVaccinations";

-- JOIN com CovidDeaths
SELECT *
FROM PUBLIC."CovidDeaths" as dea
JOIN PUBLIC."CovidVaccinations" as vac 
ON dea.location = vac.location
and dea.date = vac.date;

-- JOIN com CovidDeaths
-- Pop. Total vs Vaccs
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS Acumulado_Vaccs
FROM PUBLIC."CovidDeaths" AS dea
JOIN PUBLIC."CovidVaccinations" AS vac ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE = VAC.DATE
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date;


-- Pop. Total vs Vaccs
-- CTE
WITH PopVac (continent, location, date, population, new_vaccinations, Acumulado_vaccs)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS Acumulado_Vaccs
FROM PUBLIC."CovidDeaths" AS dea
JOIN PUBLIC."CovidVaccinations" AS vac ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE = VAC.DATE
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date
)
SELECT *, (acumulado_vaccs / population) * 100 AS Porcentagem_vac
FROM PoPVac;


-- Create View
CREATE VIEW Porcentagem_Vac_Brazil 
AS

WITH PopVac (continent, location, date, population, new_vaccinations, Acumulado_vaccs)

AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location Order by dea.location, dea.date) AS Acumulado_Vaccs
FROM PUBLIC."CovidDeaths" AS dea
JOIN PUBLIC."CovidVaccinations" AS vac ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE = VAC.DATE
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date
)
SELECT *, (acumulado_vaccs / population) * 100 AS Porcentagem_vac
FROM PoPVac
WHERE location = 'Brazil';


-- Ver o view
SELECT *
FROM porcentagem_vac_brazil;