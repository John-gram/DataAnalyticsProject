/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM [PORTFOLIO PROJECT 1]..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4


-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PORTFOLIO PROJECT 1]..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2 


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [PORTFOLIO PROJECT 1]..CovidDeaths
--WHERE location like '%Cyprus%'
--AND continent IS NOT NULL 
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, Population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM [PORTFOLIO PROJECT 1]..CovidDeaths
--WHERE location like '%Cyprus%'
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [PORTFOLIO PROJECT 1]..CovidDeaths
--Where location like '%Cyprus%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM [PORTFOLIO PROJECT 1]..CovidDeaths
--Where location like '%states%'
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(Total_deaths as int)) AS TotalDeathCount
FROM [PORTFOLIO PROJECT 1]..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(CAST(new_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM [PORTFOLIO PROJECT 1]..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL 
--Group By date
ORDER BY 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PORTFOLIO PROJECT 1]..CovidDeaths DEA
JOIN [PORTFOLIO PROJECT 1]..CovidVaccinations VAC
	On DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PORTFOLIO PROJECT 1]..CovidDeaths DEA
JOIN [PORTFOLIO PROJECT 1]..CovidVaccinations VAC
	On DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PORTFOLIO PROJECT 1]..CovidDeaths DEA
JOIN [PORTFOLIO PROJECT 1]..CovidVaccinations VAC
	On DEA.location = VAC.location
	AND DEA.date = VAC.date
--WHERE DEA.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVacciated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations
, SUM(CONVERT(int,VAC.new_vaccinations)) OVER (PARTITION BY DEA.Location ORDER BY DEA.location, DEA.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PORTFOLIO PROJECT 1]..CovidDeaths DEA
JOIN [PORTFOLIO PROJECT 1]..CovidVaccinations VAC
	On DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL 



