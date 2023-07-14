SELECT * FROM CovidVaccinations$
ORDER BY 3,4

----SELECT * FROM CovidDeaths$
----ORDER BY 3,4

---Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2

--Total cases vs total deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS percentagedeath
FROM CovidDeaths$
WHERE location like '%kenya%'
ORDER BY 1,2

--Total cases vs population

SELECT location, date, population, total_cases,(total_cases/population)*100 AS percentagecase
FROM CovidDeaths$
WHERE location like '%kenya%' --edit this according to your location
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highestInfectionCount,MAX((total_cases/population))*100 AS InfectedPopulation
FROM CovidDeaths$
GROUP BY location, population
ORDER BY InfectedPopulation desc

--Countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Death Count by Continent
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Death Count by Continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as deathpercentage
FROM CovidDeaths$
WHERE continent is not null
ORDER BY 1,2


--Total population vs vaccination

SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
  ORDER BY 2,3

  --USE CTE
  With PopvsVac (Continent, Location, Date, Population, new_vaccinations, cumulative_vaccinations)
  as
  (
  SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null
 )
 SELECT *, (cumulative_vaccinations/population)*100
 FROM PopvsVac

 --USE TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
 CREATE Table #PercentPopulationVaccinated
 (
 Contintent nvarchar(255),
 Location nvarchar(255),
 Date  datetime,
 Population numeric,
 new_vaccinations numeric,
 cumulative_vaccinations numeric
 )

 Insert into #PercentPopulationVaccinated
 SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null

  SELECT *, (cumulative_vaccinations/population)*100
 FROM #PercentPopulationVaccinated

 --create view
 Create View PercentPopulationVaccinated as
 SELECT dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as cumulative_vaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
  ON dea.location = vac.location
  and dea.date = vac.date
  WHERE dea.continent is not null

  SELECT * FROM PercentPopulationVaccinated