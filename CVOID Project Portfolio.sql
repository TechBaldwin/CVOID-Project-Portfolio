--Select *
--From PortfolioProject..CovDeaths
--order by 3,4

--
--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From CovDeaths
WHERE continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From CovDeaths
Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From CovDeaths
--Where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovDeaths
--Where location like '%states%'
Where continent is not null 
Group by location
order by TotalDeathCount desc

--Let's break things down by continent
--showing contintents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global numbers
Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovDeaths
--Where location like '%states%'
where continent is not null
Group by date
order by 1,2

--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovDeaths dea
Join CovidVax vax
  On dea.location = vax.location
  and dea.date = vax.date
where dea.continent is not null 
order by 2,3


--USE CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovDeaths dea
Join CovidVax vax
  On dea.location = vax.location
  and dea.date = vax.date
where dea.continent is not null 
--order by 2,3
)
Select *
From PopvsVac



--Temp Table
Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(

Continent nvarchar(255),
Location nvarchar(255),
date    datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovDeaths dea
Join CovidVax vax
  On dea.location = vax.location
  and dea.date = vax.date
where dea.continent is not null 
--order by 2,3

Select *
From #PercentPopulationVaccinated


-- Create view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations
, SUM(cast(vax.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovDeaths dea
Join CovidVax vax
  On dea.location = vax.location
  and dea.date = vax.date
where dea.continent is not null 
--order by 2,3