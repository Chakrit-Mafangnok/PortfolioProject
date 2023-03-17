SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)*100) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Thailand%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (CAST(total_cases AS float) / CAST(population AS float)*100) AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Thailand%'
ORDER BY 1,2

-- Looking at Countries with Hignest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(CAST(total_cases AS float) / CAST(population AS float))*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Thailand%'
Group BY location, population
ORDER BY InfectedPercentage DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Thailand%'
WHERE continent IS NULL
Group BY location
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Thailand%'
WHERE continent IS NOT NULL
Group BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Thailand%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated / Population)*100
FROM PopvsVac

--TEMP TABLE


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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	--WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated / Population)*100
FROM #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATE VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated