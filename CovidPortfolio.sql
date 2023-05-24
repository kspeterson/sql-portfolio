SELECT *
FROM CovidPortfolio..CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidPortfolio..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths in USA:
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidPortfolio..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows percdntage of population that contracted Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
FROM CovidPortfolio..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidPortfolio..CovidDeaths
GROUP BY location, population 
ORDER BY PercentPopulationInfected desc

-- Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Breaking things down by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global numbers per day
SELECT date, SUM(new_cases) AS NewCasesPerDay, SUM(cast(new_deaths as int)) AS DeathsPerDay, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
FROM CovidPortfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Global numbers total
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as DeathPercentage
FROM CovidPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


--Looking at total population vs. vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolio..CovidDeaths dea
JOIN CovidPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolio..CovidDeaths dea
JOIN CovidPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPopulationPercentage FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolio..CovidDeaths dea
JOIN CovidPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS VaccinatedPopulationPercentage FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PopulationVaccinatedPercent AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolio..CovidDeaths dea
JOIN CovidPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PopulationVaccinatedPercent