/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



--A brief overview of the data

SELECT *
FROM Portfolio_project..CovidDeaths

SELECT * 
FROM Portfolio_project..CovidVaccinations

Select *
From Portfolio_project..CovidDeaths
Where continent is not null 
order by 3,4

Select *
From Portfolio_project..CovidVaccinations
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project..CovidDeaths
Where continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- This will show the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_project..CovidDeaths
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_project..CovidDeaths
WHERE location Like 'Africa'
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_project..CovidDeaths
WHERE location Like '%states%'
ORDER BY 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Portfolio_project..CovidDeaths
WHERE location Like '%kingdom%'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Population_Infected
FROM Portfolio_project..CovidDeaths
WHERE location Like '%kingdom%'
ORDER BY 1,2

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS Population_Infected
FROM Portfolio_project..CovidDeaths
WHERE location Like 'Africa'
ORDER BY 1,2


-- Looking at countries with Hghest Infection Rate compared to population

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX(total_cases/population)*100 AS Percent_Population_Infected
FROM Portfolio_project..CovidDeaths
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC


--Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM Portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC


--Showing the continent with the highest death count
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count
FROM Portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC



--Global Level Analysis
--Total new cases, new deaths and death percentage in the world per day

SELECT date, SUM(New_cases) as total_cases, SUM(CAST(New_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--Now the % of population vaccinated against the total population in each country by using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM Portfolio_project..CovidDeaths dea
JOIN Portfolio_project..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 

