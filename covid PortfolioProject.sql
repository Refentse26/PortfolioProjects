USE PortfolioProject;

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- select data that will be used
SELECT  location, date, total_tests, new_tests, total_deaths, population
 FROM PortfolioProject..CovidVaccinations
 ORDER BY 1,2

SELECT  location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths
 ORDER BY 1,2

-- looking for total cases vs total deaths
-- this shows the likelihood of dying if you contract covid in your country


SELECT location,date,total_cases,total_deaths,(cast(total_deaths as numeric))/cast(total_cases as numeric)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


SELECT location,date,total_cases,total_deaths,(cast(total_deaths as numeric))/cast(total_cases as numeric)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'south africa'
ORDER BY 1,2


--looking at the total cases vs population
-- shows what percentage of population got covid

SELECT location,date,population,total_cases,(cast(total_cases as numeric))/cast(population as numeric)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'south africa'
and continent is not null
ORDER BY 1,2


-- looking  at contries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX(cast (total_cases as numeric))/MAX(cast(population as numeric))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%france%'
and continent is not null
GROUP BY location,population
ORDER BY PercentPopulationInfected desc


-- showing contries with highest deaths count per population

SELECT location,MAX(cast (total_cases as numeric)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc



-- BREAKING THINGS DOWN BYCONTINENT


SELECT location,MAX(cast (total_cases as numeric)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT continent,MAX(cast (total_cases as numeric)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- global numbers

SELECT date,SUM(new_cases), SUM(CAST(new_deaths as numeric)),total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'south africa'
WHERE continent is not null
GROUP BY  date
ORDER BY 1,2



SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as numeric)) as total_daeths,SUM(CAST(new_deaths as numeric))/SUM(New_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'south africa'
WHERE continent is not null
--GROUP BY  date
ORDER BY 1,2


--joing the two tables


SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date


-- looking at total popualtion vs vaccinations


SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USING CTE

with PopvsVac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--Temp Table

CREATE TABLE #PercentPopulationVaccinated
             (
			 continent nvarchar(225),
			 location nvarchar(225),
			 date datetime,
			 population numeric,
			 new_vaccinations numeric,
			 RollingPeopleVaccinated numeric
			 )

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- CREATING VIEWS TO STORE DATAFOR LATER VISUALIZATION


CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


CREATE VIEW using_cte as 
with PopvsVac (continent, location, date,population,new_vaccinations,RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
,SUM(CONVERT(numeric,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

