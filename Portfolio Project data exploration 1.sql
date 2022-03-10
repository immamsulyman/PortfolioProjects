SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3, 4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- select the data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--Looking at Total cases VS Total deaths.And percentage of people who died that had it(total_deaths/total_cases)*100 
--Shows Likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Nigeria%'
AND continent is not null
ORDER BY 1, 2

--Looking at Total Cases VS Population
--show what poulation that got covid
SELECT location, date, population, total_cases,  (total_cases/population)*100 AS CasesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
ORDER BY 1, 2

--Looking at Countries with Highest Infection rates compared to population

SELECT location, population, MAX(total_cases) HighestInfectionRate,  MAX((total_cases/population))*100 AS HighestCasesPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestCasesPercentage DESC

--Showing Countries with Highest Death count per population
-- And converting from varchar to integer By usin CAST

SELECT location, MAX(CAST(Total_deaths  AS int)) AS TotaldeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotaldeathCount DESC

--Let's break things down by continents
--Showing continents with the highest death count per population
SELECT continent, MAX(CAST(Total_deaths  AS int)) AS TotaldeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotaldeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total_newCases, SUM(cast(new_deaths as int)) AS Total_newDeath, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
where continent is not null
GROUP BY date
ORDER BY 1
--GLOBAL NUMBERS 2
SELECT SUM(new_cases) AS Total_newCases, SUM(cast(new_deaths as int)) AS Total_newDeath, SUM(cast(new_deaths as int))/SUM(new_cases) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Nigeria%'
where continent is not null
ORDER BY 1

-- Now on COVID VACCINATION

SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date

 --LOOKING AT TOTAL POPULATION VS VACCINATIONS
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.Location Order by dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
 --GROUP BY dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 --ORDER BY dea.location, dea.date

 --USE CTE

 WITH PopVsVacc (Continent, Location, Date, Population, rollingPeopleVaccinated, new_vaccination)
 AS (SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER(PARTITION BY dea.Location Order by dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
 )

 Select *, (rollingPeopleVaccinated/Population)*100
 from PopVsVacc


 --Temp Table
 DROP TABLE if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
  (
 continent nvarchar(255),
 location nvarchar(255),
 date date,
 population numeric,
 new_vaccinations numeric,
 rollingPeopleVaccinated numeric
 )

 INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.Location Order by dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null
 
  Select *, (rollingPeopleVaccinated/Population)*100 newrollingPopulated
 from #PercentPopulationVaccinated

 --creating View to store data for later visualizations

 CREATE VIEW PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.Location Order by dea.date) AS rollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 where dea.continent is not null

