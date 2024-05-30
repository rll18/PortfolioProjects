SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE trim(continent) <> ''
ORDER BY 3,4

-- Total cases vs total deaths
-- Shows the likelihood of dying if you contract COVID in each country
SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs population
-- Shows what percentage of the population has contracted COVID in each country
SELECT location, date, population, total_cases, (NULLIF(CONVERT(float, total_cases), 0) / NULLIF(CONVERT(float, population), 0)) * 100 as ContractedPercentage 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- What countries have the highest infection rates compared to population
SELECT location, population, MAX(NULLIF(CONVERT(float, total_cases),0)) as HighestInfectionCount, MAX(NULLIF(CONVERT(float, total_cases), 0) / NULLIF(CONVERT(float, population), 0)) * 100 as HighestPercentageInfected 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY HighestPercentageInfected DESC

-- Which countries have the highest death rate compared to population
SELECT location, MAX(NULLIF(CONVERT(float, total_deaths),0)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE trim(continent) <> ''
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Which continents have the highest death rates compared to population
SELECT location, MAX(NULLIF(CONVERT(float, total_deaths),0)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE trim(continent) = ''
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global death percentage by date
SELECT date, sum(CONVERT(float, new_cases)) as TotalCases, SUM(CONVERT(float, new_deaths)) as TotalDeaths, (SUM(CONVERT(float, new_deaths)) / NULLIF(SUM(CONVERT(float, new_cases)),0)) * 100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE trim(continent) <> ''
GROUP BY date
ORDER BY 1,2

-- Global TOTAL death percentage
SELECT sum(CONVERT(float, new_cases)) as TotalCases, SUM(CONVERT(float, new_deaths)) as TotalDeaths, (SUM(CONVERT(float, new_deaths)) / NULLIF(SUM(CONVERT(float, new_cases)),0)) * 100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE trim(continent) <> ''
ORDER BY 1,2

-- Total amount of people vaccinated in the world by date with a rolling total
SELECT d.continent, d.location, d.date, d.population, NULLIF(v.new_vaccinations,0) as Vaccinations,
SUM(NULLIF(CONVERT(float, v.new_vaccinations),0)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE trim(d.continent) <> ''


-- Total amount of people in the world that have been vaccinated
SELECT SUM(CONVERT(float, v.new_vaccinations)) as TotalVaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE trim(d.continent) <> ''

-- Total amount of people in the world that have been vaccinated by country
SELECT d.location, d.population, SUM(CONVERT(float, v.new_vaccinations)) as TotalVaccinations
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE trim(d.continent) = ''
group by d.location, d.population
ORDER BY TotalVaccinations DESC

-- Total amount of people vaccinated in the world by date with a rolling total
With PopvsVac (continent, location, date, population, vaccinations, RollingPeopleVaccinated)
as ( 
SELECT d.continent, d.location, d.date, d.population, NULLIF(v.new_vaccinations,0) as Vaccinations,
SUM(NULLIF(CONVERT(float, v.new_vaccinations),0)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE trim(d.continent) <> ''
)
SELECT *, (RollingPeopleVaccinated/population) * 100 as RollingPercent
FROM PopvsVac


--Temp table rather than CTE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population varchar(255),
new_vaccinations varchar(255),
rollingPeopleVaccinated float
)

INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, NULLIF(v.new_vaccinations,0) as Vaccinations,
SUM(NULLIF(CONVERT(float, v.new_vaccinations),0)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE trim(d.continent) <> ''

SELECT *, (RollingPeopleVaccinated/population) * 100 as RollingPercent
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT d.continent, d.location, d.date, d.population, NULLIF(v.new_vaccinations,0) as Vaccinations,
SUM(NULLIF(CONVERT(float, v.new_vaccinations),0)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
JOIN PortfolioProject..CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
WHERE trim(d.continent) <> ''

